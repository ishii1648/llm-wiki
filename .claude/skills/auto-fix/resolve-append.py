#!/usr/bin/env python3
"""
auto-fix skill: append-only な wiki ファイルの merge conflict を決定論的に解消する。

このリポジトリの conflict の大半は、両側のブランチが wiki/index.md / wiki/sources.md /
wiki/log.md に **新しいエントリを末尾追記しただけ** で起きる(既存行の書き換えではない)。
このパターンは機械的に union できるので、LLM の文字列操作に頼らず決定論的に解消する。

対象ファイル(ファイル名で振り分け):
- wiki/index.md     — [[name]] をキーに dedup。ours の出現順を保ち、theirs にしか無い行を末尾追加
- wiki/sources.md   — `- raw/...` のパスをキーに dedup。同上
- wiki/log.md       — `## [YYYY-MM-DD] ...` ブロック単位で dedup(見出し行が完全一致のものを同一視)

衝突検知:
  同じキー(または同じ log 見出し)が ours / theirs 両方に出現し、かつ **行内容が異なる**
  hunk は決定論的に解消できない(既存行の書き換え=セマンティック衝突)ため、その hunk は
  コンフリクトマーカーを残したまま書き戻して exit 1 で終了する。LLM/人間に判断を委ねる。

Usage:
    python3 resolve-append.py <file> [<file> ...]

Exit codes:
  0 — すべての対象 hunk を解消(または元から conflict が無い)
  1 — 一部 hunk が衝突 (collision) で未解消。マーカーは保持
  2 — 対象外のファイル名 / 引数なし
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

CONFLICT_START = re.compile(r"^<{7}( .*)?$")
CONFLICT_MID = re.compile(r"^={7}$")
CONFLICT_END = re.compile(r"^>{7}( .*)?$")


def parse_conflicts(text: str):
    """Return list of either:
        str                                    — 非 conflict 領域
        ('conflict', start, ours, mid, theirs, end) — conflict hunk(マーカー行も保持)
    """
    out: list = []
    buf: list[str] = []
    lines = text.splitlines(keepends=True)
    i = 0
    while i < len(lines):
        if CONFLICT_START.match(lines[i].rstrip("\n")):
            if buf:
                out.append("".join(buf))
                buf = []
            start_marker = lines[i]
            i += 1
            ours: list[str] = []
            while i < len(lines) and not CONFLICT_MID.match(lines[i].rstrip("\n")):
                ours.append(lines[i])
                i += 1
            if i >= len(lines):
                raise ValueError("unterminated conflict: missing =======")
            mid_marker = lines[i]
            i += 1
            theirs: list[str] = []
            while i < len(lines) and not CONFLICT_END.match(lines[i].rstrip("\n")):
                theirs.append(lines[i])
                i += 1
            if i >= len(lines):
                raise ValueError("unterminated conflict: missing >>>>>>>")
            end_marker = lines[i]
            i += 1
            out.append(("conflict", start_marker, ours, mid_marker, theirs, end_marker))
        else:
            buf.append(lines[i])
            i += 1
    if buf:
        out.append("".join(buf))
    return out


def key_index(line: str) -> str | None:
    """wiki/index.md のエントリ行から [[name]] を抽出。エントリ行でなければ None。"""
    if not line.lstrip().startswith("-"):
        return None
    m = re.search(r"\[\[([^\]]+)\]\]", line)
    return m.group(1) if m else None


def key_sources(line: str) -> str | None:
    """wiki/sources.md のエントリ行から raw パスを抽出。エントリ行でなければ None。"""
    m = re.match(r"^- (raw/\S+)", line)
    return m.group(1) if m else None


def union_by_key(ours: list[str], theirs: list[str], key_fn):
    """両側のリスト行を union。
    Returns:
      merged str  — 衝突なし。ours の順序を保ち、theirs にしかない行を末尾追加
      None        — 衝突あり(同一キーで行内容が異なる)→ 決定論的に解消不可

    キーが取れない行(セクション見出し・空行・コメント等)は ours 側のみ採用する。
    """
    ours_by_key: dict[str, str] = {}
    for line in ours:
        k = key_fn(line)
        if k is None or k in ours_by_key:
            continue
        ours_by_key[k] = line.rstrip("\n")
    theirs_by_key: dict[str, str] = {}
    for line in theirs:
        k = key_fn(line)
        if k is None or k in theirs_by_key:
            continue
        theirs_by_key[k] = line.rstrip("\n")

    for k, v in ours_by_key.items():
        if k in theirs_by_key and theirs_by_key[k] != v:
            return None  # collision: same key, different line

    seen: set[str] = set()
    out: list[str] = []
    for line in ours:
        k = key_fn(line)
        if k is None:
            out.append(line)
            continue
        if k in seen:
            continue
        seen.add(k)
        out.append(line)
    for line in theirs:
        k = key_fn(line)
        if k is None:
            continue
        if k in seen:
            continue
        seen.add(k)
        out.append(line)
    return "".join(out)


def _split_log_blocks(lines: list[str]) -> list[list[str]]:
    blocks: list[list[str]] = []
    current: list[str] | None = None
    for line in lines:
        if line.startswith("## ["):
            if current is not None:
                blocks.append(current)
            current = [line]
        else:
            if current is None:
                current = [line]
            else:
                current.append(line)
    if current is not None:
        blocks.append(current)
    return blocks


def union_log_blocks(ours: list[str], theirs: list[str]):
    """wiki/log.md のブロック union。
    Returns:
      merged str — 衝突なし。出力順は ours_blocks → theirs_blocks
      None       — 衝突あり(同一見出しでブロック本文が異なる)
    """
    ours_blocks = _split_log_blocks(ours)
    theirs_blocks = _split_log_blocks(theirs)

    ours_by_head: dict[str, str] = {}
    for b in ours_blocks:
        h = b[0].rstrip("\n")
        if h not in ours_by_head:
            ours_by_head[h] = "".join(b)
    theirs_by_head: dict[str, str] = {}
    for b in theirs_blocks:
        h = b[0].rstrip("\n")
        if h not in theirs_by_head:
            theirs_by_head[h] = "".join(b)

    for h, body in ours_by_head.items():
        if h in theirs_by_head and theirs_by_head[h] != body:
            return None

    seen: set[str] = set()
    result: list[str] = []
    for block in ours_blocks + theirs_blocks:
        head = block[0].rstrip("\n")
        if head in seen:
            continue
        seen.add(head)
        result.append("".join(block))
    return "".join(result)


RESOLVERS = {
    "index.md": lambda o, t: union_by_key(o, t, key_index),
    "sources.md": lambda o, t: union_by_key(o, t, key_sources),
    "log.md": union_log_blocks,
}


def resolve(path: Path) -> int:
    fname = path.name
    resolver = RESOLVERS.get(fname)
    if resolver is None:
        print(f"[skip] {path}: no resolver for filename '{fname}'", file=sys.stderr)
        return 2

    text = path.read_text(encoding="utf-8")
    if "<<<<<<<" not in text:
        print(f"[noop] {path}: no conflict markers")
        return 0

    try:
        parts = parse_conflicts(text)
    except ValueError as e:
        print(f"[fail] {path}: {e}", file=sys.stderr)
        return 1

    output: list[str] = []
    unresolved_hunks = 0
    resolved_hunks = 0
    for p in parts:
        if isinstance(p, str):
            output.append(p)
            continue
        _, start, ours, mid, theirs, end = p
        merged = resolver(ours, theirs)
        if merged is None:
            unresolved_hunks += 1
            output.append(start)
            output.extend(ours)
            output.append(mid)
            output.extend(theirs)
            output.append(end)
        else:
            resolved_hunks += 1
            output.append(merged)

    path.write_text("".join(output), encoding="utf-8")
    if unresolved_hunks > 0:
        print(
            f"[partial] {path}: resolved={resolved_hunks} unresolved={unresolved_hunks} "
            "(collision: same key with different content — left markers for human/LLM)",
            file=sys.stderr,
        )
        return 1
    print(f"[ok] {path}: resolved {resolved_hunks} hunk(s)")
    return 0


def main() -> None:
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    rc = 0
    for arg in sys.argv[1:]:
        r = resolve(Path(arg))
        if r > rc:
            rc = r
    sys.exit(rc)


if __name__ == "__main__":
    main()

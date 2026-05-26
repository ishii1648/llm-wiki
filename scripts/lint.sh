#!/usr/bin/env bash
#
# lint.sh — wiki の決定論的健全性チェック
#
# CLAUDE.md の lint 操作の前段。grep/find で機械的に判定できる項目だけを扱い、
# 矛盾の検出や陳腐化判定など意味的なチェックは LLM が担う。
#
# チェック項目:
#   1. dangling link  : [[X]] の参照先ページファイルが存在しない
#   2. orphan page    : 他のコンテンツページからの被リンクが 0 のページ
#   3. broken source  : ページ/台帳が指す raw/ パスが実在しない
#   4. ledger mismatch: ページの sources: と sources.md 台帳の食い違い
#
# 抽出はコードフェンス(```)・HTML コメント(<!-- -->)・インラインコード(`...`)を
# 除去してから行う。これらは書式例・テンプレートであり実在参照ではないため。
#
# 終了コード: 問題ゼロなら 0、1件以上検出で 1(pre-commit / CI で利用可)。

set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WIKI="$ROOT/wiki"
PAGE_DIRS=("$WIKI/entities" "$WIKI/concepts" "$WIKI/syntheses")
# 被リンク元として数えない（=カタログ/ログ/台帳）ファイル
NON_PAGE_RE='/wiki/(index|log|sources)\.md$'

issues=0
note() { printf '  - %s\n' "$1"; issues=$((issues + 1)); }

# コンテンツページのファイルパス一覧
page_files() { find "${PAGE_DIRS[@]}" -name '*.md' 2>/dev/null | sort; }
# index/log/sources を除く全ページ（被リンク元の母集団）
content_files() { page_files | grep -vE "$NON_PAGE_RE"; }
# wiki 配下の全 md
all_md() { find "$WIKI" -name '*.md' 2>/dev/null | sort; }

# 書式例・テンプレートを除いた本文を出力（コードフェンス→HTMLコメント→インラインコード）
clean() {
  awk '/^[[:space:]]*```/ { f = !f; next } !f { print }' "$1" \
    | perl -0777 -pe 's/<!--.*?-->//gs; s/`[^`]*`//g'
}

# 与えたファイル群から [[target]] を抽出（alias `|`・heading `#` を除去、ユニーク）
links_in() {
  for f in "$@"; do clean "$f"; done \
    | grep -oE '\[\[[^]]+\]\]' \
    | sed -E 's/^\[\[//; s/\]\]$//; s/\|.*$//; s/#.*$//; s/[[:space:]]+$//' \
    | sort -u
}

echo "== wiki lint =="
echo "root: $ROOT"
echo

# --- 1. dangling link --------------------------------------------------------
echo "[1] dangling links ([[X]] の参照先が無い)"
names_tmp="$(mktemp)"
page_files | while read -r f; do basename "$f" .md; done | sort -u > "$names_tmp"
while IFS= read -r t; do
  [ -z "$t" ] && continue
  grep -qxF "$t" "$names_tmp" || note "[[$t]] → wiki/{entities,concepts,syntheses}/$t.md が無い"
done < <(links_in $(all_md))
rm -f "$names_tmp"
echo

# --- 2. orphan page ----------------------------------------------------------
echo "[2] orphan pages (コンテンツページからの被リンク 0)"
refs_tmp="$(mktemp)"
links_in $(content_files) > "$refs_tmp"
while IFS= read -r f; do
  name="$(basename "$f" .md)"
  grep -qxF "$name" "$refs_tmp" || note "[[$name]] はどのページからもリンクされていない ($f)"
done < <(page_files)
rm -f "$refs_tmp"
echo

# --- 3. broken source path ---------------------------------------------------
echo "[3] broken source paths (参照される raw/ が実在しない)"
while IFS= read -r p; do
  [ -z "$p" ] || [ -e "$ROOT/$p" ] || note "$p が存在しない"
done < <(for f in $(all_md); do clean "$f"; done | grep -oE 'raw/[A-Za-z0-9._/-]+' | sort -u)
echo

# --- 4. ledger / sources frontmatter mismatch --------------------------------
echo "[4] ledger 整合 (ページ sources: と wiki/sources.md の双方向一致)"
ledger="$WIKI/sources.md"
ledger_tmp="$(mktemp)"; pages_src_tmp="$(mktemp)"
clean "$ledger" | grep -oE '^- raw/[A-Za-z0-9._/-]+' | sed -E 's/^- //' | sort -u > "$ledger_tmp"
for f in $(page_files); do clean "$f"; done \
  | grep -oE '^[[:space:]]*-[[:space:]]*raw/[A-Za-z0-9._/-]+' \
  | sed -E 's/^[[:space:]]*-[[:space:]]*//' | sort -u > "$pages_src_tmp"
while IFS= read -r p; do
  [ -z "$p" ] || note "$p はページの出典だが sources.md 台帳に未登録"
done < <(comm -23 "$pages_src_tmp" "$ledger_tmp")
while IFS= read -r p; do
  [ -z "$p" ] || note "$p は台帳にあるが、出典に持つページが無い"
done < <(comm -13 "$pages_src_tmp" "$ledger_tmp")
rm -f "$ledger_tmp" "$pages_src_tmp"
echo

# --- 結果 --------------------------------------------------------------------
if [ "$issues" -eq 0 ]; then
  echo "OK: 決定論的チェックで問題は見つかりませんでした。"
  exit 0
else
  echo "検出: $issues 件。上記を確認し、必要なら LLM lint で意味的チェックを続けてください。"
  exit 1
fi

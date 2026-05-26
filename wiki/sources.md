# Source Ledger

ingest 済みソースの台帳。**冪等性チェックの唯一の基準**です。1行 = 1ソース。
ingest のたびに LLM が追記・更新します(過去行は再 ingest 時のみ書き換える)。

形式:
```
- <raw パス> | sha256:<先頭12桁> | <ingest 日 YYYY-MM-DD> | <波及ページ>
```

- **sha256**: ソース本文のハッシュ先頭12桁。`shasum -a 256 <path> | cut -c1-12` で算出。
  再 ingest 時にこの値が一致すれば「内容不変 = 何もしない」、不一致なら「改訂されたので該当ページを更新」と判定する。
- **波及ページ**: そのソースを出典に持つページを `[[page]], [[page]]` 形式で列挙。
  各ページ frontmatter の `sources:` と双方向で一致していること(lint がチェック)。

抽出例: `grep "^- raw/" wiki/sources.md`

---

<!-- 例:
- raw/articles/example.md | sha256:abc123def456 | 2026-05-27 | [[page-a]], [[page-b]]
-->
（まだありません）

# llm-wiki

[Andrej Karpathy が提唱した **LLM wiki パターン**](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) の個人用実装。

RAG のように「クエリのたびに生データを検索して即興合成する」のではなく、LLM エージェントが markdown ファイル群を読み書き・保守し、**知識を蓄積(compound)させていく** 永続ナレッジベース。

## 構造

```
raw/      ソースの原本（人間が追加・LLM は読取専用）
  articles/  papers/  assets/
wiki/     LLM が所有するページ群
  index.md     全ページのカタログ
  log.md       追記専用の操作ログ
  sources.md   ingest 済みソースの台帳（冪等性判定の基準）
  entities/    人物・製品・組織・ツール・論文 …
  concepts/    抽象的な概念・手法・パターン
  syntheses/   横断的な比較・分析・まとめ
scripts/  補助スクリプト
  lint.sh      決定論的な健全性チェック（リンク切れ・孤立・出典実在）
CLAUDE.md エージェント運用スキーマ（本体）
```

## 使い方

1. 取り込みたい記事/論文を `raw/articles/` や `raw/papers/` に置く（markdown 推奨。Obsidian Web Clipper などで変換）。
2. Claude Code をこのディレクトリで開き、`これを ingest して: raw/articles/xxx.md` と依頼。
3. 質問するときは `〜について教えて`（query）。良い回答は自動的に `wiki/syntheses/` へ蓄積される。
4. 定期的に `lint して` で矛盾・孤立ページ・知識ギャップを点検（前段で `bash scripts/lint.sh` が決定論的チェックを実行）。

詳細なワークフローと書式は [CLAUDE.md](./CLAUDE.md) を参照。

## 補助ツール（任意）

- **Obsidian**: この `wiki/` フォルダを Vault として開くと `[[wiki-links]]` の Graph view、Web Clipper、Dataview が使える。
- **git**: 変更履歴・差分レビュー・ブランチが無料で得られる。

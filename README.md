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
mkdocs.yml             GitHub Pages（MkDocs Material）の設定
requirements-docs.txt  Pages ビルドの依存
CLAUDE.md エージェント運用スキーマ（本体）
```

## 使い方

1. Claude Code をこのディレクトリで開き、取り込みたいソースを指定して `これを ingest して: <URL またはファイルパス>` と依頼。Claude が原本を `raw/` に**忠実に保存**してから wiki へ統合するまでをワンアクションで実行する。
   - 自分で先に `raw/articles/` や `raw/papers/` へ置いてからパスを渡してもよい（markdown 推奨。Obsidian Web Clipper などで変換）。何を取り込むかの判断は常に人間が持つ。
2. 質問するときは `〜について教えて`（query）。良い回答は自動的に `wiki/syntheses/` へ蓄積される。
3. 定期的に `lint して` で矛盾・孤立ページ・知識ギャップを点検（前段で `bash scripts/lint.sh` が決定論的チェックを実行）。

詳細なワークフローと書式は [CLAUDE.md](./CLAUDE.md) を参照。

## 補助ツール（任意）

- **Obsidian**: この `wiki/` フォルダを Vault として開くと `[[wiki-links]]` の Graph view、Web Clipper、Dataview が使える。
- **git**: 変更履歴・差分レビュー・ブランチが無料で得られる。

## GitHub Pages で公開

`wiki/` を [MkDocs Material](https://squidfunk.github.io/mkdocs-material/) で静的サイト化し、GitHub Pages へ自動公開する。

- 公開 URL: **https://ishii1648.github.io/llm-wiki/**
- ビルド/デプロイは [`.github/workflows/deploy-docs.yml`](./.github/workflows/deploy-docs.yml) が担う（`gh-pages` ブランチへ公開）。
  - **`main` への push**: サイト本体を更新。
  - **PR の作成/更新**: `pr-preview/pr-<N>/` にプレビューをデプロイし、PR にプレビュー URL を自動コメント（`https://ishii1648.github.io/llm-wiki/pr-preview/pr-<N>/`）。
  - **PR のクローズ**: 対応するプレビューを自動削除。
- Obsidian 互換の `[[wikilink]]` は [roamlinks プラグイン](https://github.com/Jackiexiao/mkdocs-roamlinks-plugin)がビルド時に通常リンクへ変換する（**`wiki/` のソースは加工しない**）。
- 運用ログ `log.md` とソース台帳 `sources.md` は公開サイトから除外している（`mkdocs.yml` の `exclude_docs`）。

### 初回セットアップ（リポジトリ管理者が一度だけ）

リポジトリの **Settings → Pages → Build and deployment** で **Source = 「Deploy from a branch」**、**Branch = `gh-pages` / `/ (root)`** を選択する。`gh-pages` ブランチは初回のワークフロー実行で自動作成される。以後は push / PR のたびに自動更新される。

### ローカルプレビュー

```bash
pip install -r requirements-docs.txt
mkdocs serve   # http://127.0.0.1:8000/ で確認
```

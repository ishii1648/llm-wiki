# Log

追記専用の操作ログ。新しいエントリを**末尾に**追加し、過去エントリは編集しません。
形式: `## [YYYY-MM-DD] <ingest|query|lint> | <タイトル>`

抽出例: `grep "^## \[" wiki/log.md | tail -5`

---

## [2026-05-24] init | リポジトリ初期化
- LLM wiki パターンの雛形を作成(raw/ と wiki/ の構造、CLAUDE.md スキーマ)。
- 最初のソースを `raw/` に追加して `ingest` から運用開始する。

## [2026-05-27] ingest | oven-sh/bun の Claude Code 活用パターン(外部ソース)
- 追加したページ: [[bun-claude-code-patterns]], [[bun]]
- ソース: GitHub の oven-sh/bun(CLAUDE.md / .claude / .github/workflows / scripts)。raw/ 配下ではないため sources.md 台帳には登録せず、各ページに URL を明記。
- 主な学び: ガードレールを hooks で「コードとして」強制(回避テクニックまで先回りで deny)、重複検出は LLM・クローズは cron スクリプトという役割分担、slash command をマルチエージェント並列検索+フィルタ段で構成し CI(claude-code-base-action)から無人実行、エージェント向けに既製ツールの落とし穴を埋める自前 CLI(ci:* / pr:comments)を整備、AI slop PR の自動クローズゲート。
- 矛盾・要確認: 対象は 2026-05-27 時点の main。CLAUDE.md/workflow は頻繁に改訂されるため参照時点とのズレに注意。

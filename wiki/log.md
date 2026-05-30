# Log

追記専用の操作ログ。新しいエントリを**末尾に**追加し、過去エントリは編集しません。
形式: `## [YYYY-MM-DD] <ingest|query|lint> | <タイトル>`

抽出例: `grep "^## \[" wiki/log.md | tail -5`

---

## [2026-05-24] init | リポジトリ初期化
- LLM wiki パターンの雛形を作成(raw/ と wiki/ の構造、CLAUDE.md スキーマ)。
- 最初のソースを `raw/` に追加して `ingest` から運用開始する。

## [2026-05-30] ingest | Strands Agents ドキュメント 14ページ(multi-agent / agent / tools / plugins / evals)
- 取得・保存: strandsagents.com の推奨14 URL を WebFetch ではなく HTML→Markdown 変換で `raw/articles/strands-*.md` に原本保存(Astro/Starlight サイトのため `.sl-markdown-content` を抽出)。
- 追加したページ(18件):
  - entities: [[strands-agents]](ハブ), [[model-context-protocol]], [[strands-agents-evals]]
  - concepts: [[agent-loop]], [[structured-output]], [[state-management]], [[conversation-management]], [[custom-tools]], [[mcp-tools]], [[plugins]], [[agent-skills]], [[graph-multi-agent]], [[swarm-multi-agent]], [[evaluators]], [[experiment-management]]
  - syntheses: [[multi-agent-patterns]], [[graph-swarm-hybrid]]
- 主な学び:
  - マルチエージェント選定の判断軸は「実行経路の決まり方」。Graph(決定論・条件付きエッジ・サイクル)/ Swarm(自律 handoff)/ Workflow。Graph ノードに Swarm をネスト可能=ハイブリッド構成の根拠([[graph-swarm-hybrid]])。
  - SDK 差異が地雷: Python は OR セマンティクス+バッチ実行/状態蓄積、TS は AND セマンティクス+個別起動/ステートレス。timeout はネスト orchestrator に伝播しない。
  - 状態は3層(conversation history / agent state / invocation state)。conversation manager 既定は sliding window、大量 context は Summarizing + proactive compression を検討。
  - structured output は複数 Pydantic スキーマを per-invocation 上書きで運用可。
  - Skills は progressive disclosure(metadata を system prompt 注入 → tool 有効化で本文ロード)。
- 矛盾・要確認:
  - 既知の矛盾なし。各ページに Python/TS の挙動差を「SDK 差異」節として併記済み。
  - Workflow の独立ページは今回の14 URL に含まれないため未収録(必要なら追加 ingest 提案)。
  - 推奨リストにあった `hooks` / `session-management` / `snapshots` / `steering` / `context-offloader` は参照のみ(未 ingest)。

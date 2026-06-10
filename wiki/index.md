# Wiki Index

このファイルは全ページのカタログです。`ingest` / `query` のたびに LLM が更新します。
各行は `- [[page-name]] — 1行サマリ (updated: YYYY-MM-DD)` の形式。

## Entities
<!-- 人物・製品・組織・ツール・論文など。 -->
- [[strands-agents]] — モデル駆動で AI エージェントを構築する SDK(Python/TS)。本テーマのハブ (updated: 2026-05-30)
- [[model-context-protocol]] — LLM へのコンテキスト提供を標準化するオープンプロトコル(MCP) (updated: 2026-05-30)
- [[strands-agents-evals]] — エージェント評価フレームワーク `strands-agents-evals`(Experiment/Case/evaluator) (updated: 2026-05-30)
- [[argo-cd]] — Kubernetes 上の CNCF GitOps デリバリツール(repo server / application controller / API server) (updated: 2026-06-04)
- [[addy-osmani]] — agentic development を論じるブロガー/エンジニア。[[loop-engineering]] の著者ハブ (updated: 2026-06-10)

## Concepts
<!-- 抽象的な概念・手法・パターン。 -->
- [[agent-loop]] — 推論↔ツール実行のサイクルを管理する Strands の最基礎プリミティブ (updated: 2026-05-30)
- [[structured-output]] — Pydantic/Zod スキーマで型安全な LLM 出力を得る(`structured_output_model`) (updated: 2026-05-30)
- [[state-management]] — conversation history / agent state / invocation state の3層状態管理 (updated: 2026-05-30)
- [[conversation-management]] — Null/SlidingWindow/Summarizing と proactive compression による context 管理 (updated: 2026-05-30)
- [[custom-tools]] — `@tool` デコレータ・クラス/モジュール形式・ToolContext によるツール作成 (updated: 2026-05-30)
- [[mcp-tools]] — MCPClient で MCP サーバのツールを利用(トランスポート/フィルタ/elicitation) (updated: 2026-05-30)
- [[plugins]] — hooks/tools でエージェント挙動を拡張する `plugins=[...]` の仕組み (updated: 2026-05-30)
- [[agent-skills]] — progressive disclosure でオンデマンドに指示をロードする AgentSkills/SKILL.md (updated: 2026-05-30)
- [[graph-multi-agent]] — 決定論的な有向グラフ型オーケストレーション(GraphBuilder/条件付きエッジ) (updated: 2026-05-30)
- [[swarm-multi-agent]] — 自律 handoff で協調する Swarm パターン (updated: 2026-05-30)
- [[evaluators]] — Output/Trajectory/Interactions 等の評価器と選定指針 (updated: 2026-05-30)
- [[experiment-management]] — Case/Experiment の整理・結合・版管理 (updated: 2026-05-30)
- [[ai-code-review]] — レビューは「説明できる著者」を前提とし、agentic development がその前提を壊す(diff が語らない文脈/説明可能性を前提条件に) (updated: 2026-06-03)
- [[gitops]] — git を desired state の真実源とする宣言的デリバリ運用(Argo CD/Flux/Spinnaker) (updated: 2026-06-04)
- [[argo-cd-controller-scaling]] — Argo CD を10,000アプリ規模で回す設定: client QPS とシャーディングが最も効く(AWS/EKS 6実験) (updated: 2026-06-04)
- [[loop-engineering]] — prompt する自分をループ設計に置き換える。Automations/Worktrees/Skills/Connectors/Sub-agents+memory(Codex⇔Claude Code 対応) (updated: 2026-06-10)

## Syntheses
<!-- 横断的な比較・分析・まとめ。 -->
- [[multi-agent-patterns]] — Graph/Swarm/Workflow の比較と「実行経路の決まり方」による使い分け (updated: 2026-05-30)
- [[graph-swarm-hybrid]] — Graph ノードに Swarm をネストするハイブリッド構成の設計と地雷 (updated: 2026-05-30)

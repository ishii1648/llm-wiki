---
title: Multi-Agent Patterns — Graph / Swarm / Workflow の使い分け
type: synthesis
aliases: [multi-agent patterns, マルチエージェントパターン, when to use each pattern]
tags: [strands, multi-agent, comparison, graph, swarm, workflow]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-multi-agent-patterns.mdx
related:
  - "[[graph-multi-agent]]"
  - "[[swarm-multi-agent]]"
  - "[[graph-swarm-hybrid]]"
  - "[[strands-agents]]"
  - "[[state-management]]"
---

## 概要
Strands でマルチエージェント/複雑なツールチェーンを構築する3つの主要パターン **Graph / Swarm / Workflow** の比較と選定指針。最大の判断軸は **「実行経路(path of execution)がどう決まるか」**。Graph と Swarm は SDK 組み込みのオーケストレータ、Workflow はコードで agent を連鎖させて実装するパターン(Python では `strands-agents-tools` の `workflow` ツールが既製)。

## 詳細

### マルチエージェントシステムの3原則
- **Orchestration**: agent 間の情報・タスクの流れを管理する制御構造。
- **Specialization**: 各 agent が特定の役割・専門・ツールを持つ。
- **Collaboration**: agent が通信・情報共有して互いの作業を発展させる。

### 共通点
- いずれも複雑問題の解決を目的とする。
- 最小行動単位は単一の Strands `Agent`。
- コンポーネント間で情報を受け渡して最終解へ向かう。

### 違い(比較表)
| 項目 | Graph | Swarm | Workflow |
|---|---|---|---|
| コア概念 | 開発者定義のフローチャート。agent が経路を判断 | 自律的に handoff する協調チーム | 単一ツールとして実行される事前定義 Task Graph(DAG) |
| 構造 | 全 node/edge を事前定義 | agent プールを与え、agent 自身が経路を決める | 全 task と依存をコードで定義 |
| 実行フロー | 制御されつつ動的(edge に沿うが各 node で LLM が判断) | 逐次・自律(最適な peer へ handoff) | 決定論的・並列(依存グラフ固定、独立 task は並列) |
| サイクル | 可 | 可 | 不可 |
| 状態共有 | 共有 state オブジェクトを全 agent が読み書き | 共有 context / working memory | ツールが task 出力を自動で次へ受け渡し |
| 会話履歴 | 全 transcript を共有 | 共有 transcript(handoff/知識履歴) | task 固有(依存結果の要約のみ) |
| エラー処理 | 明示的な error edge を定義可 | agent 駆動(error 専門へ handoff、timeout/handoff 上限で暴走防止) | systemic(1 task 失敗で下流停止、`Failed`) |

### いつ使うか
- **[[graph-multi-agent]](Graph)**: 条件分岐・ループを伴う**構造化された決定論的フロー**が要る時。ビジネスプロセスや「次ステップが現ステップの結果で決まる」タスク。例: 意図によるカスタマーサポートのルーティング、検証結果で error node へ分岐するデータ検証。
- **[[swarm-multi-agent]](Swarm)**: 問題を**異なる専門視点が有益なサブタスク**に分解できる時。探索・ブレスト・複数ソースの統合を、協調 handoff で行う。例: 多分野インシデント対応(monitoring→network→database)、ソフト開発(researcher→architect→coder→review、経路は創発的)。
- **Workflow**: 複雑だが**反復可能なプロセス**を単一の信頼できる再利用ツールにカプセル化したい時。例: 自動データパイプライン(独立な分析を並列実行)、標準業務プロセス(オンボーディング)。

### パターン横断の共有状態(Shared State)
Graph と Swarm はともに `invocation_state`(TS: `invocationState`)で全 agent に共有状態を渡せる。**LLM に晒さずに** context/設定を共有するための仕組み(→ [[state-management]])。
- 伝播先: 全 agent の `**kwargs` / `@tool(context=True)` の `ToolContext` / tool 関連 hooks。
- `MultiAgentState`(orchestrator):`results`(全 NodeResult)/ `nodes`(node 単位状態)/ `steps` / `app`(custom 用 StateStore)。
- **使い分け**: shared state = prompt に出さない context/設定。各パターン固有のデータフロー(swarm の shared context、graph の agent 入力)= LLM に推論させたいデータ。

> 💡 Graph と Swarm は **排他ではない**。Graph のノードに Swarm を入れる「ハイブリッド構成」が可能で、構造的な制御(Graph)と創発的協調(Swarm)を組み合わせられる。詳細は [[graph-swarm-hybrid]]。

## 出典
- `raw/articles/strands-multi-agent-patterns.mdx` — 3原則、共通点、比較表、各パターンの使用判断と例、shared state(`invocation_state` / `MultiAgentState`)。

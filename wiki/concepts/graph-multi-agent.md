---
title: Graph Multi-Agent Pattern
type: concept
aliases: [Graph, GraphBuilder, graph pattern, グラフパターン]
tags: [strands, multi-agent, graph, orchestration]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-graph.mdx
related:
  - "[[multi-agent-patterns]]"
  - "[[swarm-multi-agent]]"
  - "[[graph-swarm-hybrid]]"
  - "[[strands-agents]]"
  - "[[state-management]]"
---

## 概要
**Graph** は、agent・custom node・他のマルチエージェントシステム(Swarm やネストした Graph)を**ノード**とする決定論的な有向グラフ型オーケストレーション。ノードはエッジ依存に従って実行され、出力が接続先ノードへ入力として渡る。非循環(DAG)も循環(フィードバックループ)も表現できる。使い分けは [[multi-agent-patterns]]。

## 詳細

### 主要コンポーネント(Python)
- **`GraphNode`**: `node_id` / `executor`(Agent・A2AAgent・MultiAgentBase)/ `dependencies` / `execution_status`(PENDING/EXECUTING/COMPLETED/FAILED)/ `result` / `execution_time`。
- **`GraphEdge`**: `from_node` / `to_node` / `condition`(任意の判定関数)。
- **`GraphBuilder`**: `add_node()` / `add_edge()` / `set_entry_point()` / `set_max_node_executions()` / `set_execution_timeout()` / `set_node_timeout()` / `reset_on_revisit()` / `build()`。

```python
from strands.multiagent import GraphBuilder
builder = GraphBuilder()
builder.add_node(researcher, "research")
builder.add_node(analyst, "analysis")
builder.add_edge("research", "analysis")
builder.set_entry_point("research")          # 省略時は入次数0ノードを自動検出
builder.set_execution_timeout(600)
graph = builder.build()
result = graph("...")                          # await graph.invoke_async(...) も可
```

### Conditional Edges(条件付きエッジ)
エッジに `condition`(state を受け bool を返す関数)を付け、動的ワークフローを作る。
```python
def only_if_research_successful(state):
    node = state.results.get("research")
    return bool(node) and "successful" in str(node.result).lower()
builder.add_edge("research", "analysis", condition=only_if_research_successful)
```
- **全依存の完了待ち(AND 条件)**: `state.results[id].status == Status.COMPLETED` を全 required node について確認する factory 関数で表現(`GraphState` / `Status` を使用)。

### 実行制御(サイクル安全装置)
- `set_max_node_executions(N)`(TS: `maxSteps`): 総ノード実行回数の上限。
- `set_execution_timeout(sec)`(TS: `timeout` ms): 全体の wall-clock 上限。
- `set_node_timeout` / per-node `timeout`(TS): ノード単位の上限。
- `reset_on_revisit(True)`: 再訪時にノード状態をリセット。
- `maxSteps` も `timeout` も未設定だと、循環グラフが無限実行しうるため構築時に一度だけ警告。timeout は `AbortSignal` による協調的なもの。

### ネストとリモート
- **ネスト**: Graph や [[swarm-multi-agent]](Swarm)をノードにできる(→ [[graph-swarm-hybrid]])。`builder.add_node(research_swarm, "research_team")` のように追加。
- **リモート agent**: `A2AAgent`(endpoint 指定)をローカル agent と同様にノード化でき、分散アーキテクチャを構成できる。

### Custom Node Types
`MultiAgentBase` を継承(TS は `Node` を継承し `handle` 実装)して決定論的ロジックをノード化。LLM 呼び出しを省いた business rule・データ処理パイプラインなどハイブリッドワークフローを作れる。

### 入力伝播 / 共有状態 / 結果
- **入力伝播**: entry point は元タスクを受け取り、依存ノードは「元タスク + 完了した依存ノードの結果」を結合した入力を受ける。
- **共有状態**: `invocation_state` で全 agent に context/設定を渡せる(LLM に晒さない。→ [[state-management]] / [[multi-agent-patterns]])。
- **`GraphResult`**: `status` / `execution_order` / `results[node_id].result` / `total_nodes` / `completed_nodes` / `failed_nodes` / `execution_time` / `accumulated_usage`。
- ストリーミング: `graph.stream_async(...)` で `multiagent_node_start` / `_stream` / `_stop` / `multiagent_result` 等のイベントを取得。
- **Graph as a Tool**: `from strands_tools import graph` を agent に渡すと、agent が動的に Graph を組んで実行できる。

### 代表的トポロジ
Sequential Pipeline / Parallel Processing + Aggregation / Branching Logic(分類器 + 条件エッジ)/ Feedback Loop(reviewer→draft_writer の循環 + `set_max_node_executions` で無限ループ防止)。

### SDK 差異(地雷)
- **依存解決**: Python は **OR セマンティクス**(完了バッチ中いずれか1エッジが満たされれば発火)、TS は **AND セマンティクス**(全入力エッジ完了で発火。join/diamond で直感的)。
- **スケジューリング**: Python は離散バッチ実行(バッチ完了待ち)、TS は ready 次第個別起動(`maxConcurrency` まで)。
- **ノード状態**: Python は既定で実行をまたいで状態蓄積(`reset_on_revisit` で無効化)、TS は既定でステートレス(`preserveContext: true` で蓄積)。
- **エラー処理**: Python はノード失敗が例外(fail-fast)・orchestrator 上限違反が FAILED 結果、TS はその逆。
- **キャンセル**: TS は CANCELLED、Python は FAILED。

## 出典
- `raw/articles/strands-graph.mdx` — コンポーネント、`GraphBuilder` API、条件付きエッジ、実行制御、ネスト/A2A、custom node、入力伝播、`GraphResult`、トポロジ、SDK 差異。

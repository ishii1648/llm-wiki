---
title: Graph + Swarm ハイブリッド構成
type: synthesis
aliases: [graph swarm hybrid, nested multi-agent, swarm as graph node]
tags: [strands, multi-agent, graph, swarm, nesting, architecture]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-graph.md
  - raw/articles/strands-swarm.md
  - raw/articles/strands-multi-agent-patterns.md
related:
  - "[[graph-multi-agent]]"
  - "[[swarm-multi-agent]]"
  - "[[multi-agent-patterns]]"
  - "[[state-management]]"
---

## 概要
[[graph-multi-agent]](Graph)と [[swarm-multi-agent]](Swarm)は排他ではなく、**Graph のノードとして Swarm(または別の Graph)をネストできる**。これにより「構造的・決定論的な制御(Graph)」と「自律的・創発的な協調(Swarm)」を1つのシステムに組み合わせられる。本ページは [[multi-agent-patterns]] の選定指針を、ハイブリッド構成の観点から横断的に整理する。

## 詳細

### なぜネストするのか
- Graph は経路を開発者が定義し、条件分岐・error edge・ループで**決定論的に制御**できるが、各段の内部探索は固定的。
- Swarm は専門 agent が**自律 handoff** して創発的に協調するが、全体の経路は制御しにくい。
- → 全体フローは Graph で骨格を組み、**探索・ブレスト・多視点統合が要る一部の段だけ Swarm に委ねる**のがハイブリッドの勘所。

### 構成方法(Python)
`Swarm` インスタンスをそのまま `builder.add_node(...)` に渡す。SDK が自動で `MultiAgentNode`(TS)/ MultiAgentBase ノードとして扱う。

```python
from strands import Agent
from strands.multiagent import GraphBuilder, Swarm

research_agents = [
    Agent(name="medical_researcher",    system_prompt="..."),
    Agent(name="technology_researcher", system_prompt="..."),
    Agent(name="economic_researcher",   system_prompt="..."),
]
research_swarm = Swarm(research_agents)            # 創発的な調査チーム
analyst = Agent(system_prompt="Analyze the provided research.")

builder = GraphBuilder()
builder.add_node(research_swarm, "research_team")  # Swarm を1ノードとして埋め込む
builder.add_node(analyst, "analysis")
builder.add_edge("research_team", "analysis")      # 決定論的な後段
graph = builder.build()
result = graph("Research the impact of AI on healthcare and create a report")
```

典型形: `research_team(Swarm)` → `analysis(Agent)` → ... のように、Swarm の出力を Graph の後続ノードへ決定論的に流す。

### 設計上の注意(SDK 差異・地雷)
- **timeout はネストへ伝播しない**(TS): Graph の `timeout` は `MultiAgentNode` でラップされたネスト Swarm/Graph には伝わらず、**ネスト側は自前の timeout 設定で動く**。ハイブリッドでは内側 Swarm にも `execution_timeout`/`node_timeout`(または TS の `timeout`)を必ず設定する。
- **`nodeTimeout` は MultiAgentNode に適用されない**(TS)。ネスト orchestrator の時間制御は内側で行う。
- **依存解決/スケジューリングの差**: Python は OR セマンティクス + バッチ実行、TS は AND セマンティクス + 個別起動。join/diamond 形(複数 Swarm の結果を1ノードで集約)を作る際はこの差を踏まえる(→ [[graph-multi-agent]] の SDK 差異)。
- **ノード状態のリセット**: 同一ノードを再訪する反復ワークフローでは、Python の状態蓄積 / TS の `preserveContext` の挙動を意識する。

### 共有状態の一貫性
Graph と Swarm はともに `invocation_state`(TS: `invocationState`)を受け取り、ネスト境界を越えて全 agent に伝播する。**同じ `shared_state` を Graph 起動時に渡せば、内側 Swarm の各 agent や `@tool(context=True)` のツールからも参照できる**(→ [[state-management]])。LLM に晒さない context/設定(user_id・session_id・DB 接続など)はここに置く。

```python
shared_state = {"user_id": "user123", "session_id": "sess456", "debug_mode": True}
result = graph("Analyze customer data", invocation_state=shared_state)
```

### 選定の早見
- 全体に**分岐・ループ・error 経路**が要る → 骨格は [[graph-multi-agent]]。
- ある段が**多視点の探索/協調**を要する → その段を [[swarm-multi-agent]] にしてノード化。
- 反復可能で固定的な決定論パイプライン全体 → Workflow も候補(→ [[multi-agent-patterns]])。

## 出典
- `raw/articles/strands-graph.md` — 「Nested Multi-Agent Patterns」(Graph/Swarm をノードにする)、Graph 構成・`GraphResult`・SDK 差異、timeout がネストへ伝播しない仕様。
- `raw/articles/strands-swarm.md` — Swarm の作成・handoff・安全機構(ネスト側 timeout 設定の根拠)。
- `raw/articles/strands-multi-agent-patterns.md` — パターン選定指針、`invocation_state` による横断共有状態。

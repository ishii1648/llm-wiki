---
title: Swarm Multi-Agent Pattern
type: concept
aliases: [Swarm, swarm pattern, スウォーム, handoff]
tags: [strands, multi-agent, swarm, orchestration, handoff]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-swarm.mdx
related:
  - "[[multi-agent-patterns]]"
  - "[[graph-multi-agent]]"
  - "[[graph-swarm-hybrid]]"
  - "[[strands-agents]]"
  - "[[structured-output]]"
  - "[[state-management]]"
---

## 概要
**Swarm** は、複数の agent がチームとして協調し複雑タスクを解く協調型オーケストレーション。逐次・階層型と違い、**共有 context と working memory を持つ agent 同士が自律的に handoff(制御移譲)**して調整する。創発的知性(emergent intelligence)が原理。使い分けは [[multi-agent-patterns]]。

## 詳細

### 動作原理
各 agent は (1) タスク全体の context にアクセスでき、(2) どの agent が作業したか履歴を見られ、(3) 他 agent が貢献した知識を参照でき、(4) 別の専門 agent に handoff するか自分で判断する。中央制御なしで協調する。

### Swarm の作成(Python)
専門の異なる agent 群を渡す。既定では最初の agent が初期要求を受けるが、`entry_point` で指定可。
```python
from strands.multiagent import Swarm
swarm = Swarm(
    [coder, researcher, reviewer, architect],
    entry_point=researcher,
    max_handoffs=20,
    max_iterations=20,
    execution_timeout=900.0,   # 15分
    node_timeout=300.0,        # agent あたり5分
    repetitive_handoff_detection_window=8,
    repetitive_handoff_min_unique_agents=3,
)
result = swarm("Design and implement a simple REST API for a todo app")
```

### Swarm Configuration(Python)
| パラメータ | 説明 | 既定 |
|---|---|---|
| `entry_point` | 開始 agent | None(最初の agent) |
| `max_handoffs` | handoff 上限 | 20 |
| `max_iterations` | 全 agent の総反復上限 | 20 |
| `execution_timeout` | 総実行 timeout(秒) | 900.0 |
| `node_timeout` | agent 個別 timeout(秒) | 300.0 |
| `repetitive_handoff_detection_window` | ping-pong 検出窓 | 0(無効) |
| `repetitive_handoff_min_unique_agents` | 窓内に必要な最小 unique agent 数 | 0(無効) |

### Swarm Coordination
- **Handoff Tool**(Python): 各 agent に自動装備される `handoff_to_agent(agent_name, message, context)` で別 agent へ制御移譲。
- **Shared Context**: 元タスク記述・作業した agent 履歴・前 agent の知識・協調可能な agent 一覧を全員が参照。受信 agent には整形された context 文字列が渡る。
- **Structured Output Routing**: agent は [[structured-output]] で次ステップを決める。応答に `agentId`(移譲先。省略で swarm 終了し最終応答)、`message`(次 agent への指示 or 最終応答)、`context`(任意データ)を含む。agent description が routing 判断を助ける。

### Shared State / 結果 / ストリーミング
- **Shared State**: `invocation_state` で全 agent に context/設定を共有(協調用 shared context とは別。LLM に晒さない。→ [[state-management]] / [[multi-agent-patterns]])。
- **SwarmResult**: `status` / `node_history` / `results[id].result` / `execution_count` / `execution_time` / `accumulated_usage`。
- ストリーミング: `swarm.stream_async(...)` で `multiagent_node_start` / `multiagent_handoff` / `multiagent_result` 等。
- **Swarm as a Tool**: `from strands_tools import swarm` を agent に渡すと動的に swarm を組成・実行できる。

### 安全機構 / ベストプラクティス
- 安全機構: step 上限 / execution timeout / node timeout / **repetitive handoff detection**(ping-pong 防止)。
- ベストプラクティス: 専門特化 agent を作る・説明的な名前・適切な timeout・handoff 検出有効化・多様な専門性・agent description 付与・multi-modal 入力(ContentBlock)活用。

### SDK 差異(地雷)
- **Handoff 機構**: Python は `handoff_to_agent` ツール注入。TS は structured output schema(`{agentId, message, context}`)で表現し、`agentId` 有=移譲、無=`message` が最終応答。
- **Shared context**: Python は可変 `SharedContext`(各 agent が読み書き)。TS は handoff 入力に JSON テキストブロックとして直列化(cross-agent の可変状態を避ける)。
- **Step 上限**: Python は `max_handoffs` と `max_iterations` を分離、TS は単一 `maxSteps`。
- **Node 入力**: Python はリッチな context 文字列、TS は handoff message + 直列化 context のみ。
- **エラー/キャンセル**: [[graph-multi-agent]] と同様の Python/TS 差(TS は CANCELLED、Python は FAILED)。

## 出典
- `raw/articles/strands-swarm.mdx` — 動作原理、`Swarm` 作成・設定表、handoff/shared context/structured output routing、shared state、`SwarmResult`、安全機構、ベストプラクティス、SDK 差異。

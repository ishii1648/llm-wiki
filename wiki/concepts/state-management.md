---
title: State Management
type: concept
aliases: [state management, 状態管理, agent state, invocation state]
tags: [strands, agent, state, messages, memory]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-state.mdx
related:
  - "[[strands-agents]]"
  - "[[agent-loop]]"
  - "[[conversation-management]]"
  - "[[custom-tools]]"
  - "[[multi-agent-patterns]]"
---

## 概要
Strands のエージェント状態は **3つの形**で保持される: (1) **Conversation History**(会話履歴)、(2) **Agent State**(会話 context 外で複数リクエストをまたいで保持する key-value)、(3) **Invocation State**(単一 invocation 内のコンテキスト情報)。多ターン対話やワークフローで context を維持するために理解が必須。

## 詳細

### 1. Conversation History(会話履歴)
エージェントの主要な context。`agent.messages` で全 user/assistant メッセージ(ツール呼び出し・結果含む)に直接アクセスできる。

```python
agent = Agent()
agent("Hello!")
print(agent.messages)   # これまでの全メッセージ
```

- **既存メッセージで初期化**: `Agent(messages=[...])` で会話を継続したり context を事前充填できる。**現状コードでの履歴注入(`messages=past_messages or None`)はこの仕組み**。
- 会話履歴は自動的に「呼び出し間で維持・各推論でモデルへ渡す・ツール実行 context に使用・context window 溢れを防ぐよう管理」される。管理戦略は [[conversation-management]]。
- **Direct Tool Calling**: `agent.tool.<name>(...)` の直接呼び出しは既定で履歴に記録される。`record_direct_tool_call=False` で記録を抑制できる(Python)。

### 2. Agent State(= app state)
会話 context の **外**にある key-value ストア。推論時にモデルへは渡されないが、ツールやアプリロジックから読み書きできる。

```python
agent = Agent(state={"user_preferences": {"theme": "dark"}, "session_count": 0})
agent.state.get("user_preferences")     # 取得
agent.state.set("last_action", "login") # 設定
agent.state.delete("last_action")       # 削除
```

- **JSON シリアライズ検証**: シリアライズ不能な値(関数等)を set すると `ValueError`。永続化・復元のため。
- ツール内では `@tool(context=True)` + `tool_context.agent.state` でアクセス。ツール実行をまたいだ情報維持に有用。

### 3. Invocation State
各 invocation ごとの辞書。event loop の反復をまたいで持続するが、**モデル context には含まれない**。

- Python: `invocation_state` / `request_state`(callback handler の `kwargs["request_state"]`)。TS: `invocationState`(`invoke()` の第2引数オプション)。
- 省略時は `{}` で初期化。hooks やツールから参照でき、変更は後続の hooks/tools/最終結果に反映。`AgentResult`(Python: `result.state`、TS: `result.invocationState`)で返る。
- **マルチエージェントでの共有**: [[graph-multi-agent]] / [[swarm-multi-agent]] では `invocation_state` が全 agent に伝播し、LLM に晒さずに context/設定を共有する手段になる(→ [[multi-agent-patterns]])。

### セッション横断の永続化
アプリ再起動をまたぐ自動永続化は Session Management、手動の point-in-time 取得・復元は Snapshots(いずれも本 ingest 範囲外、参照のみ)。

## 出典
- `raw/articles/strands-state.mdx` — 3種の状態(conversation history / agent state / invocation state)、`agent.messages` 初期化、direct tool calling、state 検証、ツール内アクセス、invocation state の性質。

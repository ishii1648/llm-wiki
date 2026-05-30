---
title: Plugins
type: concept
aliases: [plugins, プラグイン, Plugin]
tags: [strands, plugins, hooks, extensibility]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-plugins.md
related:
  - "[[strands-agents]]"
  - "[[agent-skills]]"
  - "[[state-management]]"
  - "[[agent-loop]]"
---

## 概要
**Plugins(プラグイン)** は、エージェントの典型的な挙動を変更する仕組み。[[agent-skills]](Skills)、steering、その他の挙動変更を agentic loop に導入できる。Agent クラスが公開する低レベルプリミティブ(`model` / `system_prompt` / `messages` / `tools` / `hooks`)を活用してロジックを実行する。

## 詳細

### 組み込みプラグイン
- **[[agent-skills]](Skills)** — 実行時に発見・有効化されるオンデマンドの modular instruction([Agent Skills 仕様](https://agentskills.io/specification)準拠)。
- **Steering** — 複雑なタスク向けの context-aware な modular プロンプティング。
- **Context Offloader** — 巨大なツール結果を先回りでストレージへ退避し、preview と取得ツールに置換([[conversation-management]] の補完)。

### 使い方
`Agent(plugins=[...])` で初期化時に渡す。
```python
from strands.vended_plugins.steering import LLMSteeringHandler
agent = Agent(tools=[my_tool],
              plugins=[LLMSteeringHandler(system_prompt="Guide the agent...")])
```

### 構造と仕組み
プラグインは `Plugin` 基底クラスを継承し `name` を定義するクラス。アタッチ時に以下が起きる(Python):
1. **Discovery**: `@hook` / `@tool` で装飾されたメソッドを走査。
2. **Hook Registration**: 各 `@hook` メソッドを、型ヒントから推論したイベント種別で hook registry に登録。
3. **Tool Registration**: 各 `@tool` メソッドを agent の tools へ追加。
4. **Initialization**: `init_agent(agent)` を呼ぶ。

TS は `@hook`/`@tool` デコレータを使わず、`getTools()` でツールを返し、`initAgent()` 内で `agent.addHook()` により手動登録する。

### `@hook` デコレータ
メソッドを hook コールバックにする。イベント種別は型ヒントから自動推論(`BeforeModelCallEvent` 等)。union 型で複数イベントを1メソッドで扱える。手動登録(`init_agent` 内で `agent.add_hook(cb, EventType)`)も可能。

### プラグイン状態の管理
プラグインは invocation をまたいで状態を保持できる。シリアライズ/共有が要る状態は [[state-management]] の **Agent State** を使う(`agent.state.set/get`)。

### Async 初期化
`async def init_agent(self, agent)` / `async initAgent()` で非同期初期化(設定の遅延ロード等)が可能。

## 出典
- `raw/articles/strands-plugins.md` — プラグインの定義(`model`/`system_prompt`/`messages`/`tools`/`hooks` の活用)、組み込みプラグイン、`plugins=[...]`、構造・discovery・hook 登録、状態管理、async 初期化。

---
title: Strands Agents SDK
type: entity
aliases: [Strands, Strands Agents, strands-agents, Strands Agents SDK]
tags: [strands, agent, sdk, framework, multi-agent]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-agent-loop.md
  - raw/articles/strands-plugins.md
related:
  - "[[agent-loop]]"
  - "[[custom-tools]]"
  - "[[mcp-tools]]"
  - "[[structured-output]]"
  - "[[state-management]]"
  - "[[conversation-management]]"
  - "[[plugins]]"
  - "[[agent-skills]]"
  - "[[multi-agent-patterns]]"
  - "[[strands-agents-evals]]"
---

## 概要
**Strands Agents SDK** は、少ないコード量で「モデル駆動(model-driven)」の AI エージェントを構築するためのフレームワーク。Python と TypeScript の両 SDK が提供され、コア実行プリミティブである [[agent-loop]](agent loop)の上に、ツール・マルチエージェント・プラグインなどの高位パターンが積み上がる構造になっている。

## 詳細

### 設計の中心: Agent Loop
すべての基盤は [[agent-loop]] である。「モデルを呼ぶ → ツールを使いたいか判定 → 使うなら実行 → 結果を添えて再びモデルを呼ぶ」を、最終応答が出るまで繰り返す。各反復で会話履歴(context)が蓄積されることが、多段推論を可能にする原動力。出典: `raw/articles/strands-agent-loop.md`。

### Agent クラスが公開する低レベルプリミティブ
[[plugins]] の説明によれば、`Agent` クラスは以下のプリミティブを公開し、これらを操作することでエージェントの挙動を拡張する:

- `model` — 使用するモデルプロバイダ
- `system_prompt` — システムプロンプト
- `messages` — 会話履歴(→ [[state-management]])
- `tools` — 利用可能なツール群(→ [[custom-tools]] / [[mcp-tools]])
- `hooks` — ライフサイクルイベントのフック

出典: `raw/articles/strands-plugins.md`。

### 主要な構成要素(本 wiki の地図)

| 領域 | ページ |
|---|---|
| 実行基盤 | [[agent-loop]] |
| 型安全な出力 | [[structured-output]] |
| 状態管理 | [[state-management]] / [[conversation-management]] |
| ツール作成 | [[custom-tools]] |
| 外部ツール連携 | [[mcp-tools]]([[model-context-protocol]]) |
| 挙動拡張 | [[plugins]] / [[agent-skills]] |
| マルチエージェント | [[multi-agent-patterns]] / [[graph-multi-agent]] / [[swarm-multi-agent]] / [[graph-swarm-hybrid]] |
| 評価 | [[strands-agents-evals]] / [[evaluators]] / [[experiment-management]] |

### Python と TypeScript の差異
SDK は2言語で提供されるが、コア概念は共通でも挙動差がある(例: マルチエージェントの依存解決セマンティクス、conversation manager の `per_turn`、MCP の tool フィルタなど)。各ページの「SDK 差異」節を参照。

## 出典
- `raw/articles/strands-agent-loop.md` — agent loop が「Strands の基盤概念であり、他のすべてがこの上に構築される」と明記。
- `raw/articles/strands-plugins.md` — Agent クラスが公開するプリミティブ(`model`/`system_prompt`/`messages`/`tools`/`hooks`)の列挙。

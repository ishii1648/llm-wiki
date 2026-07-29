---
title: MCP Extensions(Apps / Tasks)
type: concept
aliases: [MCP Apps, MCP Tasks, extensions framework, MCP拡張フレームワーク]
tags: [mcp, protocol, extensions, ui, async]
created: 2026-07-29
updated: 2026-07-29
sources:
  - raw/articles/bringing-mcp-2026-07-28-to-claude.md
related:
  - "[[mcp-2026-07-28]]"
  - "[[model-context-protocol]]"
---

## 概要
**MCP extensions framework** は、[[model-context-protocol]] のコアプロトコルを変更せずに能力を追加するための versioned な公式拡張の枠組み。[[mcp-2026-07-28]] で **MCP Apps**(対話的 UI)と **Tasks**(長時間処理)が正式な拡張として昇格(graduate)した。

## 詳細

### フレームワークの意義
拡張はコアと独立にバージョン管理され、開発者は「対話的 UI」や「長時間実行の処理」のような能力を、コアプロトコルの変更を待たずに追加できる。コアを stateless に保ったまま([[mcp-2026-07-28]] の stateless core)、リッチな機能を階層化するアーキテクチャ上の分離でもある。

### MCP Apps
- MCP サーバが**会話の中に対話的 UI を直接レンダリング**できる拡張。
- Claude では、ユーザーが connector の動作を可視化し、タブを切り替えずにインラインで操作できる形で提供されている。
- 仕様: modelcontextprotocol.io/extensions/apps/overview

### Tasks
- **長時間実行の処理(long-running work)** をコアプロトコル変更なしに扱うための拡張。
- 仕様: modelcontextprotocol.io/extensions/tasks/overview
- (推測)stateless な request/response コアでは処理の継続状態をコネクションに持てないため、長時間処理を第一級で表現する Tasks 拡張が対になっていると考えられる。

## 出典
- `raw/articles/bringing-mcp-2026-07-28-to-claude.md` — 「MCP Apps and Tasks now ship under a versioned extensions framework, giving developers a formal path to add capabilities like interactive UIs and long-running work without changing the core protocol」、Claude における MCP Apps の説明。

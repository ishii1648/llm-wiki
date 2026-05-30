---
title: Model Context Protocol (MCP)
type: entity
aliases: [MCP, Model Context Protocol, model-context-protocol]
tags: [strands, mcp, tools, protocol, integration]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-mcp-tools.mdx
related:
  - "[[mcp-tools]]"
  - "[[strands-agents]]"
---

## 概要
**Model Context Protocol(MCP)** は、アプリケーションが大規模言語モデル(LLM)へコンテキストを提供する方法を標準化するオープンプロトコル。公式サイトは [modelcontextprotocol.io](https://modelcontextprotocol.io)。[[strands-agents]] は MCP と統合し、外部 MCP サーバが提供するツールでエージェント能力を拡張できる。

## 詳細
- MCP は、エージェントと「追加ツールを提供する MCP サーバ」の間の通信を可能にする。Strands は Python / TypeScript の双方で MCP サーバ接続の組み込みサポートを持つ。
- Strands における具体的な利用方法(`MCPClient`、トランスポート、複数サーバ、elicitation など)は [[mcp-tools]] に詳述。
- MCP には **elicitation**(サーバがツール呼び出しを一時停止し、ユーザへ追加入力を要求する)などの仕様が含まれる。詳細は [MCP specification](https://modelcontextprotocol.io/specification/draft/client/elicitation)。

> ℹ️ 注: 本 wiki の親リポジトリ環境(Claude Code)も `mcp__github__*` のような MCP ツールを利用するが、それは Strands SDK とは別文脈。ここで扱うのは Strands Agents から見た MCP 連携である。

## 出典
- `raw/articles/strands-mcp-tools.mdx` — 「MCP はアプリが LLM へコンテキストを提供する方法を標準化するオープンプロトコル」「Strands は MCP と統合し外部ツール/サービスで能力を拡張」と記載。

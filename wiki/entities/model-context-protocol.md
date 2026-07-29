---
title: Model Context Protocol (MCP)
type: entity
aliases: [MCP, Model Context Protocol, model-context-protocol]
tags: [strands, mcp, tools, protocol, integration]
created: 2026-05-30
updated: 2026-07-29
sources:
  - raw/articles/strands-mcp-tools.mdx
  - raw/articles/bringing-mcp-2026-07-28-to-claude.md
related:
  - "[[mcp-tools]]"
  - "[[strands-agents]]"
  - "[[project-headroom]]"
  - "[[mcp-2026-07-28]]"
  - "[[mcp-extensions]]"
---

## 概要
**Model Context Protocol(MCP)** は、アプリケーションが大規模言語モデル(LLM)へコンテキストを提供する方法を標準化するオープンプロトコル。公式サイトは [modelcontextprotocol.io](https://modelcontextprotocol.io)。[[strands-agents]] は MCP と統合し、外部 MCP サーバが提供するツールでエージェント能力を拡張できる。

## 詳細
- MCP は、エージェントと「追加ツールを提供する MCP サーバ」の間の通信を可能にする。Strands は Python / TypeScript の双方で MCP サーバ接続の組み込みサポートを持つ。
- Strands における具体的な利用方法(`MCPClient`、トランスポート、複数サーバ、elicitation など)は [[mcp-tools]] に詳述。
- MCP には **elicitation**(サーバがツール呼び出しを一時停止し、ユーザへ追加入力を要求する)などの仕様が含まれる。詳細は [MCP specification](https://modelcontextprotocol.io/specification/draft/client/elicitation)。

### スペックの進化と普及(2026-07 時点)
- 2026-07-28 に**第5版スペック [[mcp-2026-07-28]]** がリリース。プロトコルコアが双方向ステートフルから **stateless(request/response)** に移行し、認可は OAuth 2.0 / OIDC の本番運用に整合、MCP Apps / Tasks は versioned な [[mcp-extensions]] フレームワークへ正式昇格した。
- 月間 SDK ダウンロードは **400M 超(今年 4 倍増)** で、「AI エージェントをアプリケーションに接続する業界標準」になったと Anthropic は位置づけている。Claude の connectors directory には 950 超の MCP サーバが掲載。

> ℹ️ 注: 本 wiki の親リポジトリ環境(Claude Code)も `mcp__github__*` のような MCP ツールを利用するが、それは Strands SDK とは別文脈。ここで扱うのは Strands Agents から見た MCP 連携である。

> 📎 別用途: MCP は「ツール提供」以外にも使える。[[project-headroom]] の CCR は、圧縮で削った原文を必要時に取り出す **retrieval の経路**として MCP サーバーを用いる(→ [[context-compression]])。

## 出典
- `raw/articles/strands-mcp-tools.mdx` — 「MCP はアプリが LLM へコンテキストを提供する方法を標準化するオープンプロトコル」「Strands は MCP と統合し外部ツール/サービスで能力を拡張」と記載。
- `raw/articles/bringing-mcp-2026-07-28-to-claude.md` — 第5版スペック(stateless core / extensions / auth hardening)、400M 月間 SDK ダウンロード・4倍増・950+ connectors の数値。

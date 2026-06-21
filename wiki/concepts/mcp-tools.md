---
title: MCP Tools (Strands × MCP)
type: concept
aliases: [MCP tools, MCPClient, mcp-tools]
tags: [strands, tools, mcp, integration, transport]
created: 2026-05-30
updated: 2026-06-11
sources:
  - raw/articles/strands-mcp-tools.mdx
related:
  - "[[strands-agents]]"
  - "[[model-context-protocol]]"
  - "[[custom-tools]]"
  - "[[conversation-management]]"
  - "[[loop-engineering]]"
  - "[[project-headroom]]"
---

## 概要
[[model-context-protocol]](MCP)サーバが提供するツールを [[strands-agents]] から利用する方法。`MCPClient`(Python)/ `McpClient`(TS)で MCP サーバへ接続し、stdio・Streamable HTTP・SSE のトランスポートをサポートする。

## 詳細

### Quick Start と統合アプローチ(Python)
- **Managed Integration(推奨)**: `MCPClient` は `ToolProvider` を実装するので、`Agent(tools=[mcp_client])` のように直接渡すと**ライフサイクルが自動管理**される。
- **Manual Context Management**: セッション制御が要る場合は context manager(`with`)で:
  ```python
  with mcp_client:
      tools = mcp_client.list_tools_sync()
      agent = Agent(tools=tools)
      agent("What is AWS Lambda?")   # 必ず with ブロック内で実行
  ```

```python
from mcp import stdio_client, StdioServerParameters
from strands.tools.mcp import MCPClient

mcp_client = MCPClient(lambda: stdio_client(
    StdioServerParameters(command="uvx",
        args=["awslabs.aws-documentation-mcp-server@latest"])))
agent = Agent(tools=[mcp_client])
```

### トランスポート
- **stdio**: ローカルプロセス/CLI ツール(`stdio_client` + `StdioServerParameters`)。
- **Streamable HTTP**: `streamablehttp_client("http://localhost:8000/mcp")`。`headers={"Authorization": f"Bearer {token}"}` で認証可。AWS SigV4/IAM は `mcp-proxy-for-aws` の `aws_iam_streamablehttp_client` が便利。
- **SSE**: `sse_client("http://localhost:8000/sse")`。

### 複数 MCP サーバの同時利用
複数クライアントのツールを1 agent に統合できる。
```python
with sse_mcp_client, stdio_mcp_client:   # 手動: 明示的 context 管理
    tools = sse_mcp_client.list_tools_sync() + stdio_mcp_client.list_tools_sync()
    agent = Agent(tools=tools)
# managed:
agent = Agent(tools=[sse_mcp_client, stdio_mcp_client])
```

> ⚠️ 複数 MCP を `with` で開く際は例外時 cleanup に注意。Python のベストプラクティスは **常に context manager を使う**こと(下記 Troubleshooting 参照)。

### Client Configuration(Python のみ)
- **Tool Filtering**: `tool_filters={"allowed": [...], "rejected": [...]}`。文字列・`re.compile(...)` の正規表現を受け、`allowed` を先に適用してから `rejected`。多数ツールから必要分だけロードする推奨方式。
- **Tool Name Prefixing**: `prefix="aws_docs"` で `aws_docs_search_documentation` のように改名し、複数サーバ間の名前衝突を防ぐ。
- TS では tool filtering / prefixing は**未対応**(`applicationName`/`applicationVersion` メタデータのみ)。

### Direct Tool Invocation / 自作サーバ / Elicitation
- 直接呼び出し: `mcp_client.call_tool_sync(tool_use_id=..., name=..., arguments=...)`。
- 自作 MCP サーバ: Python は `FastMCP` + `@mcp.tool(...)`、TS は `McpServer` + `server.tool(...)`。
- **Elicitation**: サーバがツール呼び出しを一時停止しユーザ入力を要求する仕組み。`elicitation_callback` を client に設定して応答する。

### Troubleshooting(Python)
- **MCPClientInitializationError**: MCP 接続に依存するツールは `with` ブロック内で使う必要がある。ブロック外での操作は失敗。
- Connection Failures(サーバ稼働・ネットワーク・URL/command 確認)、Tool Discovery Issues(`list_tools` 実装確認)、Tool Execution Errors(引数 schema 一致確認)。

### context への影響
MCP ツールの出力は会話履歴に蓄積されトークンを消費する。大量の MCP context を扱う構成では [[conversation-management]] の明示制御(summarizing / proactive compression)を検討する。なお MCP ツール出力は「70%が冗長な JSON」とされ圧縮余地が大きい。[[project-headroom]] の CCR は逆に **MCP サーバーを原文 retrieval の経路として使う**(可逆圧縮、→ [[context-compression]])。

## 出典
- `raw/articles/strands-mcp-tools.mdx` — Quick Start、統合アプローチ、トランスポート、複数サーバ、tool フィルタ/prefix、direct invocation、自作サーバ、elicitation、troubleshooting。

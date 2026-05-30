---
title: Creating Custom Tools
type: concept
aliases: [custom tools, カスタムツール, tool decorator, "@tool"]
tags: [strands, tools, decorator, tool-context]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-custom-tools.md
related:
  - "[[strands-agents]]"
  - "[[agent-loop]]"
  - "[[state-management]]"
  - "[[mcp-tools]]"
  - "[[structured-output]]"
  - "[[multi-agent-patterns]]"
---

## 概要
**Custom Tools(カスタムツール)** の作成方法。Python は3アプローチ(`@tool` デコレータ関数 / クラスベース / モジュール形式)、TypeScript は2アプローチ(`tool()` 関数 + Zod/JSON schema / `FunctionTool` 継承クラス)を提供する。

## 詳細

### `@tool` デコレータ(Python の基本)
通常の関数にデコレータを付けるだけ。**docstring と type hint からツール仕様を自動生成**する。

```python
from strands import tool

@tool
def weather_forecast(city: str, days: int = 3) -> str:
    """Get weather forecast for a city.

    Args:
        city: The name of the city
        days: Number of days for the forecast
    """
    return f"Weather forecast for {city} for the next {days} days..."
```

- docstring の最初の段落 → ツールの description、`Args:` 節 → 各パラメータ説明。type hint と合わせて完全な仕様になる。
- **名前/説明/schema の上書き**: `@tool(name="get_weather", description="...")`、`@tool(inputSchema={...})` で上書き可能。
- ツール名は `^[a-zA-Z0-9_-]+$`・1–64 文字。違反すると assistant メッセージ上で `INVALID_TOOL_NAME` に置換される。
- 使い方: `Agent(tools=[weather_forecast])`。

### 返り値とレスポンス形式
既定では返り値が text 応答に整形される。より制御したい場合は `ToolResult` 構造の dict を返す:
```python
{"status": "success", "content": [{"json": data}]}   # または {"text": ...}
```
- `ToolResult` = `{toolUseId, status: "success"|"error", content: [...]}`。content ブロックは `text` か `json`。
- `@tool` は返り値を自動変換: 単純値 → `{"text": str(result)}`、正しい `ToolResult` dict → そのまま、例外 → error 応答。

### Async とストリーミング
- `async def` でツール定義可能。Strands は async ツールを**並行実行**する。
- ツールは中間結果を `yield` でき、各 yield が streaming event になる(最後の値が返り値)。進捗更新に有用。

### ToolContext
ツールから実行 context(呼び出し元 agent・現ツール使用データ・invocation state)へアクセスする手段。
- Python: `@tool(context=True)` + `tool_context: ToolContext` 引数(パラメータ名は `@tool(context="...")` で変更可)。
- TS: callback の第2引数 `context?: ToolContext`。
- `tool_context.agent` / `tool_context.tool_use["toolUseId"]` / `tool_context.invocation_state[...]` 等。

#### ツール内での状態アクセス(使い分け)
| 種類 | 用途 |
|---|---|
| **Tool Parameters** | LLM が推論して与えるべきデータ(検索クエリ、ファイルパス等) |
| **Invocation State**(`invocation_state` / `context.invocationState`) | prompt に出さないがツール挙動に効くリクエストスコープ情報(user_id, session_id)。invocation 限り。→ [[state-management]] |
| **Agent State**(`context.agent.appState`) | invocation をまたぐ永続 key-value(JSON シリアライズ可) |
| **クラスベースツール** | 初期化が要る不変設定(API キー、DB 接続) |

- マルチエージェントでは invocation_state 経由で全 agent に共有状態を渡せる(→ [[multi-agent-patterns]])。

### クラスベースツール
状態・リソースを共有したい時に有用。`@tool` をメソッドに付けると、インスタンスにバインドされ属性アクセス・状態維持ができる。DB 接続を複数ツールで共有する例など。

### モジュール形式ツール(Python のみ)
SDK 非依存のツールを作れる。`TOOL_SPEC` 変数(name/description/inputSchema)と、同名の実装関数の2要素で構成。`Agent(tools=[module])` または `Agent(tools=["./weather_forecast.py"])` で読み込む。async も可。

## 出典
- `raw/articles/strands-custom-tools.md` — `@tool` デコレータ、schema 上書き、返り値/`ToolResult`、async/streaming、`ToolContext`、状態の使い分け、クラスベース、モジュール形式の各例。

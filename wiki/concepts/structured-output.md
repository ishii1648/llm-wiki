---
title: Structured Output
type: concept
aliases: [structured output, 構造化出力, structured_output_model]
tags: [strands, agent, output, pydantic, validation]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-structured-output.md
related:
  - "[[strands-agents]]"
  - "[[agent-loop]]"
  - "[[custom-tools]]"
---

## 概要
**Structured Output(構造化出力)** は、スキーマ定義を使って LLM から型安全で検証済みのオブジェクトを得る仕組み。生テキストをパースする代わりに、Python では **Pydantic** モデル、TypeScript では **Zod** スキーマで構造を定義し、検証済みオブジェクトを受け取る。

## 詳細

### 基本的な使い方(Python)
Pydantic モデルを定義し、invocation 時に `structured_output_model` 引数で渡す。結果は `AgentResult.structured_output` から取得。

```python
from pydantic import BaseModel, Field
from strands import Agent

class PersonInfo(BaseModel):
    name: str = Field(description="Name of the person")
    age: int = Field(description="Age of the person")
    occupation: str = Field(description="Occupation of the person")

agent = Agent()
result = agent("John Smith is a 30 year-old software engineer",
               structured_output_model=PersonInfo)
person_info: PersonInfo = result.structured_output
```

TypeScript は `structuredOutputSchema`(Zod)を `Agent` 初期化時または invocation 時に渡し、`result.structuredOutput` で取得。

### 仕組みと利点
- スキーマ定義を **tool specification** に変換してモデルを誘導する。Strands がサポートする全モデルプロバイダで動作。
- 利点: 型安全 / 自動検証 / スキーマがドキュメントを兼ねる / IDE 補完 / 不正応答の早期検出。

### エラーハンドリング
検証失敗時は Python で `StructuredOutputException`(`strands.types.exceptions`)、TS で `StructuredOutputError` を送出。`field_validator`(Pydantic)や `.refine()`(Zod)を使うと、検証失敗を起点とした **自動リトライ** パターンも組める。

### 複数スキーマの運用(重要)
1つの `Agent` インスタンスを、呼び出しごとに異なる `structured_output_model` で再利用できる(`Person` 抽出と `Task` 抽出を同一 agent で切り替える等)。

```python
person_res = agent("Extract person: ...", structured_output_model=Person)
task_res   = agent("Create task: ...",    structured_output_model=Task)
```

- **Agent レベルのデフォルト**: `Agent(structured_output_model=PersonInfo)` で全 invocation の既定スキーマを設定できる。
- **デフォルトの上書き**: デフォルトを設定していても、特定呼び出しで `structured_output_model=...` を渡せば上書きできる。
- **会話履歴からの抽出**: 直前の会話 context から構造化情報を抽出可能(質問を繰り返さない)。
- **ツールとの併用**: ツール実行結果を構造化出力に整形できる(→ [[custom-tools]])。
- **ストリーミング併用**: `stream_async` 中も最終 result に構造化出力が入る。

> 💡 地雷: 複数の Pydantic スキーマ(例: `ThinkReplyOutput` / `AskReviewOutput` / `CategoryClassificationOutput`)を運用する場合、Agent デフォルトと per-invocation 上書きの優先順位を明確にし、スキーマは「焦点を絞って」定義する(ベストプラクティス)。

## 出典
- `raw/articles/strands-structured-output.md` — Pydantic/Zod 連携、`structured_output_model`、エラーハンドリング、複数スキーマ運用、Agent デフォルトと上書き、cookbook 各例。

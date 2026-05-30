---
title: Strands Agents Evals (strands-agents-evals)
type: entity
aliases: [Strands Evaluation, strands-agents-evals, strands_evals, Strands Evals SDK]
tags: [strands, evaluation, testing, sdk]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-evals-quickstart.mdx
related:
  - "[[evaluators]]"
  - "[[experiment-management]]"
  - "[[strands-agents]]"
---

## 概要
**strands-agents-evals**(import 名 `strands_evals`)は、AI エージェント・LLM アプリケーションを評価するためのフレームワーク。単純な出力検証から、trajectory(行動系列)評価、マルチエージェント相互作用分析、自動実験生成までをカバーする。[[strands-agents]] と同じモデルプロバイダを使用する。

## 詳細

### 提供機能
- **複数の評価タイプ**: 出力評価 / trajectory 分析 / ツール使用評価 / interaction 評価(→ [[evaluators]])
- **LLM-as-a-Judge**: モデルを使った構造化スコアリング。デフォルトは Amazon Bedrock + Claude 4 を judge モデルとして使用。
- **決定論的 evaluator**: `Equals` / `Contains` / `ToolCalled` / `StateEquals` など、CI/CD 向けの高速コードベースチェック。
- **trace ベース評価**: OpenTelemetry 実行 trace を解析(CloudWatch・Langfuse 等のリモート trace プロバイダ対応)。
- **自動実験生成 / 実験管理**: context 記述から test suite を生成、JSON シリアライズで保存・版管理(→ [[experiment-management]])。

### 導入
```
pip install strands-agents-evals
pip install strands-agents strands-agents-tools   # コア SDK と tools
```
Python 3.10+ が必要。

### 最小構成(Quickstart の骨子)
`@eval_task()` でタスク関数(`Agent` を返すだけ)を定義 → `Case` で test case を作成 → `OutputEvaluator` 等の evaluator を rubric 付きで生成 → `Experiment(cases=..., evaluators=...)` → `experiment.run_evaluations(task_fn)` で実行。`experiment.to_file("name")` で `./experiment_files/<name>.json` に保存。

```python
from strands import Agent
from strands_evals import eval_task, Case, Experiment
from strands_evals.evaluators import OutputEvaluator

@eval_task()
def get_response():
    return Agent(system_prompt="...", callback_handler=None)

experiment = Experiment[str, str](cases=test_cases, evaluators=[OutputEvaluator(rubric="...")])
reports = experiment.run_evaluations(get_response)
reports[0].run_display()
```

- **async 実行**: `run_evaluations_async` で test case を並行評価し総時間を短縮。
- **context 溢れ対策**: trajectory 評価では `tools_use_extractor` を使い trajectory を効率抽出すること(quickstart の Performance Optimization 推奨)。

## 出典
- `raw/articles/strands-evals-quickstart.mdx` — フレームワーク概要、インストール、`@eval_task`/`Case`/`Experiment`/`run_evaluations`、自動生成、custom evaluator、async 実行の各例。

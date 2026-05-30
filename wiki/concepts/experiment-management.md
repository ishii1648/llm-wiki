---
title: Experiment Management (Strands Evals)
type: concept
aliases: [experiment management, 実験管理, Experiment, Case]
tags: [strands, evaluation, experiment, case, dataset]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-evals-experiment-management.md
related:
  - "[[strands-agents-evals]]"
  - "[[evaluators]]"
---

## 概要
**Experiment Management** は、test case を `Experiment` オブジェクトに整理し、評価実験を管理・版管理する実践パターン。[[strands-agents-evals]] では `Case` を `Experiment` にまとめ、`run_evaluations` で実行する。

## 詳細

### test case の整理
- **metadata による整理**: `Case(name=..., input=..., metadata={"category":..., "difficulty":..., "tags":[...]})`。`[c for c in cases if c.metadata.get("difficulty")=="easy"]` のようにフィルタできる。dataset item から case を組む際の基本。
- **命名規約**: `{category}-{subcategory}-{number}`(例 `knowledge-geography-001`)。説明的な名前を使う(`test1` より `customer-service-refund-request`)。

### 複数実験の管理
```python
experiments = {
    "baseline":   Experiment(cases=baseline_cases, evaluators=[...]),
    "with_tools": Experiment(cases=tool_cases,     evaluators=[...]),
    "edge_cases": Experiment(cases=edge_cases,     evaluators=[...]),
}
for name, exp in experiments.items():
    reports = exp.run_evaluations(task_function)
```
- **結合**: `Experiment(cases=exp1.cases + exp2.cases + exp3.cases, evaluators=[...])`。
- **レポート flatten**: 複数 evaluator は evaluator ごとに1レポートを返す。`EvaluationReport.flatten(reports)` で1テーブルに統合(`combined.run_display()`)。

### 実験の変更
- case 追加: `experiment.cases.append(new_case)` / `experiment.cases.extend([...])`。
- evaluator 差し替え: `experiment.evaluators = [OutputEvaluator(), HelpfulnessEvaluator()]`(→ [[evaluators]])。

### Session ID
各 `Case` には自動で一意の session ID(UUID)が付く。`case.session_id` で参照、`Case(input=..., session_id="custom-123")` で明示指定も可能。trace ベース評価で session マッピングに使う。

### ベストプラクティス
1. 説明的な name を使う。
2. リッチな metadata(category / difficulty / expected_tools / created_date 等)を含める。
3. 実験を版管理する: `experiment.to_file("experiment_v1.json")`、タイムスタンプ付き保存(`experiment_{YYYYmmdd_HHMMSS}.json`)。

## 出典
- `raw/articles/strands-evals-experiment-management.md` — metadata 整理、命名規約、複数実験管理(collections/combining/flatten)、実験変更、session ID、版管理のベストプラクティス。

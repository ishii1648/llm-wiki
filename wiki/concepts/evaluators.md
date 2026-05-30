---
title: Evaluators (Strands Evals)
type: concept
aliases: [evaluators, Evaluator, OutputEvaluator, TrajectoryEvaluator, InteractionsEvaluator]
tags: [strands, evaluation, evaluators, llm-as-judge, rubric]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-evals-evaluators.mdx
related:
  - "[[strands-agents-evals]]"
  - "[[experiment-management]]"
---

## 概要
**Evaluators** は、会話エージェントの出力・挙動・目標達成を解析して品質と性能を評価するコンポーネント。[[strands-agents-evals]] は、個々の応答品質から多ターン会話の成功までを評価する組み込み evaluator 群を提供する。単純な exact match を超え、LLM-as-a-judge による主観品質評価や構造化された理由付けを行う。

## 詳細

### 評価レベル(粒度)
| レベル | スコープ | 用途 |
|---|---|---|
| **OUTPUT_LEVEL** | 単一応答 | 個々の出力品質 |
| **TRACE_LEVEL** | 単一ターン | ターンごとの会話分析 |
| **SESSION_LEVEL** | 会話全体 | end-to-end の目標達成 |

### 組み込み Evaluator(選定の指針)
**応答品質(主に TRACE_LEVEL、Output は OUTPUT_LEVEL)**
- `OutputEvaluator`(OUTPUT_LEVEL): custom rubric による柔軟な LLM 評価。安全性・関連性・トーン等の任意の主観品質に。
- `HelpfulnessEvaluator`: ユーザ視点の有用性(seven-level scoring)。
- `FaithfulnessEvaluator`: 事実正確性・groundedness。
- `CorrectnessEvaluator`: 事実正確性(任意で reference 比較)。
- `CoherenceEvaluator`: 論理一貫性・推論品質。
- `ConcisenessEvaluator`: 簡潔性・効率。
- `ResponseRelevanceEvaluator`: 質問との関連性。
- `HarmfulnessEvaluator` / `RefusalEvaluator` / `StereotypingEvaluator` / `InstructionFollowingEvaluator`: いずれも binary 評価(有害/不当な拒否/バイアス/指示遵守)。

**Multimodal(OUTPUT_LEVEL)**: `MultimodalOutputEvaluator` / `MultimodalOverallQualityEvaluator` / `MultimodalCorrectnessEvaluator` / `MultimodalFaithfulnessEvaluator` / `MultimodalInstructionFollowingEvaluator`(画像/文書→テキストタスク向け)。

**ツール使用(TRACE_LEVEL)**: `ToolSelectionEvaluator`(正しいツール選択)/ `ToolParameterEvaluator`(パラメータ正確性)。

**会話フロー(SESSION_LEVEL)**:
- `TrajectoryEvaluator`: 行動系列・ツール使用パターン。多段推論/ワークフロー遵守の評価。`exact_match_scorer` / `in_order_match_scorer` / `any_order_match_scorer` の組み込み scoring を rubric で使える。
- `InteractionsEvaluator`: 会話パターン・interaction 品質・エンゲージメント。

**目標達成(SESSION_LEVEL)**: `GoalSuccessRateEvaluator`(ユーザ目標の達成判定)。

**決定論的(OUTPUT/SESSION_LEVEL)**: LLM judge を使わない高速チェック。`Equals` / `Contains` / `StartsWith` / `ToolCalled` / `StateEquals`。回帰テスト・CI/CD・exact match に。

### Custom Evaluator
基底 `Evaluator` を継承し `evaluate(evaluation_case: EvaluationData) -> EvaluationOutput` を実装。`EvaluationOutput(score, test_pass, reason, label)` を返す。ドメイン特化のロジックに。

### Evaluators vs Simulators
| 観点 | Evaluators | Simulators |
|---|---|---|
| 役割 | 品質を評価 | 相互作用を生成 |
| タイミング | 会話後 | 会話中 |
| 出力 | 評価スコア | 会話ターン |

両者は補完関係: simulator で多ターン会話を生成 → evaluator で品質評価。`ActorSimulator.from_case_for_user_simulator(...)` + `StrandsInMemorySessionMapper` で session を組み、複数 evaluator で多面評価する。

### ベストプラクティス
- 評価レベルを目的に合わせる(個別品質→OUTPUT、ターン→TRACE、end-to-end→SESSION)。
- 複数 evaluator を組み合わせる(Helpfulness + Faithfulness + ToolSelection + GoalSuccessRate 等)。
- 明確な rubric を書く(1.0/0.5/0.0 の基準を具体化)。
- `aevaluate` で async 並行評価し性能を上げる。

## 出典
- `raw/articles/strands-evals-evaluators.mdx` — 評価レベル、組み込み evaluator 一覧と level/purpose、custom evaluator、evaluators vs simulators、統合例、ベストプラクティス、common patterns。

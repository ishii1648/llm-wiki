---
title: Evaluators (Strands Evals)
type: concept
aliases: [evaluators, Evaluator, OutputEvaluator, TrajectoryEvaluator, InteractionsEvaluator]
tags: [strands, evaluation, evaluators, llm-as-judge, rubric]
created: 2026-05-30
updated: 2026-08-29
sources:
  - raw/articles/strands-evals-evaluators.mdx
  - raw/articles/demystifying-evals-for-ai-agents.md
related:
  - "[[strands-agents-evals]]"
  - "[[experiment-management]]"
  - "[[graders]]"
  - "[[agent-evaluation]]"
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

## Anthropic の grader 分類との対応
[[graders]] の3分類にこのページの evaluator を当てはめると、Strands の分類がどの層を厚くしているかが分かる。

| [[graders]] の分類 | 対応する Strands evaluator |
|---|---|
| code-based | 決定論的 evaluator(`Equals` / `Contains` / `StartsWith` / `ToolCalled` / `StateEquals`) |
| model-based(LLM-as-judge) | `OutputEvaluator` 以下の rubric 系ほぼ全部、multimodal 系、`ToolSelectionEvaluator` / `ToolParameterEvaluator`、`TrajectoryEvaluator` / `InteractionsEvaluator` / `GoalSuccessRateEvaluator` |
| human | SDK 側に該当なし。LLM judge の校正は利用側の運用に委ねられる |

> ⚠️ 力点の相違: 本ページのベストプラクティスは「複数 evaluator を組み合わせる」を前面に出すが、Anthropic の記事は**決定論的 grader を可能な限り優先し、LLM judge は必要なとき/柔軟性が要るときに限る**という順序をより強く主張する(`raw/articles/demystifying-evals-for-ai-agents.md`)。矛盾ではないが既定値の置き所が違い、Strands の組み込み evaluator が LLM judge に大きく偏っている点は意識して選ぶべき。
>
> 同様に `TrajectoryEvaluator` の `exact_match_scorer` / `in_order_match_scorer` は「ツール呼び出しの順序」を採点する手段だが、Anthropic 記事は**経路の固定的な採点は脆く、エージェントの妥当な創造性を罰する**として、成果物の採点を推奨している。順序の一致が本当に要件かを確認してから使うこと。

## 出典
- `raw/articles/strands-evals-evaluators.mdx` — 評価レベル、組み込み evaluator 一覧と level/purpose、custom evaluator、evaluators vs simulators、統合例、ベストプラクティス、common patterns。
- `raw/articles/demystifying-evals-for-ai-agents.md` — grader の3分類(code-based / model-based / human)と「決定論的優先・経路でなく成果物を採点」の推奨。上表の対応づけは本 wiki による整理(推測を含む)。

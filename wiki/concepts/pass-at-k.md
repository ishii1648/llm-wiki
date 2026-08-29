---
title: pass@k と pass^k
type: concept
aliases: [pass@k, pass^k, pass at k, pass hat k, 非決定性, non-determinism]
tags: [evaluation, evals, metrics, non-determinism, reliability]
created: 2026-08-29
updated: 2026-08-29
sources:
  - raw/articles/demystifying-evals-for-ai-agents.md
related:
  - "[[agent-evaluation]]"
  - "[[capability-vs-regression-evals]]"
  - "[[graders]]"
---

## 概要
エージェントの挙動は実行ごとにぶれるため、eval 結果は見た目より解釈が難しい。task ごとに固有の成功率(ある task で 90%、別で 50%)があり、ある実行で通った task が次で落ちる。測りたいのは「**trial のうちどれくらいの割合で成功するか**」であることが多い。このニュアンスを捉えるのが **pass@k** と **pass^k** の2指標(出典: Anthropic, 2026-01-09)。

## 2つの指標

| 指標 | 定義 | k を増やすと | 使いどころ |
|---|---|---|---|
| **pass@k** | k 回の試行のうち**少なくとも1回**正解を得る確率 | **上がる**(shots on goal が増える) | 1回でも成功すればよいツール。コーディングでは「一発で解く」= **pass@1** に関心が集まる |
| **pass^k** | **k 回すべて**が成功する確率 | **下がる**(より多くの trial で一貫性を要求するのは厳しいバー) | 毎回の信頼できる挙動をユーザーが期待する**顧客向けエージェント** |

- 「50% pass@1」= モデルが eval の task の半分を初回で成功させる。
- 1 trial あたり成功率 75% のエージェントで 3 trial なら、3回すべて通る確率は (0.75)³ ≈ **42%**。
- **k=1 では両者は一致する**(どちらも 1 trial あたりの成功率)。k=10 になると正反対の物語を語る: pass@k は 100% に近づき、pass^k は 0% に落ちる。

> どちらも有用で、選択は**プロダクト要件**で決まる。「1回でも成功すればよい」なら pass@k、「一貫性が本質」なら pass^k。

## 診断への応用
frontier モデルで**多数 trial にわたる 0% pass(= 0% pass@100)は、エージェントが無能なのではなく task が壊れている signal** であることが最も多い。task 仕様と grader を再確認するサインとして使う。→ [[graders]]

逆側の端では [[capability-vs-regression-evals]] の **eval saturation**(pass 率が 100% に張り付き改善の signal が消える)が問題になる。両端で eval が情報を失う点は対称的。

## 出典
- `raw/articles/demystifying-evals-for-ai-agents.md` — "How to think about non-determinism in evaluations for agents"(task ごとの成功率、pass@k / pass^k の定義と k に対する挙動、75%³≈42% の例、k=1 での一致と k=10 での乖離、プロダクト要件による使い分け)、Step 2 の 0% pass@100 の解釈。

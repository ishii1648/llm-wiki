---
title: Capability Eval と Regression Eval
type: concept
aliases: [capability eval, quality eval, regression eval, 能力評価, 回帰評価, eval saturation, 飽和]
tags: [evaluation, evals, regression, benchmark, anthropic]
created: 2026-08-29
updated: 2026-08-29
sources:
  - raw/articles/demystifying-evals-for-ai-agents.md
related:
  - "[[agent-evaluation]]"
  - "[[graders]]"
  - "[[eval-driven-development]]"
  - "[[pass-at-k]]"
---

## 概要
eval は**問いの向き**で2種に分かれ、期待する pass 率も運用も逆になる。この区別を持たないと「スコアが上がらない」「スコアが 100% で何も分からない」の両方に対処できない(出典: Anthropic, 2026-01-09)。

| | **capability eval**(= quality eval) | **regression eval** |
|---|---|---|
| 問い | 「このエージェントは**何をうまくできるか**?」 | 「以前できていたことを**まだ全部できているか**?」 |
| 期待 pass 率 | **低い**ところから始める | **ほぼ 100%** |
| 狙う task | エージェントが苦戦する task | 既に安定して通る task |
| 役割 | チームに**登るべき丘**を与える | 後退(backsliding)を防ぐ。スコア低下 = 何かが壊れた signal |

capability eval を登るときは、**変更が他所に問題を起こしていないかを regression eval で必ず併走確認する**。

## 卒業(graduation): capability → regression
ローンチと最適化を経て pass 率が高くなった capability eval は、**regression suite に「卒業」させ**、drift を捕まえるために継続実行する。かつて「そもそもできるのか?」を測っていた task が、「**まだ確実にできるか?**」を測るものに変わる。

## eval saturation(飽和)
**eval saturation** は、エージェントが解ける task をすべて通してしまい、改善の余地が残らない状態。100% の eval は回帰を追跡できるが、**改善の signal はゼロ**になる。

- SWE-bench Verified は今年 30% から始まり、frontier モデルは 80% 超で飽和に近づいている。
- 飽和に近づくほど残るのは最難関 task だけになり、進捗も鈍る。すると**大きな能力向上が小さなスコア上昇にしか見えない**という、結果を誤読させる状態になる。
- 事例: コードレビューのスタートアップ **Qodo** は当初 Opus 4.5 に感心しなかった。彼らの one-shot コーディング eval が、より長く複雑な task での向上を捉えられていなかったため。これを受けて **agentic eval フレームワークを新たに開発**し、進捗をはるかに明瞭に把握できるようになった。

> 飽和の兆候が出たら、eval を難しくするか、より長い・より agentic な task へ設計を作り直す。スコアの停滞をモデルの停滞と読み違えないこと。

## 関連
- 飽和と表裏の落とし穴として、**0% pass も同様に signal を持たない**。frontier モデルで 0% pass@100 なら task が壊れている疑いが濃い → [[graders]]、[[pass-at-k]]。
- 「まだ実現できていない能力を先に eval として定義しておく」実践は eval-driven development の中核 → [[eval-driven-development]]。

## 出典
- `raw/articles/demystifying-evals-for-ai-agents.md` — "Capability vs. regression evals" セクション(定義・期待 pass 率・卒業)、Step 7 "Monitor for capability eval saturation"(SWE-Bench Verified の 30%→80%超、Qodo の事例、スコアを額面どおり受け取らない規範)。

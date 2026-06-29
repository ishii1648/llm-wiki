---
title: "Writing Code vs. Shipping Code: Productivity Effects Across Generations of AI Coding Tools"
type: entity
aliases: [Writing Code vs Shipping Code, NBER w35275, NBER Working Paper 35275, Demirer Musolff Yang 2026]
tags: [paper, nber, economics, productivity, ai-coding-tools, weak-link, event-study]
created: 2026-06-29
updated: 2026-06-29
sources:
  - raw/papers/writing-code-vs-shipping-code.md
related:
  - "[[weak-link-hypothesis]]"
  - "[[ai-coding-tool-generations]]"
  - "[[one-developer-is-all-you-need]]"
  - "[[the-end-of-software-engineering]]"
  - "[[agentic-engineering]]"
---

## 概要
Mert Demirer・Leon Musolff・Liyuan Yang による **NBER Working Paper No. 35275**(2026年5月、JEL: D24, L86, O33)。**10万人超の GitHub 開発者**の活動データと AI 利用テレメトリを突き合わせた **matched event study** で、3世代の AI コーディングツール(autocomplete / sync agent / async agent)の生産性効果を測定する。中心的発見は「**タスクレベルの大きな生産性向上が、本番出力(shipped/used software)へはごく一部しか伝播しない**」という **weak-link(弱い環)仮説**の実証である([[weak-link-hypothesis]])。

著者: Mert Demirer(MIT 経済学部 & NBER)、Leon Musolff(UPenn Wharton & NBER)、Liyuan Yang(MIT)。査読前のディスカッションペーパー。

## 2つの問い(研究課題)
1. AI の生産性効果は**ツール世代をまたいでどう進化する**か。
2. タスクレベルの利得は**最終出力にどこまで翻訳される**か。

## 主要な結果

### 世代横断のタスクレベル効果(commits 基準・累積)
ツールは旧世代と併用されるため、各世代までの**累積効果**で示される([[ai-coding-tool-generations]])。

| 世代 | commits への累積効果 |
|---|---|
| autocomplete | **+40%** |
| + sync agent | **+140%** |
| + async agent | **+180%**(agent 作成 commit 含む) |

効果は**活動量の少ない開発者ほど大きい**が、分布全体で substantial。

### 生産階層を上るほど減衰(attenuation)
ソフトウェア生産は **lines of code → files → commits → pull requests → projects → releases** の6層階層([[weak-link-hypothesis]] の生産モデル、本文 Figure 3)。AI 効果はこの階層を上るにつれ急減する:

- **async agent**: commits +180% → **projects +50% → releases +30%**。
- **sync agent**: **lines of code +741% → pull requests +65% → releases +20%**。
- **autocomplete**: **lines of code +228% → commits +36% → releases +10%**。

### メカニズム: 強い補完性
階層モデルを推定値に較正すると、上流出力(AI 生成)と各層の人手の間の **代替の弾力性 ≈ 0.25**。これは AI と人手の**強い補完性(strong complementarity)**を意味する。autocomplete は code-writing 層のみ、sync/async agent はより後段にも介入する、という想定とも整合。

### アプリマーケットプレイスでの検証
Apple App Store / Google Play / Chrome Web Store / SourceForge の月次パネルで上記を裏取り:
- 2025年中頃以降、**新規アプリ数は増加**(Apple/Chrome で急増、Google Play は緩やか、SourceForge はほぼ不変)。
- しかし**ローンチ後3ヶ月の総利用量はどのマーケットでも増えていない**。
- **わずかな利用者すら獲得できない新規アプリの割合が上昇** → 供給増は「ほぼ無利用」のアプリに偏在。
- 解釈は2つ(本データでは区別不可): (a) 限界的アプリの品質が低い / (b) 消費者側のボトルネック(発見・採用に時間がかかる)。

## 結論の含意
- ボトルネックは「コードを**書く**」から「**レビュー・統合・配布**する」へ移りつつある。
- 段階が補完的なとき、一段だけ自動化しても最終出力への効果は有界(マクロ成長論の weak-link / O-ring ロジックの**垂直版**)。
- 今後の伸びしろは、(a) レビュー不要な高品質コード生成、(b) レビュー・統合の自動化、(c) 発見・採用の改善——のいずれかが downstream 制約を緩めるか次第。

## 限界(著者明記)
- ソフト品質は ratings/downloads からの**間接推定**にとどまる。
- enterprise・社内専用ソフトはカバー外。
- ソフトウェアは生成 AI 最先端の応用領域であり、量的推定値は他分野へ外挿できない可能性。

## 関連
- [[weak-link-hypothesis]] — 本論文が垂直生産階層で実証した中核理論。
- [[ai-coding-tool-generations]] — 本論文の3世代分類(autocomplete/sync/async)と各世代効果。
- [[one-developer-is-all-you-need]] — 「1人+AIで増幅」というミクロ事例。本論文は「タスク利得は最終出力に薄まる」と**マクロで反証的に補完**する。
- [[the-end-of-software-engineering]] — AI がパラダイムを変えるという楽観論。本論文は「律速は人間ボトルネックへ移るだけ」と冷静な計量証拠を対置。
- [[agentic-engineering]] — 「人間の役割が intent architect/auditor へ」という主張は、本論文の「ボトルネックがレビュー・統合へ移る」と整合。

## 出典
- raw/papers/writing-code-vs-shipping-code.md(NBER Working Paper No. 35275, May 2026, Demirer・Musolff・Yang)

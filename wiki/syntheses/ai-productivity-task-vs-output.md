---
title: AI 生産性のミクロ⇄マクロ — タスク利得は本番出力に翻訳されるか
type: synthesis
aliases: [task-level vs output, productivity paradox of AI coding, AI 生産性パラドクス, writing vs shipping]
tags: [synthesis, productivity, ai-impact, weak-link, case-study, economics]
created: 2026-06-29
updated: 2026-06-29
sources:
  - raw/papers/writing-code-vs-shipping-code.md
  - raw/papers/one-developer-is-all-you-need.md
  - raw/papers/the-end-of-software-engineering.md
related:
  - "[[writing-code-vs-shipping-code]]"
  - "[[weak-link-hypothesis]]"
  - "[[one-developer-is-all-you-need]]"
  - "[[one-person-squad]]"
  - "[[the-end-of-software-engineering]]"
  - "[[agentic-engineering]]"
  - "[[ai-code-review]]"
---

## 問い
AI コーディングツールは「コードを書く」タスクを劇的に速くする。では、その利得は**実際に出荷され使われるソフトウェア**にどこまで翻訳されるのか? wiki 内の3本のソースは、この問いに**異なる粒度・異なる態度**で答えており、突き合わせると一貫した像が立ち上がる。

## 3つの視点

| ソース | 粒度 | 方法 | 中心主張 |
|---|---|---|---|
| [[writing-code-vs-shipping-code]] (NBER w35275) | マクロ計量 | 10万+開発者の event study + 4マーケット | タスク利得は**最終出力へ大きく減衰**(commits+180%→releases+30%)。律速は人間ボトルネックへ移動 |
| [[one-developer-is-all-you-need]] (Itaú 事例) | ミクロ事例 | 単一事例研究 | 1人+4 AIエージェントで**時間50%短縮・コスト85%減**。AI は熟練者を**増幅** |
| [[the-end-of-software-engineering]] (Cao 2026) | 理論/ポジション | first-principles + ベンチ | AI はツール改良でなく**パラダイム転換**。人間は intent architect/auditor へ |

## 一見の対立、実は補完
楽観論(one-developer / end-of-SE)と計量的慎重論(weak-link)は**矛盾しない**。両立する命題は:

1. **タスクレベルの増幅は本物**。autocomplete +40%、sync +140%、async +180%(commits)。Itaú の事例もこの上限近傍の一点と読める。
2. **しかし出力はボトルネックに律速される**([[weak-link-hypothesis]])。代替の弾力性 ≈ 0.25 = AI と人手は**強い補完**。コードを速く書いても、レビュー・統合・配布・そして**消費者の発見/採用**が伴わなければ releases も usage も伸びない(4マーケットで総利用量は不変、無利用アプリの割合は上昇)。

→ ミクロの「+180%」とマクロの「+30%」は**同じ現象の別の層**。減衰こそが weak-link 仮説の予言。

## ボトルネックは「消える」のでなく「移動する」
3ソースは別々の語彙で**同じ移動**を指している:

- [[writing-code-vs-shipping-code]]: 律速は「書く」→「**レビュー・統合・配布**」へ。
- [[one-person-squad]]: 成立条件は「**仕様の質**」と「**経験者=品質ゲート**」。コード生産が安価になると、上流(仕様)と下流(レビュー/検収)が binding になる。
- [[agentic-engineering]] / [[ai-code-review]]: 人間の役割は著者から **intent architect / outcome auditor** へ。価値は orchestration と検証に移る。

つまり「AI が安くした段階の**隣**が次の weak link になる」という構造を、計量(w35275)・事例(Itaú)・理論(Cao/LangChain)が三方向から裏付ける。

## どこで楽観論は効くか(境界条件)
[[one-person-squad]] が挙げる成立条件は、weak-link の言葉では「**補完段階を人間が高速に処理できる範囲**」に等しい:
- well-specified・定型パターン・指揮役が熟知するドメイン → 下流レビュー負荷が小さく、タスク利得が出力に通りやすい。
- プロダクト不確実性・未知ドメイン・高 blast-radius → 下流の人間ボトルネックが効き、減衰が大きい。

## 含意
- **「コードを速く書ける」は十分条件でない**。最終出力を伸ばすには、AI が**下流(レビュー・統合・発見・採用)**を緩める必要がある(w35275 結論)。
- 投資判断: タスク自動化 ROI を「commits/LOC」で測ると過大評価になりうる。**releases / 採用された機能**で測れ。
- 将来の伸びしろは「レビュー不要な高品質生成」「レビュー・統合の自動化」「discovery/adoption の改善」のいずれかが downstream を解くか次第。

## 出典
- raw/papers/writing-code-vs-shipping-code.md(NBER w35275: 階層減衰・弾力性0.25・マーケット分析)
- raw/papers/one-developer-is-all-you-need.md(Itaú 単一事例: 数値・成立条件)
- raw/papers/the-end-of-software-engineering.md(Cao 2026: パラダイム転換論・人間役割)

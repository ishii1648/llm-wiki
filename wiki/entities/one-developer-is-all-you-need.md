---
title: "One Developer Is All You Need: A Case Study of an AI-Augmented One-Person Squad in a Brownfield Enterprise"
type: entity
aliases: [One Developer Is All You Need, one-person squad paper, arXiv:2605.18461, Itaú one-person squad study]
tags: [paper, case-study, ai-augmented-development, software-engineering, enterprise]
created: 2026-06-05
updated: 2026-06-05
sources:
  - raw/papers/one-developer-is-all-you-need.md
related:
  - "[[one-person-squad]]"
  - "[[spec-driven-development]]"
  - "[[ai-code-review]]"
  - "[[writing-code-vs-shipping-code]]"
  - "[[ai-productivity-task-vs-output]]"
---

## 概要
Itaú Unibanco(ブラジルの大手金融機関)での**単一事例研究(single-case practitioner-researcher study)**。1人の staff エンジニアが4つの AI エージェントを **Spec-Driven Development(SDD)** ワークフローで指揮し、本来「4人スカッド×6スプリント」想定のブラウンフィールド案件(非口座保有者向けデジタル署名基盤)を**3スプリントで完遂**した経緯と条件を報告する。中心的主張は「**AI はチームメンバーを置換せず、残った経験豊富なエンジニアのスループットを増幅(multiply)する**——律速はモデル能力ではなく、仕様の質と組織知である」。

著者: Marcelo Vilas Boas, Gustavo Pinto, Edward Roberto Monteiro, Vinicius Fernandes Carida, Danilo Ribeiro(arXiv:2605.18461v2, 2026)。

## 設定(One-Person Squad)
4つのエージェント役割を3ツール上に構築し、デリバリ全工程をカバー([[one-person-squad]] に詳述)。

| 段階 | ツール | モード |
|---|---|---|
| Discovery & 要件 | StackSpot エージェント | Human-in-the-loop |
| 仕様(Specification) | Devin | Human-in-the-loop |
| 開発(core) | GitHub Copilot | Human-in-the-loop |
| 開発(non-core) | Devin | Autonomous |

各エージェントには事前にドメイン知識・組織標準・プロジェクト制約をロード。最終の homologation(検収)段階は**人間主導**で維持。

## 主要な結果(RQ1: 成果)
- **デリバリ**: 5フィーチャ(25ユーザストーリ)を3スプリント(各3週)で完遂。当初6スプリント計画に対し **time-to-market 50%短縮**。
- **コード品質**: AI生成コードの **90%が初回レビューで構造的修正なしに採用**。
- **テスト**: 統合テスト **113/113 合格(100%)**、E2E **65/65**、backend カバレッジ 92.8%・frontend 90.3%(いずれも90%ゲート以上)。
- **欠陥**: post-validation 欠陥 **1件のみ**(アクセシビリティバグ)、post-release **0件**。
- **スループット**: BCP/eng-hour が S1 0.59 → S3 3.21(5.4倍)。過去ベースライン比で **BCP当たり工数 8.93h → 2.2h(51%削減)**。
- **コスト**: 当初見積 R$492,000 に対し実人件費 R$60,000(−88%)、ツール込みで **85%超のコスト削減**。

> ⚠️ 数値の読み方: スループット急増には (a) S1の仕様作成コストの後続スプリントへの償却、(b) core/non-core境界の確定、(c) スコアラが高評価する front-end ストーリへの構成シフト という複合効果が含まれる(著者明記)。開発は2025/08–09 で当時の最強モデルは GPT-5 と Claude Sonnet 4.5、マルチリポ計画は当時より脆弱だったため「下限」と読むべき、とされる。

## 成功/破綻の条件(RQ2)
1. **仕様の質が第一決定要因**。詳細で曖昧さのない仕様は無修正に近いコードを生む。ブラウンフィールドでは**未文書化のレガシー統合契約**が最大の rework 源。
2. **core/non-core分割は再現可能なヒューリスティック**。ドメイン濃いロジックは継続的な人の判断が必要、定型基盤は自律委任可能。境界は初期イテレーションで経験的に確定する。
3. **モデルは既存の専門性の「増幅器」であり代替ではない**。8年の実務経験+4年の institution 在籍が「品質ゲート」を成立させた。Becker et al.・Cui et al. の知見(熟練者・既知コードベースでは AI の速度向上が小さい)と整合。

## 限界・脅威(著者明記)
- **単一事例**設計で一般化が限定的。中間構成(2〜3人 AI拡張スカッド)は未検証。
- **実務者=研究者の二重性**による確認バイアス(著者の1人が主たる被験者かつ観察者)。
- ベースラインは**同一チームの過去速度**(並行対照群ではない)で、フィーチャ複雑度差を統制しきれない。
- one-person 構成は**境界テスト**であり到達目標ではない。著者は**2人技術ペア + 分数的(fractional)プロダクト戦略家**をより持続的な運用モデルとして仮説提示(直接検証はしていない)。

## 関連
- [[one-person-squad]] — 本論文が実証した構成パターンそのもの。
- [[spec-driven-development]] — 本論文の前提となる方法論。律速を「仕様の質」に移す。
- [[ai-code-review]] — 「AI生成コードは著者性(authorship)を壊す/理解こそ品質の鍵」という主張と、本論文の「経験あるエンジニアが品質ゲート」という結論が表裏で接続する。

## 出典
- raw/papers/one-developer-is-all-you-need.md(arXiv:2605.18461v2, 2026, Itaú Unibanco)

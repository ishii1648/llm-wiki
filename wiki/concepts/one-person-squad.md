---
title: One-Person Squad(一人スカッド)
type: concept
aliases: [one-person squad, 一人スカッド, AI-augmented one-person squad, solo AI-augmented delivery]
tags: [team-topology, ai-augmented-development, software-engineering, agentic-development]
created: 2026-06-05
updated: 2026-08-11
sources:
  - raw/papers/one-developer-is-all-you-need.md
related:
  - "[[one-developer-is-all-you-need]]"
  - "[[spec-driven-development]]"
  - "[[ai-code-review]]"
  - "[[weak-link-hypothesis]]"
  - "[[ai-productivity-task-vs-output]]"
  - "[[mob-rituals]]"
---

## 概要
**One-Person Squad(一人スカッド)** とは、1人の経験豊富なエンジニアが、機能役割(役割=product/spec/core dev/non-core dev など)を割り当てた**複数の AI エージェント**を指揮し、プロダクト施策をエンドツーエンドで担う最小チーム構成。従来の solo developer が全役割の認知負荷を抱えるのと異なり、人間は**オーケストレータ**として高stakesの判断に専念し、定型的な専門作業をエージェントに吸収させる(He, Treude, Lo の LLM マルチエージェント研究の具体化)。

## 背景: Brooks のトレードオフを AI が変える
[[one-developer-is-all-you-need]] によれば、Brooks(人月の神話)以来「チーム規模は調整コストが非線形に増えるが、専門カバレッジを正当化する」というトレードオフが small cross-functional team(3〜9人)を規範化してきた。AI エージェントはこのトレードオフを変える——専門役割をエージェントが担うことで、規模縮小による「専門カバレッジ喪失」を補える。規制下・レガシー濃厚な企業環境で従来「構造的に不可能」とされた単独デリバリが射程に入る。

## 構成例(Itaú の事例)
| 役割 | ツール | モード | 担当 |
|---|---|---|---|
| Product Manager | StackSpot エージェント | Human-in-the-loop | discovery・要件・ユーザストーリ生成 |
| Specification | Devin(マルチリポ) | Human-in-the-loop | 9リポを文脈に仕様生成 |
| Developer(core) | GitHub Copilot(agent mode) | Human-in-the-loop | 業務ルール・ドメインユースケース |
| Developer(non-core) | Devin | Autonomous | 基盤・API統合・キュー設定・boilerplate |

ガードレールは CI/CD で強制(WCAG 2.1 AA、セキュリティスキャン、カバレッジ90%)。homologation(検収)は人間主導で維持。

## 中核ヒューリスティック: core / non-core 分割
タスクが要求する判断量に応じて人の監督を割り当てる:
- **core**(業務ルール・ドメインロジック・ユーザ向けロジック): human-in-the-loop。
- **non-core**(基盤・統合・boilerplate): 自律エージェントに委任。

境界は事前に自明ではなく、**初期イテレーションでエージェント出力が一貫して人の修正を要する箇所を観察して経験的に確定**する。一度確定すれば全フィーチャで再利用できる。詳細は [[spec-driven-development]] と併用。

## 成立条件と限界
**成立条件**(= 律速):
- **仕様の質**が出力品質の binding constraint([[spec-driven-development]])。
- **指揮役の組織知・ドメイン知**が「品質ゲート」を成立させる。AI は専門性の**増幅器であって代替ではない**。T字型(T-shaped: 1領域の深さ + 隣接領域の幅)コンピテンシが要件。

**限界**:
- 指揮役プロファイル(generalist/T-shaped)が**希少**で、AIツール調達より人材確保の方が難しい。
- **単一障害点(single point of failure)**: 1人に全メンタルモデルが集中。緩和策は (1) SDD 由来のドキュメントを day-1 から first-class 扱いにする「継続性レバー」、(2) **2人技術ペア + 分数的プロダクト戦略家**というより持続的な構成(著者の仮説)。
- 追加人員の価値が下がるのは「well-specified・定型パターン・指揮役が熟知するドメイン」のときに限る。プロダクト不確実性・未知ドメイン・高 blast-radius・長期運用では依然チームが有効。

> 一人スカッドは「普遍的な運用モデル」ではなく、**AI拡張による圧縮の境界テスト**として読むべき(著者強調)。

## 対照: mob を要求する AI-DLC
[[ai-dlc]](AWS)は原則8で「専門サイロを越えることで専門役割の必要数が減る」と述べ、**論理的には一人スカッドと同じ方向を向いている**。にもかかわらず、その儀式([[mob-rituals]])は Product Owner・開発者・QA・その他ステークホルダーが**単一の部屋に同席**することを前提とする。

この対立は「単一障害点」の扱いの違いとして読める。一人スカッドは1人に全メンタルモデルが集中するリスクを SDD 由来のドキュメント(継続性レバー)で緩和しようとするのに対し、AI-DLC は **AI 生成物の検証に複数の独立した視点を置く**ことで冗長化する。どちらも「経験者=品質ゲート」という同じ成立条件を認めた上での、異なる冗長化戦略である。(この対比は本 wiki の解釈)

## 関連
- [[one-developer-is-all-you-need]] — このパターンを実証した一次資料(事例・数値)。
- [[spec-driven-development]] — 一人スカッドを成立させる方法論的前提。
- [[ai-code-review]] — 「誰も理解しないまま PR 形の成果物が生まれる」リスクと、本パターンの「経験者=品質ゲート」要件は同じ問題の表裏。
- [[weak-link-hypothesis]] — 「仕様の質」「経験者=品質ゲート」という成立条件は、AI が安くした段階の隣(上流仕様・下流レビュー)が次の weak link になる、という計量的帰結と一致する。
- [[ai-productivity-task-vs-output]] — 本パターンの楽観的数値と NBER の減衰証拠を突き合わせた統合分析。

## 出典
- raw/papers/one-developer-is-all-you-need.md(§II-B, §III, §V-B, §VI)

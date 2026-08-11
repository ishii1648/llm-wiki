---
title: AI-DLC(AI-Driven Development Lifecycle)
type: concept
aliases:
  - AI-DLC
  - AI-Driven Development Lifecycle
  - AI駆動開発ライフサイクル
  - AI-Driven era
  - AI-Assisted era
tags: [methodology, agentic-development, software-engineering, ddd, aws, sdlc]
created: 2026-08-11
updated: 2026-08-11
sources:
  - raw/papers/aidlc-method-definition.md
related:
  - "[[intent-unit-bolt]]"
  - "[[mob-rituals]]"
  - "[[ai-dlc-vs-spec-driven-development]]"
  - "[[spec-driven-development]]"
  - "[[agentic-engineering]]"
  - "[[one-person-squad]]"
  - "[[domain-modeling]]"
  - "[[design-doc]]"
---

## 概要
**AI-DLC(AI-Driven Development Lifecycle)** は、AWS の Raja SP が定義した **AI-native な開発方法論**。SDLC や Agile(Scrum)に AI を後付け(retrofit)するのではなく、**第一原理から作り直す(reimagine)** ことを出発点とし、AI が計画・分解・生成を担い**人間は各段の承認者・検証者に回る**という役割配置を採る。設計技法(第一版は Domain-Driven Design)を方法論の**コアに内蔵**し、反復単位を週単位の Sprint から時間〜日単位の **Bolt** に縮める。

> ⚠️ 出典の性質: 本ページの記述は AWS が公開した 8 ページの method definition ペーパー1本のみに基づく。査読論文でも実証研究でもなく、**AWS のマーケティング文脈に置かれた提案文書**である。後述の主張(品質コスト $2.41 兆、「数週間〜数ヶ月が数時間に凝縮」など)は本 wiki が検証したものではない。実証データを伴う対照事例としては [[one-developer-is-all-you-need]] を参照。

## 2つの時代区分: AI-Assisted → AI-Driven
論文は現在地を2段階に切る。

- **AI-Assisted era**: コード生成・バグ検出・テスト生成といった**細粒度で個別のタスク**を AI が増強する段階。知的な重労働の大半は依然として開発者が負う。
- **AI-Driven era**: 要件精緻化・計画・タスク分解・設計・リアルタイム協働へと AI の適用範囲が拡がり、AI が**開発プロセスそのものをオーケストレートする**段階。

論文の立場は「AI-Assisted は AI のポテンシャルを解放できない。しかし現在の AI は高レベルの意図を自律的に実行可能コードへ翻訳するには**まだ信頼できない**」という中間点で、AI-DLC はその両端の間にバランスを置くと主張する。この「control plane としての AI」という捉え方は [[agentic-engineering]] と同じ地平にあるが、AI-DLC は**方法論(フェーズ・儀式・成果物)として具体化**している点が異なる。

## 10 の原則
論文 II 章。以下は原文の主張の要約。

| # | 原則 | 要旨 |
|---|---|---|
| 1 | Reimagine rather than retrofit | 既存手法は月〜週の反復を前提に daily standup 等の儀式を持つ。AI の適用は時間〜日の反復を生むため、多くの儀式が無意味化する。story point / velocity は Business Value 等に置き換わるべきでは、と問う。「速い馬車ではなく自動車が要る」 |
| 2 | Reverse the conversation direction | 人間が AI に指示するのでなく、**AI が会話を起こし人間に問う**。AI が高レベル intent を実行可能タスクへ分解し、推奨とトレードオフを提示。人間は approver。アナロジーは Google Maps(人間は目的地を決め、システムが経路を出す) |
| 3 | Integration of design techniques into the core | Scrum/Kanban が DDD 等の設計技法を「スコープ外・チーム任せ」にした空白が品質問題を生んだ。AI-DLC は設計技法を内蔵し、DDD / BDD / TDD の各フレーバーを持つ(本論文は **DDD 版**) |
| 4 | Align with AI capability | 将来には楽観、現状には現実的。自律実行にはまだ信頼できないので、開発者が検証・意思決定・監督の最終責任を保持する |
| 5 | Cater to building complex systems | 対象は継続的な機能適応・高いアーキ複雑度・多数のトレードオフ・スケーラビリティ/統合要件を持つシステム。非開発者が作れる単純なシステムは**スコープ外**(low-code/no-code の領分) |
| 6 | Retain what enhances human symbiosis | 人間の検証・リスク低減に不可欠な既存成果物は残す。例: user story(人間と AI の理解を揃える契約)、Risk Register |
| 7 | Facilitate transition through familiarity | 既存実践者が1日でオリエントできること。旧用語との関係を保ちつつ改名する(Sprint → **Bolt**) |
| 8 | Streamline responsibilities for efficiency | infra / front-end / back-end / DevOps / security といった専門サイロを開発者が越えられるようになり、専門役割の必要数が減る。ただし Product Owner と開発者は残す |
| 9 | Minimise stages, maximise flow | ハンドオフを最小化しつつ、人間の検証を「**loss function**」として要所に置く。AI 生成コードが硬直化(*quick-cement*)する前に無駄な下流作業を刈り取る |
| 10 | No hard-wired, opinionated SDLC workflows | 新規開発/リファクタ/欠陥修正/マイクロサービス増強といった経路ごとに決め打ちのワークフローを規定しない。AI が **Level 1 Plan** を提案し、人間が対話で検証・修正する |

> 原則1と原則7は緊張関係にある。「第一原理から作り直す」と言いつつ、採用容易性のために旧用語との対応を保つ(Unit ≒ Epic、Bolt ≒ Sprint)。論文自身「AI-DLC は既存 Agile 手法から大きくは逸脱しない」(VI 章)と述べており、**再発明の主張は用語の刷新に比べて実質が薄い**と読むこともできる。(この評価は本 wiki の解釈)

## 成果物とフェーズ
用語階層(Intent / Unit / Bolt)と設計成果物の連鎖は [[intent-unit-bolt]]、Mob Elaboration / Mob Construction の儀式は [[mob-rituals]] に分けて記述する。

3フェーズの骨子:

- **Inception Phase** — Intent を捉え、Unit に翻訳する。儀式は **Mob Elaboration**。出力は Unit と、その a) PRFAQ、b) User Stories、c) NFR 定義、d) リスク記述(組織の Risk Register と突合)、e) business intent に遡れる Measurement Criteria、f) 推奨 Bolt 群。
- **Construction Phase** — Unit を Deployment Unit へ。Domain Design → Logical Design → コード生成 → 自動テストと進む。儀式は **Mob Construction**。ブラウンフィールドでは、まず既存コードを**意味的に豊かなモデル表現へ「引き上げる」**(static model = コンポーネント・責務・関係、dynamic model = 主要ユースケースの相互作用)ステップが先行する。
- **Operations Phase** — デプロイ・observability・保守。AI がメトリクス/ログ/トレースを解析して異常検知と SLA 違反の予測を行い、incident runbook と統合してスケーリング・チューニング・障害隔離を提案、**開発者の承認を得て実行**する。

## ワークフロー: Level 1 Plan と再帰的分解
business intent(green-field 開発、brown-field 拡張、モダナイゼーション、欠陥修正など)を与えると、AI が **Level 1 Plan**(その intent を実装するワークフローの概要)を生成する。これは提案にすぎず、人間が透過的にレビュー・検証・修正する。各ステップはさらに AI によって細粒度の実行可能サブタスクへ分解され、これも人間の監督下に置かれる。**この分解が再帰的に繰り返される**。

方法論の中心にあるのは、**各段の成果物を人間の監督で漸進的に豊かにし、次段の「意味的に豊かな context」へ変換していく**という原則である。各ステップは戦略的な決定点であり、そこでの人間の監督は **loss function** のように働く——誤りが下流で雪だるま式に膨らむ前に捕捉・修正する。

生成された全成果物(intent、user story、domain model、テスト計画)は**永続化され、ライフサイクル横断の "context memory" として AI が参照**する。さらに全成果物が相互にリンクされ、前方・後方の**トレーサビリティ**(例: domain model の要素 ↔ 特定の user story)を持つことで、AI が各段で正しく最も関連の高い context を取り出せるようにする。

> この「成果物を永続化して context memory にする」設計は、[[loop-engineering]] の memory 論、[[open-knowledge-format]] / [[knowledge-bundle]] の「markdown ファイル群が知識の配布単位」という発想、そして本 wiki 自身の運用と同じ骨格を持つ。Appendix A のプロンプト(後述)では、それが `aidlc-docs/` 以下の md ファイル規約として具体化されている。

## Appendix A: 実プロンプト集
論文は付録に、AI-DLC を実践するための具体的プロンプトを載せている。特徴は**方法論本体よりも運用規律に踏み込んでいる**点。

- **Setup Prompt**: 全ドキュメントを `aidlc-docs/` 配下に置く。計画は `aidlc-docs/plans/`、要件・機能変更は `aidlc-docs/requirements/`、user story は `aidlc-docs/story-artifacts/`、アーキ/設計は `aidlc-docs/design-artifacts/`、**発行した全プロンプトを順序どおり** `aidlc-docs/prompts.md` に保存させる。
- **各段の共通形**: 「Your Role: あなたは経験ある〈product manager / software architect / software engineer / Cloud Architect〉である」でロールを与え、次に必ず——
  - **作業前に計画を md ファイルへ書け**(各ステップに**チェックボックス**付き)
  - **私の確認が要るステップには注記を入れよ**
  - **重要な決定を自分で下すな**(*Do not make critical decisions on your own*)
  - 計画を出したらレビューと承認を求めよ。**承認後に1ステップずつ実行**し、終えるたびにチェックボックスを埋めよ
- 具体タスク例: user story 生成 → 独立に構築可能な Unit へのグルーピング → component model 設計(「まだコードは生成するな」)→ Python 実装生成 → デプロイ計画(CloudFormation/CDK/Terraform)+ validation report の生成と自己修正 → Flask API 生成。

このプロンプト規約は、本 wiki の [[spec-driven-development]](仕様を第一級成果物にする)や、Claude Code の plan mode / [[domain-modeling]] の ADR 蓄積と実質的に同型である。詳しい突合は [[ai-dlc-vs-spec-driven-development]]。

## 導入
論文 VI 章は2つの導入戦略を挙げる。

- **Learning by Practicing** — AI-DLC は儀式(Mob Elaboration、Mob Construction 等)の集合なので、ドキュメントや研修でなく**実案件で儀式を実演させる**。AWS のソリューションアーキテクトが **AI-DLC Unicorn Gym** という field offering として提供している。
- **Developer Experience ツールへの埋め込み** — 顧客が構築中の SDLC 横断オーケストレーションツールに AI-DLC を埋め込む。論文は Cognizant の **FlowSource**、Aspire の **CodeSpell**、HCL の **AIForce** を挙げる。

## 批判的注記
- **AWS ベンダー色**: 成果物の説明が「適切な AWS サービスと construct を選ぶ」「well-architected 原則に従う」を前提とし、例示も Lambda / DynamoDB / API Gateway / CloudFormation に寄っている。方法論の骨格自体はクラウド非依存に読めるが、**論文としては AWS 実装を既定としている**。
- **未検証の引用**: 「米国だけでソフトウェア品質問題が 2022 年に $2.41 兆のコスト」という数字は原文で "(study)" とリンクされているのみで、抽出テキストにリンク先が残っていない(CISQ の報告と推測されるが未確認)。またこの数字を「Agile が設計技法を外出しにしたこと」に帰属させる論証は原文にはない。
- **実証データが皆無**: 「Mob Elaboration は数週間〜数ヶ月の逐次作業を数時間に凝縮する」「反復サイクルは時間〜日で回る」といった効果の主張に、事例・測定・比較対照が一切添えられていない。[[ai-productivity-task-vs-output]] が整理した「タスク利得は本番出力に翻訳されるとは限らない」という論点に照らすと、**Inception の高速化がデリバリ全体の高速化を意味するかは未証明**。
- **文書としての完成度**: 原文には `responsibiliti4es`、`CONSTRUCTTION`、`brown-filed`、"The Construction Phase The encompasses" 等の誤記が残る。査読を経ていないドラフト相当の文書として扱うのが妥当。
- **儀式の物理前提**: Mob Elaboration も Mob Construction も「**単一の部屋に全員が集まる**」ことを明示的に推奨している(→ [[mob-rituals]])。AI が非同期・並列を可能にするという方法論の主張と、この同期・同室の要求は緊張関係にある。

## 関連
- [[intent-unit-bolt]] — AI-DLC の成果物階層と Scrum 用語との対応。
- [[mob-rituals]] — Mob Elaboration / Mob Construction の儀式。
- [[ai-dlc-vs-spec-driven-development]] — SDD / one-person-squad / agentic engineering との突合。
- [[agentic-engineering]] — 「AI をデリバリ全体の control plane と見る」上位概念。AI-DLC はその方法論的具体化。
- [[spec-driven-development]] — 仕様を第一級成果物にする発想。AI-DLC の user story / Domain Design 連鎖と重なる。
- [[one-person-squad]] — 実証事例側。AI-DLC の原則8(専門サイロの解消)と対応。
- [[domain-modeling]] — DDD 語彙と ADR をセッション中に書き残す実装例。AI-DLC の Domain Design / ADR 生成に対応。

## 出典
- `raw/papers/aidlc-method-definition.md`(Raja SP, Amazon Web Services)— I 章(AI-Assisted / AI-Driven の区分)、II 章(10 原則)、III 章(成果物・フェーズ・ワークフロー)、IV/V 章(green-field / brown-field の流れ)、VI 章(導入)、Appendix A(プロンプト集)。
- 原本 PDF: `https://prod.d13rzhkk8cj2z0.amplifyapp.com/aidlc.pdf`(2026-08-11 取得)。

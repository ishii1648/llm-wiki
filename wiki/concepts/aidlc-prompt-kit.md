---
title: AI-DLC プロンプト集(Appendix A)
type: concept
aliases:
  - AI-DLC prompts
  - AI-DLC Appendix A
  - aidlc-docs
  - AI-DLC プロンプトキット
tags: [methodology, agentic-development, prompting, aws, sdlc, plan-then-execute]
created: 2026-08-11
updated: 2026-08-11
sources:
  - raw/papers/aidlc-method-definition.md
related:
  - "[[ai-dlc]]"
  - "[[intent-unit-bolt]]"
  - "[[mob-rituals]]"
  - "[[ai-dlc-vs-spec-driven-development]]"
  - "[[spec-driven-development]]"
  - "[[loop-engineering]]"
  - "[[domain-modeling]]"
---

## 概要
[[ai-dlc]] の Appendix A に収録された、AI-DLC を実践するための**具体的プロンプト 7 ブロック**。方法論本体(フェーズ・儀式・用語)より**運用規律に踏み込んでおり、実務的な再利用価値が最も高い部分**である。全ブロックが共通のテンプレートを持ち、そのテンプレート自体が AI-DLC の原則2(会話の向きの反転)と原則9(人間の検証を loss function に置く)をプロンプトレベルで実装している。

## 共通テンプレート: Role + 計画ゲート + Task
Setup Prompt を除く全ブロックが、次の3部構成をとる。

### 1. Role の付与
「**Your Role: You are an expert / experienced 〈役割〉**」で始める。使われる役割は4種:

| ブロック | 与える役割 |
|---|---|
| User stories | expert product manager |
| Units | experienced software architect |
| Domain (component) model creation | experienced software engineer |
| Code Generation | experienced software engineer |
| Architecture | experienced Cloud Architect |
| Build IaC/Rest APIs | experienced software engineer |

### 2. 計画ゲート(全ブロックで一字一句ほぼ同一)
Task を書く**前**に必ず挿入される段落。要求は以下の6点。

1. **作業に着手する前に計画を立て、その手順を md ファイルへ書け**(ファイル名は指定される。後述)
2. 計画の**各ステップにチェックボックスを付けよ**
3. **私の確認(clarification)が要るステップには、その旨をステップ内に注記して確認を取れ**
4. **重要な決定を自分で下すな**(*Do not make critical decisions on your own.*)
5. 計画を出したら**私のレビューと承認を求めよ**。承認後に**同じ計画を1ステップずつ実行**せよ
6. **各ステップを終えるたびに計画のチェックボックスを done にせよ**

計画ファイル名は段階ごとに指定される: `user_stories_plan.md` / `units_plan.md` / `design/component_model.md` / `deployment_plan.md`、Code Generation と Build IaC では単に「an md file」。

### 3. Task の記述と承認フレーズ
「**Your Task:** 〈具体的な作業〉」が続く。計画提出後にユーザが返す承認フレーズも例示されており、文面は段階により少しずつ違う:

- 「Yes, I like your plan as in the 〈md file〉. Now exactly follow the same plan. Interact with me as specified in the plan. Once you finish each step, mark the checkboxes in the plan.」
- 「I approve. Proceed.」
- 「I approve the plan. Proceed. After completing each step, mark the checkbox in your plan file.」

いずれも「**計画どおりに、1ステップずつ、チェックボックスを更新しながら**」という同じ拘束を再確認している。

## ブロック 1: Setup Prompt
セッション冒頭で成果物の置き場を確定させるプロンプト。要求内容:

- フロントエンド/バックエンドの**各コンポーネントにプロジェクトフォルダを作る**
- **全ドキュメントは `aidlc-docs` フォルダに置く**
- セッションを通じて「作業の計画を先に立てて md ファイルを作れ」と指示するので、**その計画を承認するまで作業してはならない**
- 計画は常に `aidlc-docs/plans` に保存する
- ドキュメント種別ごとの置き場を固定する(下表)
- **このプロンプトの理解を確認せよ**、および**未作成なら必要なフォルダとファイルを作れ**

| ドキュメント種別 | 置き場 |
|---|---|
| 計画(plan) | `aidlc-docs/plans/` |
| 要件・機能変更 | `aidlc-docs/requirements/` |
| User story | `aidlc-docs/story-artifacts/` |
| アーキテクチャ・設計 | `aidlc-docs/design-artifacts/` |
| **発行した全プロンプト(順序どおり)** | `aidlc-docs/prompts.md` |

> **`prompts.md` に全プロンプトを順序どおり残させる**のがこの規約で最も特徴的な点。成果物だけでなく**プロセスの入力側も再現可能にする**もので、[[ai-dlc]] III 章の "context memory" とトレーサビリティの主張を、最小コストで実装している。

## ブロック 2〜3: Inception
### User stories
- Role: **expert product manager**
- 計画ファイル: `user_stories_plan.md`
- Task: 「**Task 節に記した高レベル要件のための user story を構築せよ**」。要件は `<< describe product descrition>>`(原文ママ。誤記)というプレースホルダで差し込む。
- 目的の明示: 「**システム開発の契約(contract)となる、よく定義された user story を作る**」——[[ai-dlc]] 原則6が user story を「人間と AI の理解を揃える契約」と呼ぶことのプロンプト側の対応物。

### Units
- Role: **experienced software architect**
- 計画ファイル: `units_plan.md`
- Task: 「`mvp_user_stories.md` の user story を参照し、**独立に構築可能な複数の Unit へグルーピング**せよ。各 Unit は**単一チームで構築できる高凝集な user story** を含み、**Unit 同士は疎結合**とする。各 Unit について、その user story と受け入れ基準を `design/` フォルダ内の個別 md ファイルに書け」
- → [[intent-unit-bolt]] の Unit 定義(疎結合・自律開発・独立デプロイ)をそのままプロンプト化したもの。

## ブロック 4〜7: Construction
### Domain (component) model creation
- Role: **experienced software engineer**
- 計画ファイル: `design/component_model.md`
- Task: 「`design/seo_optimization_unit.md` の user story を参照し、**それらを実装するコンポーネントモデルを設計**せよ。モデルには**全コンポーネント・属性・振る舞い・user story を実装するためのコンポーネント間の相互作用**を含めること。**まだコードを生成するな(Do not generate any codes yet)**。コンポーネントモデルは `/design` フォルダ内の別の md ファイルへ書け」
- 「まだコードを生成するな」という明示的な抑止が入る唯一のブロック。設計と実装のフェーズ分離を、プロンプト内の禁止条項で強制している。

### Code Generation
- Role: **experienced software engineer**
- Task 例(2段構え):
  1. 「`search_discovery/nlp_component.md` のコンポーネント設計を参照し、設計にある **NLP コンポーネントの非常にシンプルで直感的な Python 実装**を生成せよ。`processQuery(queryText)` メソッドでは **amazon bedrock API を使ってクエリテキストから entity を抽出**すること。クラスは個別ファイルに生成しつつ `vocabMapper` ディレクトリにまとめよ」
  2. 「`vocabMapper` の生成コードを参照せよ。**EntityExtractor コンポーネントに GenAI を呼ばせたい**。現行実装はローカルの `vocabulary_repository` を使っている。**Entity Extraction と Intent Extraction の双方で GenAI を活用する方法を分析し、計画を出せ**」
- 2段目は「既存の生成コードを読み直させて改善計画を立てさせる」形で、生成 → 検証 → 再計画のループを回す例になっている。

### Architecture
- Role: **experienced Cloud Architect**
- 計画ファイル: `deployment_plan.md`
- 参照させる入力: `design/core_component_model.md`、`UNITS/` フォルダ、`ARCHITECTURE/` フォルダのクラウドアーキテクチャ、`BACKEND/` フォルダのバックエンドコード
- Task:
  - **[CloudFormation, CDK, Terraform] を使った AWS へのバックエンドデプロイの end-to-end 計画**を生成せよ
  - デプロイの**前提条件をすべて文書化**せよ
- 承認後に課される追加の指示:
  - **clean, simple, explainable なコーディングのベストプラクティスに従え**
  - **出力コードはすべて `DEPLOYMENT/` フォルダへ**
  - **生成コードが意図どおり動くことを検証**するため、**validation plan を作り validation report を生成**せよ
  - **validation report をレビューし、特定された問題をすべて修正して report を更新**せよ
- 「検証計画 → 検証レポート → 自己修正 → レポート更新」という**自己検証ループをプロンプトに焼き込んでいる**のはこのブロックのみ。

### Build IaC / Rest APIs
- Role: **experienced software engineer**
- Task: 「`construction/<>/` フォルダ配下の `services.py` を参照し、**そこにある各サービスに対応する Python Flask API を作れ**」

## 何が持ち帰れるか
本 wiki の観点で再利用価値が高いのは、方法論の用語(Unit / Bolt)ではなく**このプロンプト規約のほう**である。

- **plan-then-execute のゲート**: 「チェックボックス付きの計画を先に md へ書け → 承認まで実行するな → 1ステップずつ → 終わるたびにチェック」は、Claude Code の plan mode / ExitPlanMode が harness 側で提供する制御を、**プロンプトだけで再現したもの**。ツールに依存せず任意の LLM で成立する点が強い。
- **「重要な決定を自分で下すな」の常設**: 全ブロックに同一文が入る。[[ai-dlc]] 原則2(人間は approver)を、フェーズ設計でなく**1プロンプトごとの制約**として反復強制している。
- **`prompts.md` への入力の永続化**: 成果物だけでなくプロンプト履歴も残させることで、セッションの再現性を確保する。本 wiki の `wiki/log.md` 追記規約と同じ発想。
- **`aidlc-docs/` のフォルダ規約**: 種別ごとに置き場を固定して AI に作らせる。[[domain-modeling]] の `CONTEXT.md` + `docs/adr/` や、[[open-knowledge-format]] の予約ファイル名と同系統。

> ⚠️ ただしプロンプト集の完成度は高くない: `<< describe product descrition>>` の誤記、参照先ファイル名が節ごとに一貫しない(`mvp_user_stories.md` / `design/seo_optimization_unit.md` / `search_discovery/nlp_component.md` / `design/core_component_model.md` と、`design/` と大文字フォルダ `UNITS/` `ARCHITECTURE/` `BACKEND/` `DEPLOYMENT/` が混在)、Setup Prompt が定めた `aidlc-docs/design-artifacts/` と後続ブロックが使う `design/` が食い違う。**そのままコピーして使える状態ではなく、規約の骨格だけ借りて自分の配置に合わせる必要がある**。(この評価は本 wiki のもの)

## 関連
- [[ai-dlc]] — このプロンプト集が実践対象とする方法論本体。
- [[intent-unit-bolt]] — Units ブロックが生成する成果物の定義。
- [[spec-driven-development]] — 自然言語仕様を第一級成果物とする発想。user story を「契約」と呼ぶ点で一致。
- [[loop-engineering]] — 「prompt する自分をループ設計に置き換える」。本プロンプト集は maker/checker 分離を手動で回す版。
- [[domain-modeling]] — フォルダ規約と設計成果物の永続化という同系統の実装。

## 出典
- `raw/papers/aidlc-method-definition.md` APPENDIX A(Setup Prompt / ##Inception ## User stories / ## Units / ###Construction ## Domain (component) model creation / ##: Code Generation / ##: Architecture / ##: Build IaC/Rest APIs の全7ブロック)。
- 原文は2段組 PDF からの抽出のため、Appendix A はブロックの並び順が入れ替わって出力されている。本ページでは論文の見出し構造(Inception → Construction)に沿って並べ直した。**各ブロックの文面自体は原文どおり**。

---
title: Intent / Unit / Bolt(AI-DLC の成果物階層)
type: concept
aliases:
  - Intent
  - Unit
  - Bolt
  - AI-DLC artefacts
  - Domain Design
  - Logical Design
  - Deployment Unit
tags: [methodology, agentic-development, ddd, aws, sdlc, artifacts]
created: 2026-08-11
updated: 2026-08-11
sources:
  - raw/papers/aidlc-method-definition.md
related:
  - "[[ai-dlc]]"
  - "[[mob-rituals]]"
  - "[[ai-dlc-vs-spec-driven-development]]"
  - "[[domain-modeling]]"
  - "[[design-doc]]"
  - "[[spec-driven-development]]"
---

## 概要
[[ai-dlc]] は「既存実践者が1日でオリエントできること」を原則に掲げ(原則7)、Scrum 等の旧用語との関係を保ちながら用語を刷新した。中核は **Intent → Unit → Bolt** の3階層と、Construction フェーズで連鎖する4つの設計成果物である。

## Intent → Unit → Bolt

| AI-DLC | 定義 | 旧用語での対応 | 誰が作り、誰が検証するか |
|---|---|---|---|
| **Intent** | 何を達成すべきかを包含する**高レベルの目的表明**。ビジネス目標・機能・技術的成果(例: 性能スケーリング)のいずれでもよい | — (Epic の上流にある「意図」) | 人間(Product Owner)が起点として与える |
| **Unit** | Intent から導かれる、**測定可能な価値を届けるための凝集した自己完結の作業要素**。Unit 同士は**疎結合**で、自律的な開発と独立したデプロイを可能にする | DDD の **Subdomain**、Scrum の **Epic** に相当 | AI が Intent を分解して提案。開発者/Product Owner が検証・修正 |
| **Bolt** | AI-DLC の**最小の反復単位**。1つの Unit、または Unit 内のタスク集合を高速に実装する。build-validation サイクルは週でなく**時間または日**で測る | Scrum の **Sprint**(4〜6週)を改名したもの | AI が Bolt を計画。開発者/Product Owner が検証 |

- 各 Unit はタスク集合(この場合 **user story**)を持ち、それが機能スコープを規定する。
- 1つの Unit は**1つ以上の Bolt** で実行され、Bolt は**並列にも逐次にも**走りうる。
- 「Sprint を意図的に改名した」理由は原則7の associative learning——旧概念との対応を保ちつつ、期間の桁が変わったことを名前で示す(*rapid, intense cycles*)。

> ⚠️ 名前が変わっただけか: Unit ≒ Epic、Bolt ≒ Sprint という対応を論文自身が明示しているため、階層構造そのものは Scrum から変わっていない。実質的な差分は **(a) 分解の主体が人間から AI に移ったこと**と **(b) Bolt の時間スケールが週から時間/日になったこと**の2点に絞られる。(この評価は本 wiki の解釈)

## Construction フェーズの成果物連鎖
Unit が確定した後、Construction フェーズは次の順で成果物を積み上げる。各段で人間の検証が入る(→ [[ai-dlc]] の loss function)。

1. **Domain Design** — Unit の**中核ビジネスロジックを、インフラ構成要素から独立にモデル化**する。AI-DLC 第一版では AI が DDD の原則を用い、戦略的・戦術的モデリング要素(aggregate、value object、entity、domain event、repository、factory)を作る。
2. **Logical Design** — Domain Design を**非機能要件(NFR)を満たすように拡張**する。適切なアーキテクチャ設計パターン(例: CQRS、Circuit Breaker)を選ぶ。AI が **Architecture Decision Record(ADR)** を生成し、開発者が検証する。
3. **Code + Unit Tests** — Logical Design の仕様からコードとユニットテストを生成。適切な AWS サービス/construct を選び well-architected 原則に従う。**AI エージェントがユニットテストを実行し、結果を分析して修正案を開発者に提示**する。
4. **Deployment Units** — 運用成果物。パッケージ済み実行コード(例: Kubernetes 向けコンテナイメージ、AWS Lambda 等のサーバレス関数)、設定(例: Helm chart)、インフラ構成要素(例: Terraform / CloudFormation スタック)を含む。AI が機能テスト・静的/動的セキュリティテスト・負荷テストのシナリオを生成し、**人間がテストシナリオとケースを検証・調整した後**に AI エージェントが実行、結果を分析して失敗点をコード変更・設定・依存関係と突き合わせる。

ADR を AI に書かせて人間が検証する形は、[[domain-modeling]](ADR は「覆しにくい・意外・トレードオフの結果」の3条件が揃った時のみ書く)や [[design-doc]] と同じ問題領域を扱う。ただし AI-DLC は**生成のトリガを人間の判断でなく段階遷移に置いている**点が異なる。

## Inception フェーズの出力
[[mob-rituals]] の Mob Elaboration を経て、各 Unit は次の構成要素を伴う:

a) **PRFAQ**(任意) / b) **User Stories** / c) **NFR 定義** / d) **リスク記述**(組織の Risk Register があればそれと突合) / e) business intent に遡れる **Measurement Criteria** / f) その Unit を構築する**推奨 Bolt 群**

user story を残したのは原則6(retain what enhances human symbiosis)による——「人間と AI の理解を揃える、よく定義された**契約**として働く」ため。この「契約としての自然言語仕様」という位置づけは [[spec-driven-development]] の核心と一致する。

## 全成果物に共通する性質
- **永続化**: intent、user story、domain model、テスト計画などの全成果物が保存され、ライフサイクル横断の **"context memory"** として AI に参照される。
- **リンクとトレーサビリティ**: 全成果物が相互リンクされ、前方・後方の追跡が可能(例: domain model の要素 ↔ 特定の user story)。目的は AI が各段で**正しく最も関連の高い context を取り出せる**ようにすること。

## 関連
- [[ai-dlc]] — 本用語群を定義する方法論本体。
- [[mob-rituals]] — これらの成果物を生成・検証する場。
- [[domain-modeling]] / [[design-doc]] — 設計成果物を書き残す実務手法。
- [[spec-driven-development]] — 自然言語仕様を第一級成果物とする発想。

## 出典
- `raw/papers/aidlc-method-definition.md` III 章 1.ARTEFACTS(Intent / Unit / Bolt / Domain Design / Logical Design / Code + Unit Tests / Deployment Units)、III 章 2.PHASES & RITUALS(Inception の出力)、III 章 3.THE WORKFLOW(context memory・トレーサビリティ)、II 章 原則6・原則7。

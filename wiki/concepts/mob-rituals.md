---
title: Mob Elaboration / Mob Construction(AI-DLC の儀式)
type: concept
aliases:
  - Mob Elaboration
  - Mob Construction
  - mob-construction ritual
  - モブエラボレーション
  - AI-DLC rituals
tags: [methodology, agentic-development, team-practice, aws, sdlc]
created: 2026-08-11
updated: 2026-08-11
sources:
  - raw/papers/aidlc-method-definition.md
related:
  - "[[ai-dlc]]"
  - "[[intent-unit-bolt]]"
  - "[[ai-dlc-vs-spec-driven-development]]"
  - "[[one-person-squad]]"
  - "[[grilling]]"
---

## 概要
[[ai-dlc]] は「AI-DLC とは実のところ**儀式(ritual)の集合**である」(VI 章)と述べ、方法論の学習をドキュメントや研修でなく**儀式の実演**で行うことを推奨する。定義されている儀式は **Mob Elaboration**(Inception フェーズ)と **Mob Construction**(Construction フェーズ)の2つ。Scrum の daily standup / retrospective のような「進捗同期のための儀式」は、反復が時間〜日単位になることで**無意味化する**というのが原則1の主張であり、代わりに置かれたのが**この2つの検証儀式**である。

共通する形式は「**単一の部屋に関係者全員が集まり、画面を共有し、AI が出した成果物をその場で集団検証する**」。AI が生成し、mob が承認する——原則2(会話の向きの反転)を場のレベルで具現化したもの。

## Mob Elaboration(Inception フェーズ)
協働的な**要件精緻化と分解**の儀式。ファシリテータが主導し、画面共有のある単一の部屋で行う。

**AI の役割**: Intent の初期分解案を提示する——User Story、Acceptance Criteria、そして [[intent-unit-bolt]] の Unit へ。分解にはドメイン知識と、**疎結合・高凝集**の原則(下流での高速な並列実行を可能にするため)を用いる。

**mob の構成**: Product Owner、開発者、QA、その他の関係者。

**mob の役割**: AI 生成の成果物を集団でレビューし、**under-engineered / over-engineered な部分を調整**して現実の制約に整合させる。

**green-field での具体的な流れ**(IV 章):

1. AI が明確化の質問をする(例: 「主要なユーザは誰か? どのビジネス成果を達成すべきか?」)。目的は元の意図の**曖昧さを最小化**すること。
2. AI が明確化された意図を user story・NFR・リスク記述へ展開。チームが検証し、必要な修正を AI に返す。
3. AI が高凝集な story 群を Unit に構成する(例: "User Data Collection"、"Recommendation Algorithm Selection"、"API Integration")。
4. Product Owner が出力を検証し、必要に応じて Unit を調整。*例: User Data Collection にプライバシー対応の記述が欠けていることに気づき、GDPR 固有の考慮を要件へ追加する。*
5. AI が(任意で)モジュールの **PRFAQ** を生成。ビジネス意図・機能・期待便益を要約する。
6. 開発者と Product Owner が PRFAQ と関連リスクを検証。

論文は「Mob Elaboration は**数週間から数ヶ月に及ぶ逐次作業を数時間に凝縮**しつつ、mob 内部および mob と AI の間の深いアラインメントを達成する」と主張する(実証データの提示はない)。

> AI が先に問いを立ててユーザの曖昧さを潰す、という動線は本 wiki の [[grilling]](`/grill-me`: 計画を関連する質問攻めにして合意形成する Claude Code スキル)と同型。違いは、grilling が1人 vs AI の対話であるのに対し、Mob Elaboration は**集団 vs AI** である点。

## Mob Construction(Construction フェーズ)
Unit を Deployment Unit へ変換する反復実行の場。論文は「Mob Elaboration と同様に**全チームが単一の部屋に同席**して行うことを推奨する」とし、これを *mob-construction ritual* と呼ぶ。チームは(domain model 段階で得た)**統合仕様を交換**し、決定を下し、それぞれの Bolt を届ける。

**AI の役割**: フェーズ全体を通してタスクを推奨し、各タスクで選択肢(設計パターン、User Experience、テスト等)を提示する。

**green-field での具体的な流れ**(IV 章。論文本文は "Mob Programming and Mob Testing rituals" とも表記する):

1. 開発者が AI とのセッションを確立。AI が担当 Unit から始めるよう促す。
2. AI が DDD 原則で担当 Unit の中核ビジネスロジックをモデル化。*例: "Recommendation Algorithm" Unit で Product / Customer / Purchase History といった entity と関係を特定。*
3. 開発者が domain model をレビュー・検証し、現実シナリオとの整合を確認(*例: 新規顧客で購買履歴が無い場合の扱い*)。
4. AI が domain model を logical design へ翻訳し、スケーラビリティ・耐障害性等の NFR を適用。*例: event-driven design と AWS Lambda を推奨。*
5. 開発者が推奨を評価しトレードオフを承認、必要なら追加考慮を提案(*例: スケーラビリティのため Lambda は受け入れるが、クエリ性能のためストレージを DynamoDB に上書き*)。
6. AI が Unit ごとの実行可能コードを生成し、論理コンポーネントを具体的な AWS サービスへマップ。
7. AI が機能・セキュリティ・性能テストも自動生成。
8. 開発者が生成コードとテストシナリオ/ケースをレビューし、必要な調整を行う。

**Testing and Validation**: AI が全テストを実行して結果を分析・問題を提示 → 失敗テストの修正案を提案(例: クエリロジックの最適化)→ 開発者が所見を検証し修正を承認、必要に応じて再実行。

## Brown-field での差分
Inception と Operations は green-field と同じ。Construction のみ**2ステップが前置**される(V 章):

1. AI が既存コードを**より高レベルのモデリング表現へ「引き上げる」**。**static model**(コンポーネント、説明、責務、関係)と **dynamic model**(最も重要なユースケースをコンポーネントがどう相互作用して実現するか)から成る。
2. 開発者がプロダクトマネージャと協働して、**AI がリバースエンジニアリングした static / dynamic model をレビュー・検証・修正**する。

目的は「AI へ渡す context を簡潔かつ正確にする」こと。既存コードそのものより、抽出されたモデルのほうが良い context になるという判断であり、[[context-compression]] / [[context-rot]] が扱う「何を読ませるか」の問題と同じ論点を、**設計モデルへの引き上げ**という手段で解いている。

## 批判的注記
- **同室・同期の要求**: 両儀式とも「単一の部屋に全員」を明示的に推奨する。AI が非同期・並列実行を可能にするという方法論の前提と、この同期性の要求は緊張関係にある。論文はこの矛盾に触れていない。
- **[[one-person-squad]] との非互換**: 儀式が Product Owner・開発者・QA・その他ステークホルダーの同席を前提とするため、1人が複数エージェントを指揮する構成には**そのままでは適用できない**。原則8(専門サイロの解消による役割数の削減)と、mob の人数要求も方向が逆に見える。
- **儀式の実効性が未検証**: 「数週間〜数ヶ月が数時間に」という効果主張に、事例・測定が添えられていない。

## 関連
- [[ai-dlc]] — 儀式を含む方法論本体。
- [[intent-unit-bolt]] — 儀式が生成・検証する成果物。
- [[grilling]] — AI 側から問いを立てて曖昧さを潰す対話パターン(1人版)。
- [[one-person-squad]] — mob 前提と対照的なチーム構成。

## 出典
- `raw/papers/aidlc-method-definition.md` III 章 2.PHASES & RITUALS(Mob Elaboration の定義、Construction フェーズと mob-construction ritual)、IV 章 1〜2(green-field の Inception / Construction の具体手順、Testing and Validation)、V 章 2(brown-field の追加ステップ)、VI 章(儀式の集合としての AI-DLC、Learning by Practicing)。

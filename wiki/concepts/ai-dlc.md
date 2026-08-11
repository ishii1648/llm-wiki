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
  - "[[aidlc-prompt-kit]]"
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

## I. CONTEXT: 抽象化の系譜と2つの時代区分

### 論証の土台: ソフトウェア工学は「下位の非差別化タスクの抽象化」を続けてきた
論文の出発点は、ソフトウェア工学の進化を**「開発者が複雑な問題の解決に集中できるようにするため、より低レベルで非差別化(undifferentiated)なタスクを抽象化し続けてきた連続的な探求」**と捉えることである。初期の機械語から高級プログラミング言語へ、そして API とライブラリの採用へ——**各段階が開発者の生産性を有意に押し上げてきた**。LLM の統合はこの系譜の最新段階であり、コード生成・バグ検出・テスト生成といったタスクに**会話的な自然言語インタラクション**を持ち込んだ。

この「AI もまた抽象化の一段である」という位置づけが、後続の全主張の土台になっている。AI を特別視するのでなく**抽象化の系譜に置く**ことで、「ならば方法論も更新されるべきだ」という結論を導く構成。

### AI-Assisted era → AI-Driven era
- **AI-Assisted era**: コード生成・バグ検出・テスト生成といった**細粒度で特定の(fine-grained, specific)タスク**を AI が増強する段階。知的な重労働の大半は依然として開発者が負う。
- **AI-Driven era**: AI の適用が要件精緻化(requirements elaboration)・計画・タスク分解・設計・開発者とのリアルタイム協働へと拡がり、AI が**開発プロセスを能動的にオーケストレートする**段階。論文はこのシフトが「kick-start しつつある」と述べる。

### なぜ既存手法では足りないのか
論文の批判は3点に整理できる。

1. **設計前提のずれ**: 既存のソフトウェア開発手法は**人間主導で長時間走るプロセス(human-driven, long-running processes)向けに設計**されており、AI の速度・柔軟性・先進的能力(例: agentic)に**完全には整合していない**。
2. **制約の所在**: それらの手法が依存する**手作業のワークフロー(manual workflows)と硬直的な役割定義(rigid role definitions)** が、AI を十分に活用する能力を制限している。
3. **retrofit の害**: AI をこれらの手法に後付けすることは、AI のポテンシャルを制限するだけでなく、**旧来の非効率を強化してしまう(reinforces outdated inefficiencies)**。

したがって「AI の変革力を十全に活かすには SDLC 手法自体が再構想される必要がある」。そしてその再構想が要求するのは、**AI を中心的な協働者(central collaborator)に据え、ワークフロー・役割・反復を整合させること**であり、それによって意思決定の高速化・シームレスなタスク実行・継続的な適応性が可能になる、というのが論文の主張。

> この「control plane としての AI」という捉え方は [[agentic-engineering]] と同じ地平にあるが、AI-DLC は**方法論(フェーズ・儀式・成果物)として具体化**している点が異なる。

## II. KEY PRINCIPLES(10 の原則)
論文自身が「これらの原則が AI-DLC のフェーズ・役割・成果物・儀式を形づくる基盤であり、手法の妥当性を検証するうえで critical な前提である」と位置づける章。以下は各原則の論証を含めた記述。

### 1. Reimagine rather than retrofit(後付けでなく再構想する)
SDLC や Agile(Scrum 等)を維持して AI を後付けするのではなく、開発手法そのものを再構想する。理由は**反復期間の桁が変わること**にある。

- 従来手法は**月・週単位の長い反復期間**のために作られており、そこから daily standup や retrospective といった儀式が生まれた。
- 対して AI の適切な適用は**時間または日単位の rapid cycle** をもたらす。これは**継続的でリアルタイムな検証とフィードバックの仕組み**を必要とし、**従来の儀式の多くを無意味化(less relevant)する**。

論文はさらに2つの問いを投げる: **AI が simple / medium / hard の境界を薄める(diminishes)なら、工数見積り(story point 等)は依然として critical か?** **velocity のようなメトリクスは意味を持つのか、それとも例えば Business Value に置き換えるべきか?**

加えて、AI は計画・タスク分解・要件分析・設計技法の適用(例: domain modelling)といった**手作業の実践を自動化する方向に進化し続けており、意図からコードへ至るまでのフェーズ数そのものを短縮している**。これらの新しい力学が、retrofit ではなく**第一原理思考(first principles thinking)に基づく再構想**を正当化する。締めの一文は「**我々に必要なのは自動車であって、より速い馬車ではない**」。

### 2. Reverse the conversation direction(会話の向きを反転する)
AI-DLC の中核。**人間が AI に会話を仕掛けてタスクを片付けさせるのでなく、AI が人間との会話を起こし、方向づける**という根本的な転換。

- AI は高レベルの intent(例: 新しいビジネス機能の実装)を実行可能なタスクへ分解し、**推奨を生成し、トレードオフを提示する**ことでワークフローを駆動する。
- 人間は **approver** として働く——検証し、選択肢を選び、critical な分岐点で決定を確定する。

この配置により、開発者は**高価値な意思決定**に集中でき、計画・タスク分解・自動化は AI が担う。伝統的な力学を反転させることで、AI-DLC は**人間の関与を purposeful なものにし、監督・リスク低減・戦略的整合に集中させる**——結果として velocity と品質の双方を高める、というのが主張。

アナロジーは **Google Maps**: 人間が目的地(= intent)を設定し、システムが逐次の道案内(= AI のタスク分解と推奨)を提供する。道中、人間は監督を保ち、必要に応じて journey を調整する。

### 3. Integration of design techniques into the core(設計技法をコアに統合する)
Scrum や Kanban のような Agile フレームワークは、設計技法(例: Domain Driven Design)を**スコープ外に置き、チーム自身に選ばせる**。論文はこれが「critical な whitespace を残し、結果として全体的なソフトウェア品質の低下を招いた」と主張する。根拠として **2022 年に米国だけでソフトウェア品質問題が $2.41 兆のコストを生んだという推計**を挙げる。

そこで AI-DLC は設計技法を切り離すのでなく**その integral core とする**。**DDD / BDD(Behavior Driven Development)/ TDD(Test-Driven Development)にそれぞれ従うチーム向けの異なるフレーバーが存在する**と述べ、本論文は **DDD フレーバー**を扱う。DDD 版は DDD の原則を用いて、システムを**独立した right-sized な bounded context** に分解し、それらを**並列に高速構築できる**ようにする。

AI は計画とタスク分解の過程でこれらの技法を**内在的に(inherently)適用**し、開発者には検証と調整だけを求める。この統合こそが、**手作業の重労働を排しつつソフトウェア品質を保ったまま、時間単位・日単位の反復サイクルを可能にする鍵**である——マントラは「**Build Better Systems Faster**」。

### 4. Align with AI capability(AI の実力に合わせる)
論文は AI の将来ポテンシャルには楽観的だが、**現状については完全に現実的**であると宣言する。

- AI-DLC は、現在の AI が進歩しているとはいえ、**高レベルの意図を自律的に実行可能コードへ翻訳することにも、人間の監督なしに独立して動作すること(かつ解釈可能性と安全性を担保すること)にも、まだ信頼できない**と認識する。
- 同時に、開発者が知的な重労働の大半を担い **AI は単なる augmentation を提供するにすぎない AI-Assisted パラダイムでは、開発における AI のポテンシャルを解放できない**。

そこで AI-DLC は **AI-Driven パラダイム**を採る——現在の AI の能力と限界に対して人間の関与をバランスさせるもの。ここで**開発者は検証・意思決定・監督の ultimate responsibility を保持する**。このバランスにより、開発者の判断が提供する critical な safeguard を損なうことなく AI の強みを活かせる。

### 5. Cater to building complex systems(複雑なシステムの構築を対象とする)
AI-DLC の対象は、次を要求するシステム:

- 継続的な機能適応性(continuous functional adaptability)
- 高いアーキテクチャ複雑度
- 多数のトレードオフ管理
- スケーラビリティ
- 統合(integration)およびカスタマイズ要件

これらは**先進的な設計技法・パターン・ベストプラクティスの適用**を必要とし、典型的には**大規模および/または規制下の組織において、複数チームが凝集的に協働する**形をとる。

**スコープ外**: 非開発者ペルソナが構築でき、トレードオフ管理をほとんど/まったく必要としない単純なシステム。これらは **low-code / no-code アプローチに適している**。

### 6. Retain what enhances human symbiosis(人間との共生を高めるものは残す)
再構想にあたり、既存手法の成果物・接点のうち**人間による検証とリスク低減に critical なものは残す**。

- **user story**: 人間と AI の「何を作るべきか」の理解を揃え、**よく定義された契約(well-defined contracts)** として働く。再構想後の手法でも**そのまま残す**。
- **Risk Register**: AI が生成した計画とコードが組織のリスクフレームワークに準拠することを保証する。

これら retain された要素は**リアルタイム利用向けに最適化**され、整合性や安全性を損なわずに高速な反復を可能にする。

### 7. Facilitate transition through familiarity(馴染みを通じて移行を容易にする)
新手法は**大がかりな研修を要求してはならず、既存の実践者なら1日でオリエントして実践を始められる**べきである。**連想学習(associative learning)による容易な採用**を支えるため、AI-DLC は**旧手法の馴染みある用語間の関係性を保存しつつ、用語を近代化する**。

例として Scrum の **Sprint** は「構築と検証のための反復サイクル」を表すが、pre-AI 時代には通常 4〜6 週間だった。AI-DLC では反復サイクルが継続的かつ時間・日の単位になる。**だから Sprint を意図的に改名する必要がある**——AI-DLC は Sprint を **Bolt** にリブランドし、前例のない velocity をもたらす**高速で intense なサイクル**を強調する。(詳細は [[intent-unit-bolt]])

### 8. Streamline responsibilities for efficiency(責務を合理化する)
AI がタスク分解と意思決定を行える能力を活かすことで、開発者は **infrastructure / front-end / back-end / DevOps / security といった従来の専門サイロを超越(transcend)できるようになる**。この責務の収斂は**複数の専門役割の必要性を減らし**、開発プロセスを合理化する。

ただし **Product Owner と開発者はフレームワークに不可欠なものとして残る**。監督・検証・戦略的意思決定という critical な責務を保持し、ビジネス目標との整合、設計品質の維持、リスク管理フレームワークへの準拠を担保することで、**自動化と人間のアカウンタビリティの均衡を保つ**。

方法論の定義においては**第一原理に忠実に、役割は最小限に留め、critical に必要な場合にのみ追加の役割を導入する**。

### 9. Minimise stages, maximise flow(段階を最小化し、フローを最大化する)
自動化と責務の収斂を通じて、AI-DLC は**ハンドオフと遷移を最小化**し、継続的な反復フローを可能にする。

だが人間の検証と意思決定は依然として critical である。理由は **AI が生成したコードが硬直化して('quick-cement')しまわず、将来の反復に向けて適応可能なままであることを保証する**ため。この目的のために、AI-DLC は**人間の監督のために特別に設計された、最小限だが十分な数のフェーズ(minimal but sufficient number of phases)** を critical な決定分岐点に組み込む。

**これらの検証は "loss function" の一形態として働く**——無駄な下流作業を、それが発生する前に特定し刈り取る。

### 10. No hard-wired, opinionated SDLC workflows(決め打ちのワークフローを持たない)
AI-DLC は、開発の経路(pathway)ごとに固定的なワークフローを規定しない。経路の例: **新規システム開発、リファクタリング、欠陥修正、マイクロサービスのスケーリング**。

代わりに**真に AI-First なアプローチ**を採る——与えられた経路の意図に基づいて **AI が Level 1 Plan を推奨**する。人間は AI との**対話的なダイアログ**を通じてこの AI 生成計画を検証・調整し、そのプロセスを **Level 2(サブタスク)以降の階層レベル**へと続けていく。タスク実行レベルでは AI がタスクを実装し、人間は成果の verification と validation を通じて監督を保つ。

この柔軟なアプローチにより、**critical な決定に対する人間の制御を保ちながら、方法論が AI の能力の進化とともに進化できる**。

> 原則1と原則7は緊張関係にある。「第一原理から作り直す」と言いつつ、採用容易性のために旧用語との対応を保つ(Unit ≒ Epic、Bolt ≒ Sprint)。論文自身「AI-DLC は既存 Agile 手法から大きくは逸脱しない」(VI 章)と述べており、**再発明の主張は用語の刷新に比べて実質が薄い**と読むこともできる。(この評価は本 wiki の解釈)

## III. CORE FRAMEWORK

### 成果物
Intent / Unit / Bolt の階層と、Domain Design → Logical Design → Code+Unit Tests → Deployment Units の連鎖は [[intent-unit-bolt]] に分けて記述する。

### フェーズと儀式
儀式(Mob Elaboration / Mob Construction)の詳細な手順は [[mob-rituals]]。ここでは3フェーズの骨子のみ。

- **Inception Phase** — Intent を捉え、開発のための Unit に翻訳する。儀式は **Mob Elaboration**(協働的な要件精緻化・分解の儀式。ファシリテータ主導、画面共有のある単一の部屋)。出力は well defined な Unit 群と、その a) PRFAQ、b) User Stories、c) NFR 定義、d) リスク記述(組織の Risk Register があればそれと突合)、e) business intent に遡れる Measurement Criteria、f) その Unit を構築しうる推奨 Bolt 群。
- **Construction Phase** — Inception で定義された Unit を、テスト済みで運用可能な Deployment Unit へ変換する反復実行。**Domain Design**(AI が技術的考慮から独立にビジネスロジックをモデル化)→ **Logical Design**(NFR と適切なクラウド設計パターンを適用)と進み、AI が Logical Design から詳細コードを生成(コンポーネントを適切な AWS サービスへマップし well-architected 原則に従う)、最後に機能性・セキュリティ・運用準備性を保証する自動テストで締める。開発者は各ステップで AI 生成物の検証と critical な決定に集中する。ブラウンフィールドでは、まず既存コードを**意味的に豊かなモデル表現へ「引き上げる」**(→ [[mob-rituals]])。
- **Operations Phase** — システムのデプロイ・observability・保守を、AI を活かして運用効率化する。AI は**テレメトリデータ(メトリクス・ログ・トレース)を能動的に解析**してパターン検出・異常特定・**SLA 違反の予測**を行い、事前の問題解決を可能にする。さらに AI は**あらかじめ定義された incident runbook と統合**し、リソースのスケーリング・性能チューニング・障害隔離といった実行可能な推奨を提示、**開発者が承認したら解決策を実行する**。開発者は validator として、AI 生成の洞察と提案アクションが SLA とコンプライアンス要件に整合していることを保証する。

### ワークフロー: Level 1 Plan と再帰的分解
business intent(例: **Green-Field 開発、Brown-Field 拡張、モダナイゼーション、欠陥修正**)を与えると、AI-DLC はまず AI に **Level 1 Plan**——その intent を実装するワークフローを概説する計画——を生成させる。これは**初期の提案(initial proposal)にすぎず**、ビジネス目標とエンジニアリング制約への整合を保証するため、人間が**透過的にレビュー・検証・洗練**する。

AI-DLC の中心にあるのは、**人間の監督を適用して各ステップの成果物を漸進的に豊かにし、それを次のステップのための意味的に豊かな context へ変換していく**という原則である。**各ステップは戦略的な決定点(strategic decision point)であり、そこでの人間の監督は loss function のように機能する**——誤りを早期に捕捉・訂正し、下流で雪だるま式に膨らむ前に止める。**これが再帰的に繰り返される**。Level 1 Plan の各ステップは、AI によってさらに細粒度の実行可能サブタスクへ分解され、正確さと文脈的妥当性を保証するためこれも人間の監督下に置かれる。

生成された全成果物(intent、user story、domain model、テスト計画)は**永続化され、AI がライフサイクル横断で参照する "context memory" として働く**。従来の SDLC 手法と同様、AI-DLC も本質的に反復的であり、継続的な洗練と適応を許す。さらに**全成果物がリンクされ、後方・前方のトレーサビリティ**(例: domain model の要素を特定の user story に接続する)を持つことで、AI が各段階で正しく最も関連の高い context を取得できるようにする。

プロセス全体を通して、**AI が戦略的計画・タスク分解・生成等を行い、人間が監督と検証を提供する**。

> この「成果物を永続化して context memory にする」設計は、[[loop-engineering]] の memory 論、[[open-knowledge-format]] / [[knowledge-bundle]] の「markdown ディレクトリツリーが知識の配布単位」という発想、そして本 wiki 自身の運用と同じ骨格を持つ。Appendix A のプロンプトでは、それが `aidlc-docs/` 以下の md ファイル規約として具体化されている(→ [[aidlc-prompt-kit]])。

## IV / V. AI-DLC IN ACTION
Green-Field / Brown-Field の具体的な進行(Inception の a〜f、Construction の a〜h、Testing and Validation、Operations の Deployment / Observability、Brown-Field の追加2ステップ)は [[mob-rituals]] に記述する。

出発点の例として論文が挙げるのは、Product Owner が **"Develop a recommendation engine for cross-selling products."**(クロスセル商品のレコメンドエンジンを開発する)という高レベル intent を articulate するところから。AI はこれを**新規アプリケーション構築の intent と認識**し、前節のワークフロー手順に沿った Level 1 Plan を生成する。チームが検証・確認し、Level 1 Plan の段階を追加・修正する。確定した Level 1 Plan をもって AI は Inception Phase へ進む。

## Appendix A: プロンプト集
論文は付録に、AI-DLC を実践するための具体的プロンプト(Setup / User stories / Units / Domain model / Code Generation / Architecture / Build IaC・REST APIs)を載せている。**方法論本体より運用規律に踏み込んでおり、実務的な再利用価値が最も高い部分**。全 7 ブロックの構造・指定ファイル名・承認フレーズは [[aidlc-prompt-kit]] に独立して記述する。

骨子だけ挙げると:

- 全ドキュメントを `aidlc-docs/` 配下の決まったサブフォルダに置かせ、**発行した全プロンプトを順序どおり** `aidlc-docs/prompts.md` に保存させる。
- 各段は「Your Role: あなたは経験ある〈…〉である」でロールを与えた後、必ず**作業前にチェックボックス付きの計画を md へ書かせ**、**承認まで実行させず**、**重要な決定を勝手に下させない**。

## VI. ADOPTING AI-DLC
論文は「AI-DLC は既存 Agile 手法から大きくは逸脱せず、容易な採用を key outcome として設計されている」としつつ、伝統的手法を長く実践してきた組織や、独自の AI-Native 手法を発明しつつある組織には固有の採用戦略が要るとして、2つのアプローチを挙げる。

- **Learning by Practicing** — AI-DLC は実のところ**グループで実践できる儀式の集合**(Mob Elaboration、Mob Construction 等)である。ドキュメントや伝統的な研修で手法を学ばせるのでなく、**実践者が現に解いている複数の実世界シナリオ**において、AI-DLC ガイドとともに儀式を実践させる。AWS のソリューションアーキテクトは、このアプローチを大規模組織での hyper-scaling な採用向けにパッケージした **AI-DLC Unicorn Gym** という field offering を作っている。
- **Developer Experience ツールへの埋め込み** — 顧客は SDLC 横断で開発者に統一体験を提供する独自のオーケストレーションツールを構築している(例: Cognizant の **FlowSource**、Aspire の **CodeSpell**、HCL の **AIForce**)。これらのツールに AI-DLC を埋め込めば、大規模組織の開発者は**大がかりな採用ドライブなしにシームレスに AI-DLC を実践する**ことになる。

## 批判的注記
- **AWS ベンダー色**: 成果物の説明が「適切な AWS サービスと construct を選ぶ」「well-architected 原則に従う」を前提とし、例示も Lambda / DynamoDB / API Gateway / CloudFormation に寄っている。方法論の骨格自体はクラウド非依存に読めるが、**論文としては AWS 実装を既定としている**。
- **未検証の引用**: 「米国だけでソフトウェア品質問題が 2022 年に $2.41 兆のコスト」という数字は原文で "(study)" とリンクされているのみで、抽出テキストにリンク先が残っていない(CISQ の報告と推測されるが未確認)。またこの数字を「Agile が設計技法を外出しにしたこと」に帰属させる論証は原文にはない。
- **実証データが皆無**: 「Mob Elaboration は数週間〜数ヶ月の逐次作業を数時間に凝縮する」「反復サイクルは時間〜日で回る」といった効果の主張に、事例・測定・比較対照が一切添えられていない。[[ai-productivity-task-vs-output]] が整理した「タスク利得は本番出力に翻訳されるとは限らない」という論点に照らすと、**Inception の高速化がデリバリ全体の高速化を意味するかは未証明**。
- **文書としての完成度**: 原文には `responsibiliti4es`、`CONSTRUCTTION`、`brown-filed`、"The Construction Phase The encompasses" 等の誤記が残る。査読を経ていないドラフト相当の文書として扱うのが妥当。
- **儀式の物理前提**: Mob Elaboration も Mob Construction も「**単一の部屋に全員が集まる**」ことを明示的に推奨している(→ [[mob-rituals]])。AI が非同期・並列を可能にするという方法論の主張と、この同期・同室の要求は緊張関係にある。
- **BDD / TDD フレーバーは未公開**: 原則3は DDD / BDD / TDD の3フレーバーが「存在する」と書くが、本論文が定義するのは DDD 版のみ。他2つは予告に留まる。

## 関連
- [[intent-unit-bolt]] — AI-DLC の成果物階層と Scrum 用語との対応。
- [[mob-rituals]] — Mob Elaboration / Mob Construction の儀式と green-field / brown-field の具体手順。
- [[aidlc-prompt-kit]] — Appendix A のプロンプト集(全7ブロック)。
- [[ai-dlc-vs-spec-driven-development]] — SDD / one-person-squad / agentic engineering との突合。
- [[agentic-engineering]] — 「AI をデリバリ全体の control plane と見る」上位概念。AI-DLC はその方法論的具体化。
- [[spec-driven-development]] — 仕様を第一級成果物にする発想。AI-DLC の user story / Domain Design 連鎖と重なる。
- [[one-person-squad]] — 実証事例側。AI-DLC の原則8(専門サイロの解消)と対応。
- [[domain-modeling]] — DDD 語彙と ADR をセッション中に書き残す実装例。AI-DLC の Domain Design / ADR 生成に対応。

## 出典
- `raw/papers/aidlc-method-definition.md`(Raja SP, Amazon Web Services)— I 章(抽象化の系譜、AI-Assisted / AI-Driven の区分、既存手法批判)、II 章(10 原則)、III 章(成果物・フェーズ・ワークフロー)、IV/V 章(green-field / brown-field)、VI 章(導入)、Appendix A(プロンプト集)。
- 原本 PDF: `https://prod.d13rzhkk8cj2z0.amplifyapp.com/aidlc.pdf`(2026-08-11 取得)。

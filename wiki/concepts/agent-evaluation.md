---
title: Agent Evaluation(エージェント評価)
type: concept
aliases: [agent evaluation, agent evals, エージェント評価, evals, evaluation harness, agent harness, scaffold, transcript, trajectory]
tags: [evaluation, evals, llm-agents, testing, benchmark, anthropic]
created: 2026-08-29
updated: 2026-08-29
sources:
  - raw/articles/demystifying-evals-for-ai-agents.md
related:
  - "[[graders]]"
  - "[[capability-vs-regression-evals]]"
  - "[[pass-at-k]]"
  - "[[eval-driven-development]]"
  - "[[evaluators]]"
  - "[[strands-agents-evals]]"
  - "[[agent-loop]]"
  - "[[agentic-engineering]]"
---

## 概要
**Evaluation(eval / 評価)** とは「AI に入力を与え、その出力に採点ロジックを当てて成功を測るテスト」。本ページはそのうち**実ユーザーなしに開発中回せる automated evals**、特に**エージェントの評価**を扱う。エージェントは多ターンにわたりツールを呼び state を変えながら適応するため、単発の prompt/response より評価が難しい。eval がないチームは「本番でしか問題に気づかず、1つ直すと別が壊れる」反応的ループに陥る(出典: Anthropic, 2026-01-09)。

このページは評価まわりのハブ。採点ロジックの設計は [[graders]]、評価の性格づけは [[capability-vs-regression-evals]]、非決定性の指標は [[pass-at-k]]、ゼロから作る手順は [[eval-driven-development]] を参照。

## エージェント評価の語彙

出典記事が採用する定義。この語彙が揃っていないと議論が噛み合わない。

| 用語 | 定義 |
|---|---|
| **task**(problem / test case) | 入力と成功基準が定義された1件のテスト |
| **trial** | task への1回の試行。出力がぶれるため複数 trial を回す |
| **grader** | エージェントの性能の一側面を採点するロジック。1 task に複数 grader、1 grader に複数 assertion(**check**) |
| **transcript**(trace / trajectory) | trial の完全な記録。出力・ツール呼び出し・推論・中間結果すべて。Anthropic API では eval 実行終了時点の messages 配列全体 |
| **outcome** | trial 終了時の**環境の最終状態** |
| **evaluation harness** | eval を end-to-end で回す基盤。指示とツールの提供、task の並行実行、記録、採点、集計 |
| **agent harness**(**scaffold**) | モデルをエージェントとして動かすシステム。入力処理・ツール呼び出しのオーケストレーション・結果返却 |
| **evaluation suite** | 特定の能力・挙動を測る task の集合。1つの広い目標を共有する |

### outcome と transcript を分ける意味
フライト予約エージェントが transcript の末尾で「予約が完了しました」と言っても、**outcome は環境の SQL データベースに予約行が存在するか**である。発話ではなく状態を見る、というのが agent eval の核心の一つ。

### 「エージェントを評価する」= harness × モデル
「an agent を評価する」とき、実際に評価しているのは **agent harness とモデルの組**である。例として [[loop-engineering]] でも触れる Claude Code は柔軟な agent harness であり、Anthropic はその中核プリミティブを Agent SDK 経由で使って long-running agent harness を組んだ。
→ eval のスコアが低いとき、原因はモデル・harness・task 仕様・grader のどこにでもありうる([[graders]] の「eval 自体のバグ」参照)。

## なぜエージェントは評価が難しいか
- 多ターンでツールを使い state を変えるため、**ミスが伝播・複利で増幅**する。
- frontier モデルは静的な eval の想定を超える創造的な解を見つける。Opus 4.5 は 𝜏2-bench のフライト予約問題でポリシーの抜け穴を発見し、eval の定義上は「失敗」しつつユーザーにとってはより良い解を出した。
  > ⚠️ ここは「eval のスコア = 良さ」ではないことの明確な反例。スコアを額面どおり受け取らず transcript を読む根拠になる([[eval-driven-development]] Step 6)。

## なぜ eval を作るか
初期は手動テスト・dogfooding・直感でかなり進める。破綻点は「変更後にエージェントが悪くなった気がする」とユーザーが報告し、当て推量以外に検証手段がないとき。eval がないと、回帰とノイズを区別できず、出荷前に数百シナリオで自動テストもできず、改善を測れない。

記事が挙げる効用:
- **仕様の明確化**: 同じ初期スペックを読んだエンジニア2人がエッジケースの扱いで異なる解釈に至る、という曖昧さを eval suite が解消する。
- **新モデル採用速度**: eval のないチームは検証に数週間、あるチームは数日で強み把握・prompt 調整・アップグレードまで到達する。
- **ベースラインと回帰テストが副産物として手に入る**: レイテンシ、トークン使用量、task あたりコスト、エラー率。
- **プロダクト↔リサーチ間の最も帯域の広いコミュニケーション経路**になり、研究側が最適化する指標を定義する。

> コストは先に見え、便益は後から積み上がるため、複利的な価値が過小評価されやすい。

### 事例
- **Claude Code**: 社内外フィードバックによる高速反復から始め、後から eval を追加。まず concision や file edit のような狭い領域、次に over-engineering のような複雑な挙動へ。
- **Descript**(動画編集エージェント): 「壊さない / 頼んだことをやる / うまくやる」の3次元で eval を設計。手動採点 → プロダクトチームが基準を定義した LLM grader + 定期的な人間キャリブレーション → 品質ベンチマークと回帰テストの2 suite 運用へ進化。
- **Bolt**: 既に広く使われるエージェントを持ってから着手し、3か月で「エージェント実行 + static analysis 採点 + ブラウザエージェントによるアプリ検証 + 指示追従などの LLM judge」を構築。

## エージェント種別ごとの評価
記事は現在スケールして運用されている4種を挙げ、それぞれ実績のある手法を示す。ゼロから発明する必要はなく、これらを土台に自分のドメインへ広げる。

### コーディングエージェント
コードは「動くか / テストが通るか」で決定論的に測れるため決定論的 grader が自然。
- **SWE-bench Verified**: 人気 Python リポジトリの GitHub issue を与え、テストスイート実行で採点。失敗テストを直しつつ既存テストを壊さない場合のみ合格。1年で 40% → 80%超。
- **Terminal-Bench**: Linux カーネルのソースビルドや ML モデル訓練など end-to-end の技術タスク。
- outcome の pass/fail を押さえたうえで **transcript も採点する**と有用(ヒューリスティックなコード品質ルール、ツールの呼び方やユーザーとの対話を測る rubric ベースの model grader)。
- 実務では「正当性 = ユニットテスト、全体のコード品質 = LLM rubric」が基本形で、他の grader は必要に応じて足す。

### 会話エージェント
support / sales / coaching など。従来のチャットボットと違い state を持ち、会話の途中でツールを使い行動する。**相互作用の質そのものが評価対象**という点が固有の難しさ。
- 検証可能な end-state outcome と、task 完了・対話品質の双方を捉える rubric を併用する。
- 他の eval と違い、**ユーザーをもう1つの LLM でシミュレートする**ことが多い。Anthropic は alignment auditing agents でこの手法を使い、長い敵対的会話でモデルをストレステストしている。
- 成功は多次元: チケットは解決したか(state check)、10ターン未満で終わったか(transcript 制約)、トーンは適切か(LLM rubric)。
- ベンチマーク: **𝜏-Bench** とその後継 **τ2-Bench**(小売サポート・航空券予約などで、一方のモデルがユーザーペルソナを演じる)。
- 「質問に答える」ような task は正解が複数ありうるため、実務では model-based grader が主体になる。

### リサーチエージェント
情報を収集・統合・分析して回答やレポートを出す。ユニットテストのような二値信号がなく、**品質は task 相対でしか判断できない**(「網羅的」「出典が良い」の基準が市場調査・買収デューデリ・科学レポートで異なる)。
- 固有の困難: 専門家間でも「網羅的か」の意見が割れる、参照コンテンツが変わり ground truth が動く、出力が長く開放的なほど誤りの余地が増える。
- ベンチマーク例: **BrowseComp**(検証は容易だが解くのが難しい、オープンウェブ上の「干し草の中の針」)。
- 戦略は grader の組み合わせ: **groundedness チェック**(主張が取得ソースに支持されるか)、**coverage チェック**(良い回答が含むべき鍵事実の定義)、**source quality チェック**(最初に引っかかっただけでなく権威あるソースか)。客観的正解のある task(「X 社の Q3 売上は?」)は exact match。
- 主観性が高いため、LLM rubric は**専門家の判断と頻繁にキャリブレーション**すること。

### コンピュータ利用エージェント
API やコード実行ではなく、スクリーンショット・マウス・キーボード・スクロールという人間と同じインタフェースで GUI を操作する。実環境またはサンドボックスで動かし、意図した outcome を達成したか確認する。
- **WebArena**: URL とページ状態でナビゲーションを検証し、データを変更する task ではバックエンド状態も検証する(確認ページが出ただけでなく、実際に注文が入ったか)。
- **OSWorld**: OS 全体の操作へ拡張。完了後にファイルシステム状態・アプリ設定・DB 内容・UI 要素プロパティなど多様な artifact を検査する。
- **ブラウザ利用はトークン効率とレイテンシのトレードオフ**: DOM ベースは速いがトークンを食い、スクリーンショットベースは遅いがトークン効率が良い。Wikipedia の要約なら DOM 抽出が効率的、Amazon でノートPCケースを探すならスクリーンショットが効率的。Claude for Chrome では**文脈ごとに正しいツールを選べているか**を測る eval を作り、ブラウザタスクを高速かつ正確にした。

## eval だけでは足りない: 手法の重ね合わせ
automated eval は本番へ出さずに数千 task を回せるが、エージェント性能を理解する方法の1つにすぎない。

| 手法 | 強み | 弱み |
|---|---|---|
| **Automated evals**(実ユーザーなしのプログラム実行) | 反復が速い / 完全に再現可能 / ユーザー影響なし / 毎コミット実行可 / 本番デプロイなしに大規模検証 | 構築の初期投資が要る / プロダクトとモデルの進化に応じた保守が要る(放置すると drift) / 実使用と乖離すると誤った自信を生む |
| **Production monitoring**(本番の指標・エラー追跡) | 実ユーザー挙動を大規模に可視化 / 合成 eval が見逃す問題を捕捉 / 実性能の ground truth | 反応的でユーザーに問題が届いてから気づく / 信号がノイジー / 計装への投資が要る / 採点の ground truth がない |
| **A/B testing**(実トラフィックでの比較) | 実際のユーザー成果(継続率・task 完了)を測る / 交絡を制御 / スケールする | 遅い(有意差まで数日〜数週、十分なトラフィックが要る) / デプロイした変更しか試せない / transcript を精査できないと「なぜ」の信号が弱い |
| **User feedback**(thumbs-down・バグ報告) | 想定外の問題が表面化 / 実ユーザーの実例が付く / プロダクト目標と相関しやすい | 疎で自己選択的 / 深刻な問題に偏る / ユーザーは理由を説明しない / 自動化されない / ユーザー任せは負の影響を伴う |
| **Manual transcript review**(人間が会話を読む) | 失敗モードへの直感が育つ / 自動チェックが見落とす微妙な品質問題を捕捉 / 「良い」の基準をキャリブレーション | 時間を食う / スケールしない / カバレッジが不均一 / レビュアー疲労や属人差が信号品質に影響 / 定量的な採点にはなりにくい |
| **Systematic human studies**(訓練された評価者による構造化採点) | 複数評価者による gold standard / 主観的・曖昧な task を扱える / model grader 改善の信号になる | 相対的に高コストで遅い / 頻繁には回せない / 評価者間不一致の調停が要る / 法務・金融・医療などは専門家が必要 |

**開発段階への対応づけ**: automated eval はローンチ前と CI/CD で、エージェント変更とモデルアップグレードのたびに走る第一防衛線。production monitoring はローンチ後に分布 drift と想定外の実世界失敗を検出。A/B は十分なトラフィックが揃ってから重要な変更を検証。user feedback と transcript review は常時の実践(フィードバックは随時トリアージ、transcript は週次でサンプリング)。systematic human study は LLM grader のキャリブレーションと、人間の合意が基準になる主観的出力の評価に限定する。

> 記事はこれを安全工学の **Swiss Cheese Model** になぞらえる。単一の評価層ですべては捕まらないが、複数を重ねると一層をすり抜けた失敗を別の層が捕まえる。最も効果的なチームは automated evals(高速反復)+ production monitoring(ground truth)+ 定期的な人間レビュー(キャリブレーション)を組み合わせている。

## eval フレームワーク(付録)
インフラをゼロから作らずに済む OSS/商用フレームワーク。エージェント種別・既存スタック・オフライン評価か本番 observability かで選ぶ。

- **Harbor**: コンテナ環境でエージェントを走らせる設計。クラウドプロバイダを跨いで trial を大規模実行する基盤と、task/grader を定義する標準フォーマット。Terminal-Bench 2.0 などは Harbor レジストリ経由で配布され、既存ベンチマークとカスタム suite を同じ形で回せる。
- **Braintrust**: オフライン評価 + 本番 observability + 実験追跡。`autoevals` ライブラリに factuality/relevance などの既製 scorer。
- **LangSmith**: トレーシング、オフライン/オンライン評価、dataset 管理。LangChain エコシステムと密結合。**Langfuse** は同等機能をセルフホスト可能な OSS 代替として提供(データ所在地要件のあるチーム向け)。
- **Arize**: OSS の **Phoenix**(LLM トレーシング・デバッグ・オフライン/オンライン評価)と、それをスケール・最適化・監視向けに拡張した SaaS の **AX**。
- **[[strands-agents-evals]]**(本 wiki の既収録): Python SDK として `Case`/`Experiment`/evaluator を提供。→ [[evaluators]], [[experiment-management]]

> 記事の立場: フレームワークは標準化と加速に有効だが、**通す eval task の質を超えることはない**。ワークフローに合うものを素早く選び、エネルギーは高品質なテストケースと grader の反復に注ぐべき。

## 出典
- `raw/articles/demystifying-evals-for-ai-agents.md`(Anthropic Engineering, 2026-01-09, Mikaela Grace / Jeremy Hadfield / Rodrigo Olivares / Jiri De Jonghe) — eval の構造と語彙定義、なぜ eval を作るか(Claude Code / Descript / Bolt の事例)、エージェント種別ごとの評価手法(コーディング / 会話 / リサーチ / コンピュータ利用)、他手法との比較表と Swiss Cheese Model、付録の eval フレームワーク一覧。

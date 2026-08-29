---
title: Graders(採点器)
type: concept
aliases: [grader, graders, 採点器, LLM-as-judge, llm as a judge, code-based grader, model-based grader, human grader, partial credit]
tags: [evaluation, evals, grading, llm-as-judge, rubric, anthropic]
created: 2026-08-29
updated: 2026-08-29
sources:
  - raw/articles/demystifying-evals-for-ai-agents.md
related:
  - "[[agent-evaluation]]"
  - "[[evaluators]]"
  - "[[eval-driven-development]]"
  - "[[capability-vs-regression-evals]]"
---

## 概要
**grader(採点器)** は、エージェントの性能の一側面を採点するロジック。1つの task に複数の grader を付けられ、各 grader は複数の assertion(check)を持つ。各 grader は **transcript** か **outcome** のいずれかの一部を評価する。エージェント評価の設計で最も本質的な作業は、**その仕事に合った grader を選ぶこと**である(→ [[agent-evaluation]])。

## 3分類

### code-based grader
| 手法 | 強み | 弱み |
|---|---|---|
| 文字列マッチ(exact / regex / fuzzy)、二値テスト(fail-to-pass / pass-to-pass)、静的解析(lint / type / security)、outcome 検証、ツール呼び出し検証(使ったツール・パラメータ)、transcript 解析(ターン数・トークン使用量) | 速い / 安い / 客観的 / 再現可能 / デバッグが容易 / 特定条件を確実に検証できる | 期待パターンに完全一致しない**妥当なバリエーションに脆い** / ニュアンスを欠く / 主観的な task には限界 |

### model-based grader(LLM-as-judge)
| 手法 | 強み | 弱み |
|---|---|---|
| rubric ベースのスコアリング、自然言語 assertion、pairwise 比較、reference ベース評価、multi-judge consensus | 柔軟 / スケールする / ニュアンスを捉える / 開放的な task を扱える / 自由形式出力を扱える | **非決定的** / コードより高価 / 正確性のために**人間 grader とのキャリブレーションが必要** |

### human grader
| 手法 | 強み | 弱み |
|---|---|---|
| SME(主題専門家)レビュー、クラウドソース判断、spot-check サンプリング、A/B テスト、評価者間一致(inter-annotator agreement) | gold standard の品質 / 専門ユーザーの判断に一致 / **model-based grader のキャリブレーションに使う** | 高価 / 遅い / 人間の専門家に大規模アクセスが必要になりがち |

### スコアの合成
task ごとのスコアリングは、**重み付き**(grader スコアの合成が閾値を超えれば合格)、**二値**(全 grader が合格)、あるいはその**ハイブリッド**にできる。

## grader 設計の原則

### 1. 決定論的を優先、LLM は必要なときと柔軟性のため、人間は慎重に
記事の推奨は明確に「**deterministic graders where possible, LLM graders where necessary or for additional flexibility, human graders judiciously for additional validation**」。

> ⚠️ 対比: 本 wiki 既収録の [[evaluators]](Strands Evals のドキュメント)は「複数 evaluator を組み合わせる」ことをベストプラクティスとして前面に出す。Anthropic 記事は組み合わせ自体は肯定しつつ、**まず決定論的で足りるかを問い、LLM judge は必要なときだけ**という順序をより強く主張する。どちらも矛盾はしないが、既定値の置き所が違う。

### 2. 経路ではなく成果物を採点する
「ツール呼び出しが正しい順序で並んだか」のような**具体的な手順の一致を確認したくなる本能**があるが、記事はこれを**硬直しすぎでテストが脆くなる**と評価する。エージェントは eval 設計者が想定しなかった妥当なアプローチを日常的に見つけるため、創造性を不必要に罰しないよう、**通った経路ではなくエージェントが生み出したものを採点する**ほうがよい。

### 3. 部分点(partial credit)を組み込む
複数コンポーネントからなる task では部分点を設計する。問題を正しく特定し顧客を認証したが返金処理に失敗したサポートエージェントは、即座に失敗するエージェントより有意に良い。この**成功の連続体**を結果に表現することが重要。

### 4. LLM judge のキャリブレーションと分割
- LLM-as-judge は**人間の専門家と密にキャリブレーション**し、人間採点との乖離が小さいことを確認する。
- **ハルシネーション対策として「逃げ道」を与える**: 情報が足りないときは "Unknown" を返せ、と指示する。
- **明確で構造化された rubric** を作り、**次元ごとに独立した LLM-as-judge で採点する**(1つの judge に全次元を採点させない)。
- システムが堅牢になれば、人間レビューは時折で十分になる。

### 5. grader を「破られない」ようにする
エージェントが eval を簡単に「ズル」できてはいけない。task と grader は、**意図しない抜け穴の悪用ではなく本当に問題を解くことでしか合格できない**ように設計する。

## eval 自体のバグ: 低スコアの原因はエージェントとは限らない
採点バグ・agent harness の制約・曖昧さのせいで、エージェントの性能が良くても低スコアになる**微妙な失敗モード**がある。**洗練されたチームでも見落とす**。

- **CORE-Bench**: Opus 4.5 は当初 42% だった。Anthropic の研究者が調べると、`96.124991…` を期待しているのに `96.12` を不正解にする硬直した採点、曖昧な task 仕様、正確に再現不能な確率的 task といった複数の問題があった。バグ修正と制約の少ない scaffold の使用後、スコアは **95%** に跳ね上がった。
- **METR** の time horizon ベンチマークでは、「指定スコア閾値まで最適化せよ」と指示しながら採点は**閾値の超過**を要求する誤設定 task が複数見つかった。指示に従った Claude のようなモデルが罰せられ、指示された目標を無視したモデルのほうが良いスコアを得ていた。

> **経験則**: frontier モデルで**多数 trial にわたる 0% pass 率(= 0% pass@100)は、能力不足ではなく task が壊れている signal** であることが最も多い。task 仕様と grader を再確認すべきサイン。→ [[pass-at-k]]

このため記事は「**誰かが eval の詳細を掘り下げ、transcript をいくつか読むまで、eval スコアを額面どおりに受け取らない**」を規範としている。採点が不公平、task が曖昧、妥当な解が罰せられる、harness がモデルを制約している——のいずれかなら eval のほうを直す。→ [[eval-driven-development]] Step 6

## 実例: grader の組み合わせ(記事の例示 YAML)
記事はコーディングエージェントと会話エージェントについて、**利用可能な grader の全レンジを示すための**例示 YAML を載せている(実務ではこの全部は使わない)。

**コーディングエージェント(認証バイパス脆弱性の修正)**: `deterministic_tests`(必須テストファイル)/ `llm_rubric`(コード品質 prompt)/ `static_analysis`(ruff, mypy, bandit)/ `state_check`(security_logs に `auth_blocked` イベント)/ `tool_calls`(read_file → edit_file → run_tests)。加えて `tracked_metrics` として transcript 系(ターン数・ツール呼び出し数・総トークン)と latency 系(TTFT・出力トークン/秒・TTLT)。
→ 実務のコーディング eval は**正当性はユニットテスト、全体品質は LLM rubric** が基本形で、他は必要に応じて足す。

**会話エージェント(苛立った顧客への返金対応)**: `llm_rubric` に自然言語 assertion(「顧客の苛立ちに共感を示した」「解決策が明確に説明された」「応答が fetch_policy ツールの結果に接地している」)/ `state_check`(tickets: resolved, refunds: processed)/ `tool_calls`(verify_identity → process_refund(amount ≤ 100) → send_confirmation)/ `transcript`(max_turns: 10)。
→ 実務では**コミュニケーション品質と目標達成の両方を model-based grader で測る**のが典型。「質問に答える」ような task は "正解" が複数ありうるため。

## 出典
- `raw/articles/demystifying-evals-for-ai-agents.md` — grader の3分類と各手法/強み/弱みの表、スコアの重み付け・二値・ハイブリッド、Step 5「Design graders thoughtfully」(決定論優先・経路でなく成果物・部分点・LLM judge のキャリブレーションと逃げ道と次元分割・ハック耐性)、CORE-Bench と METR の eval バグ事例、コーディング/会話エージェントの例示 YAML。

---
title: AI-DLC と Spec-Driven Development の突合
type: synthesis
aliases:
  - AI-DLC vs SDD
  - AI-DLC と SDD
tags: [methodology, agentic-development, software-engineering, comparison]
created: 2026-08-11
updated: 2026-08-11
sources:
  - raw/papers/aidlc-method-definition.md
  - raw/papers/one-developer-is-all-you-need.md
  - raw/papers/the-end-of-software-engineering.md
related:
  - "[[ai-dlc]]"
  - "[[intent-unit-bolt]]"
  - "[[mob-rituals]]"
  - "[[spec-driven-development]]"
  - "[[one-person-squad]]"
  - "[[agentic-engineering]]"
  - "[[ai-productivity-task-vs-output]]"
  - "[[one-developer-is-all-you-need]]"
  - "[[aidlc-prompt-kit]]"
---

## 概要
[[ai-dlc]](AWS, 2026)と [[spec-driven-development]](SDD; Rosa et al. 2026 / [[one-developer-is-all-you-need]] が実証)は、**どちらも「AI に書かせる前に、人間が検証した中間成果物を積む」構造**を持つ。だが両者は**律速要因の置き所が違う**——SDD は「仕様の質」を binding constraint と見るのに対し、AI-DLC は「各段での人間の承認(loss function)」をそこに置く。この差は方法論の設計に直結する。

さらに、AI-DLC は [[agentic-engineering]] が「control plane としての AI」と抽象的に述べたものを**フェーズ・儀式・成果物として具体化**した最初の完成品に近く、[[one-person-squad]] は**同じ思想を1人+複数エージェントで実装した実証事例**に当たる。3者を並べると、同じ地層の異なる断面が見える。

## 3者の位置づけ

| | [[ai-dlc]] | [[spec-driven-development]] | [[one-person-squad]] |
|---|---|---|---|
| 出所 | AWS の method definition ペーパー(提案文書) | Rosa et al. 2026 の概念 + Itaú の事例研究 | Itaú の事例研究(arXiv:2605.18461) |
| 実証 | **なし**(効果主張のみ) | あり(1案件、対照は計画値) | あり(同上) |
| 第一級成果物 | Intent / Unit / user story / Domain Design / Logical Design | **自然言語仕様** | 仕様 + エージェント役割定義 |
| 律速と見るもの | 各段の**人間の検証**(loss function) | **仕様の質**(モデル能力ではなく) | **経験者の判断**(人間=品質ゲート) |
| 人間の構成 | mob(PO + 開発者 + QA + ステークホルダー) | 規定なし | **1人**(+4エージェント) |
| 反復単位 | Bolt(時間〜日) | 規定なし | 規定なし |
| 設計技法 | **内蔵**(DDD 版が第一版。BDD/TDD 版も予告) | 規定なし(仕様テンプレートに委ねる) | core / non-core 分割 |

## 一致点: 「意図 → 検証済み中間物 → コード」の連鎖
両者が独立に到達している構造がある。

- **コードの前に契約を置く**。AI-DLC は user story を「人間と AI の理解を揃える、よく定義された**契約**」として明示的に残す(原則6)。SDD は仕様そのものを第一級成果物とする。呼び方が違うだけで、**AI に渡す前に人間が合意した自然言語の契約**という機能は同じ。
- **中間成果物を永続化して再利用する**。AI-DLC の "context memory"(全成果物を保存し相互リンクしてトレーサビリティを持たせる)は、SDD の「継続性(continuity)レバー」——仕様・決定記録・エージェント設定が別のエンジニアや別のエージェント群への引き継ぎを可能にする——と同じ効用を狙う。
- **ブラウンフィールドで同じ壁にぶつかっている**。[[one-developer-is-all-you-need]] は「**未文書化のレガシー統合契約**が最大の under-specification 源」であり、既存の振る舞い契約を仕様に明示しないと生成コードがそれを破ると報告した。AI-DLC の brown-field 手順(既存コードを static / dynamic model へ「引き上げ」てから通常フローに乗せる。→ [[mob-rituals]])は、まさにこの問題への対処である。**独立した2つのソースが同じ処方に到達している**点は、この論点の頑健さを示す。

## 相違点1: 律速をどこに置くか
- **SDD**: 出力品質の binding constraint を**仕様の質**に移すのが核心。詳細で曖昧さのない仕様は supervised / autonomous 双方でほぼ無修正のコードを生み、曖昧な仕様は**どのツールでも使い物にならない出力**になった。つまり**上流に一度投資すれば下流が効く**という賭け方。
- **AI-DLC**: 「各ステップは戦略的な決定点であり、そこでの人間の監督が **loss function** として働く」——誤りが雪だるま式になる前に各段で刈り取る。つまり**全段に均等に人間を配置する**という賭け方。

この差は実務コストに直結する。SDD 型なら人間の関与を Inception に集中させられるが、AI-DLC 型は Domain Design・Logical Design・コード・テスト・デプロイの**各段に承認ゲート**が要る。原則9は「ステージを最小化しフローを最大化する」と言うが、実際に列挙されているゲートの数は少なくない。**「minimise stages」と「各段に loss function」は互いを引っ張り合う**。

> ⚠️ 矛盾: AI-DLC 内部の緊張。原則9(ハンドオフ最小化)と、III 章ワークフローの「各段で人間が検証して次段の context を豊かにする」再帰構造は、同じ文書内で逆方向を向いている。論文はこの調停を「minimal but sufficient number of phases」という語で済ませており、何が sufficient かの基準は示されない。

## 相違点2: 人間の頭数
最も鋭い対立点。

- **AI-DLC** の儀式は Product Owner・開発者・QA・その他ステークホルダーが**単一の部屋に同席**することを前提とする(→ [[mob-rituals]])。
- **[[one-person-squad]]** は、同じ役割群を**エージェントに割り当てて1人に畳む**構成で成立を実証した。

AI-DLC 自身の原則8は「専門サイロを越え、専門役割の必要数を減らす」と述べており、**論理的には one-person squad の方向を向いている**。にもかかわらず儀式は mob を要求する。整合的に読むなら、AI-DLC の mob は「AI 生成物の検証には**複数の独立した視点**が要る」という品質論であって人数の効率論ではない——つまり [[one-developer-is-all-you-need]] が言う「経験者=品質ゲート」の**冗長化版**、と解釈できる。(この解釈は本 wiki のもの)

## 相違点3: 設計技法を内蔵するか
AI-DLC の原則3は、Agile が DDD 等の設計技法を「スコープ外・チーム任せ」にした空白が品質問題の原因だと主張し、設計技法を方法論のコアに引き込む。SDD にはこの主張がない(仕様テンプレートの中身はプロジェクト任せ)。

これは AI-DLC の独自性として評価できる部分である。**AI に何を生成させるかを決めるには、生成物の型(aggregate / value object / entity / domain event …)が事前に定まっている必要がある**——という指摘は、[[structured-output]] が「スキーマで出力契約を固める」ことで得る効用を、設計レベルに引き上げたものと読める。[[domain-modeling]] スキルが CONTEXT.md 用語集と ADR を能動的に構築するのも同じ動機。

## 「効果」の主張をどう扱うか
AI-DLC は「Mob Elaboration が数週間〜数ヶ月の逐次作業を数時間に凝縮する」と主張するが、これは **Inception フェーズのサイクルタイム**についての主張であって、デリバリ全体の主張ではない。

[[ai-productivity-task-vs-output]] が整理した通り、[[writing-code-vs-shipping-code]](NBER w35275)はタスク層の利得(commits +180%)が出力層(releases +30%)へ上るほど減衰することを 10万+開発者の event study で示している。AI-DLC の主張はこの減衰構造に対して無防備である——**要件定義の高速化がリリース頻度に翻訳される保証は、論文の中にも外にもない**。

同時に、AI-DLC が Operations フェーズまで含めてライフサイクル全体を設計している点は、[[weak-link-hypothesis]](補完的タスク連鎖では一段の自動化効果が最弱段に律速される)への**構造的な回答**にはなっている。全段に AI を入れれば最弱段も上がる、という賭けである。この賭けが当たるかは実証を待つほかない。

## まとめ
- AI-DLC と SDD は独立に「AI に書かせる前に人間が検証した契約を置く」という同じ骨格へ到達しており、ブラウンフィールドの処方(既存コードのモデル化)まで一致する。**この収束は両者の主張の信頼性を相互に高める**。
- 差は**人間の配置**にある。SDD は上流集中、AI-DLC は全段分散、one-person squad は1人に集約。どれが正しいかは実証がなく、AI-DLC 側は特に根拠が薄い。
- AI-DLC の独自価値は「設計技法(DDD)の内蔵」と「ライフサイクル全段のカバー」であり、用語刷新(Unit / Bolt)や儀式(mob)は本質的な新規性が薄い。
- 実務的に持ち帰るなら、方法論全体より **Appendix A のプロンプト規約**(`aidlc-docs/` の md 階層、計画をチェックボックス付きで先に書かせる、承認まで実行させない、重要な決定を勝手に下させない、発行プロンプトを `prompts.md` に全部残させる)のほうが再利用価値が高い。これは Claude Code の plan mode や [[loop-engineering]] の maker/checker 分離と直接対応する。全7ブロックの内訳は [[aidlc-prompt-kit]]。

## 出典
- `raw/papers/aidlc-method-definition.md` — 原則3・6・8・9、III 章ワークフロー(loss function、context memory)、IV/V 章、Appendix A。
- `raw/papers/one-developer-is-all-you-need.md` — SDD の binding constraint、レガシー統合契約の under-specification、one-person squad の構成。
- `raw/papers/the-end-of-software-engineering.md` — agentic engineering を control plane と見る枠組み。
- 減衰の議論は [[ai-productivity-task-vs-output]] / [[writing-code-vs-shipping-code]] / [[weak-link-hypothesis]] に依拠(出典は各ページ)。

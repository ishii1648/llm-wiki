---
title: "The End of Software Engineering (Cao 2026)"
type: entity
aliases:
  - The End of Software Engineering
  - How AI Agents Are Fundamentally Restructuring the Software Paradigm
  - arXiv:2606.05608
  - ソフトウェア工学の終焉
tags: [paper, arxiv, agentic-engineering, position-paper, software-engineering, llm-agents]
created: 2026-06-10
updated: 2026-06-10
sources:
  - raw/papers/the-end-of-software-engineering.md
related:
  - "[[agentic-engineering]]"
  - "[[agent-as-a-service]]"
  - "[[loop-engineering]]"
  - "[[ai-code-review]]"
  - "[[writing-code-vs-shipping-code]]"
  - "[[ai-productivity-task-vs-output]]"
---

## 概要
**"The End of Software Engineering: How AI Agents Are Fundamentally Restructuring the Software Paradigm"**(Zhenfeng Cao, Lingxi Intelligent Investment (Shenzhen) Development Co., Ltd., arXiv:2606.05608v1 [cs.SE], 2026-06-04, CC BY 4.0)は、AI エージェントの台頭が既存パラダイム内の「ツール改良」ではなく**ソフトウェアの根本的再構成(fundamental restructuring)**であると論じる**ポジションペーパー**。従来ソフトウェア(コード = 決定ロジックの担体)と agentic system(コード = LLM 駆動の推論ループのための ephemeral なツール)を形式的に区別し、licensed software → SaaS → **Agent-as-a-Service(AaaS)** という配信パラダイムの第三のシフトを描き、新分野 **Agentic Engineering** を提唱する(→ [[agentic-engineering]], [[agent-as-a-service]])。

> ⚠️ 性質: 査読論文ではなく、第一原理・歴史的アナロジー・既存ベンチマーク再解釈に基づく**主張型の論考**。定量的検証は他者のベンチ結果の引用に依存する。本ページの「主な主張」は論文の主張であって本 wiki が裏付けた事実ではない。

## 詳細

### 書誌
- **著者**: Zhenfeng Cao(Lingxi Intelligent Investment、深圳。連絡先 info@stellarsea.com)
- **識別子**: arXiv:2606.05608v1 [cs.SE]、2026-06-04 公開、ライセンス CC BY 4.0
- **構成**: 1 Introduction / 2 First-Principles Analysis / 3 From SaaS to AaaS / 4 Agentic Engineering: A New Discipline / 5 Empirical Evidence and Current Limitations / 6 Evolutionary Roadmap / 7 Implications / 8 Conclusion + References(14件)

### 3つの中心的主張(著者の主張)
1. **First-Principles Necessity(第一原理的必然性)**: agentic パラダイムは市場の好みでなく**複雑性スケーリング則の不可避な帰結**。従来ソフトは人間が全決定を明示的に encode せねばならないが、エージェントは推論を、学習計算量とともに容量が伸びるモデルへ外部化し、複雑性を非線形に航行できる。
2. **Paradigm Shift, Not Optimization(最適化でなくパラダイムシフト)**: 「AI → Software → Result」から「**Agent → Result**」への移行は、ソフトウェア成果物を必須の中間生成物として消す。SaaS が on-premise インストールを必須中間物として消したのと同型で、これを**ソフト配信の第3の主要パラダイムシフト**と位置づける(→ [[agent-as-a-service]])。
3. **Emergent Discipline(新分野の創発)**: [[agentic-engineering|Agentic Engineering]] が独自の概念・ツール・指標を持つ実践として立ち上がる。実務者は「より優秀なプログラマ」ではなく **intent architect / agent coordinator / outcome auditor** という別種の役割。

### 形式モデル(2.1–2.3)
- **従来ソフト** `S=(C,D,E)`: C=計算資源、D=ソースコードに encode された決定論的決定規則、E=実行環境。決定的性質は **D が実行に対し静的** —— 入力に出会う前に全決定ロジックを人間が書ききる必要がある。
- **AI エージェント** `A=(M,𝒯,ℳ,Π)`: M=推論エンジンの LLM、𝒯=実行可能ツール群(コードインタプリタ/API/DB/ファイルシステム)、ℳ=記憶サブシステム(短期 context + 長期ベクトルストア)、Π=ユーザ意図を行動列に分解する計画機構。`aₜ ← M(sₜ, ℳ)`, `s_{t+1} ← exec(aₜ)` を反復。鍵は**決定ロジックが実行時に生成**される点 —— 生成コードはシステムそのものでなく、必要に応じ作られ捨てられる transient artifact。
- Karpathy の **"Software 2.0"**(学習重みが手書きロジックを置換)をさらに一歩進め、「ニューラルネットがプログラムを置換する」のでなく「**オンデマンドでプログラムを書く**(コードを推論の道具として使う)」と位置づける。ReAct・Chain-of-Thought とも整合。

### 複雑性の壁(2.2, 2.4)
- Brooks の essential / accidental complexity を引き、accidental は減らせても essential(問題固有)は無限大に留まると指摘。
- **Proposition 2.1(Complexity Scaling)**: n 成分が相互作用しうる系の相互作用経路数 `P(n) ∈ Θ(2ⁿ)`(各ペアが相互作用する/しないで 2^C(n,2) 通りの依存グラフ)。複雑性の上界は指数的に伸びるが、人間の認知容量は本質的に一定 `C_H`。`N > C_H` の課題は現実的コストで不可能。
- エージェントは容量 `C_M`(モデルサイズ・学習計算量とともに成長)で空間を航行し、解の容量を**人間の認知限界から切り離す**。「10% の改善でなく質的変化」。

### 実証と限界(第5節)
**Breakthrough(著者が挙げる4点)**:
- **SWE-bench Verified**: Lingma SWE-GPT 72B が GitHub issue の 30.20% を解決(GPT-4o の 31.80% に肉薄、かつ完全オープン)。7B 版でも 18.20%。Llama 3.1 405B(約6倍)比で相対 22.76% 改善。
- **Multi-Agent Coordination**: LangChain の企業20+デバッグワークフローの pilot で根本原因特定時間を **93% 短縮**、1か月で200エンジニア時間超を節約。利得は個々のエージェントの優秀さでなく **orchestration**(共有 context・並列調査・相互検証)から。
- **Self-Evolution**: Nous Research の **Hermes Agent**(GitHub 179,000+ stars)。タスク完了後に再利用可能な **Skills**(parameterized procedural modules)を自律生成し、使用中に不足を検知すると**自動 self-patch**(create→use→detect weakness→self-patch を無人で)。FTS5 ベースの会話検索 + LLM 要約で cross-session の経験記憶を保持(→ [[agent-skills]] の自己進化版)。
- **Generalization**: Wang et al. のサーベイが要件分析〜保守まで全ライフサイクルへの適用研究を多数列挙。

> ⚠️ 限界(EvoClaw の崖): **EvoClaw** ベンチ(Deng et al., arXiv:2603.13428)は、孤立した issue 修正でなく**継続的なソフトウェア進化**(commit 履歴を跨いだ持続的開発、エラーが蓄積する設定)を要求。「孤立タスクの >80% から連続設定では**最大 38%** に大幅低下し、長期保守とエラー伝播でのエージェントの根深い苦闘を露呈」(12 frontier models × 4 frameworks で評価)。4つの核心課題: **context drift / error propagation / technical debt awareness の欠如 / verification fidelity**。著者はこの gap を「本質的でなく、context 管理・記憶アーキテクチャ・検証機構の研究課題」とし、「拡張(augmentation)としては今日すでに real かつ transformative だが、完全自律にはなお数年の研究が要る」と calibration する。

### 4段階ロードマップ(第6節)
| 段階 | 能力 | 鍵技術 | 人間の役割 | 代表系 |
|---|---|---|---|---|
| **I. Tool-Augmented**(2023–25) | コード補完・単一 issue 修正 | in-context learning, RAG | author + reviewer | GitHub Copilot, Claude Code |
| **II. Single-Task Autonomous**(2025–27) | 機能の end-to-end 構築・デバッグ | planning + tool use, self-correction | intent architect + auditor | Devin, OpenHands |
| **III. Multi-Agent Teams**(2026–29) | 協調 swarm・全ライフサイクル管理 | 共有記憶・役割特化・orchestration | PM + architect + auditor | LangChain orchestration, MetaGPT |
| **IV. Self-Evolving Ecosystems**(2028+) | 自律的発見・学習・複製・適応 | meta-learning, 自己改変, 生態系ガバナンス | goal setter + ethics governor | AGI assistants(見込み) |

### 提言(第7節)
- **実務者**: コード生産 → intent engineering へ。agent orchestration 力、observability 投資、"human-in-the-loop, agent-in-the-driver's-seat" 姿勢。
- **研究者**: long-context state management、open-ended での検証、スケールでの agent alignment、outcome-based の経済モデル。
- **組織**: agent-ready なワークフロー特定、評価フレーム投資、チーム構造の再設計(少数の "agent orchestrator" が大人数開発者を置換しうる)。

## 本 wiki の他ページとの接続
- [[agentic-engineering]] — 本論文が提唱する中心概念。新分野の定義・従来 SE との対比表をここに展開。
- [[agent-as-a-service]] — 第3節の3世代モデル / AaaS パラダイムシフト。
- [[loop-engineering]] — 「prompt でなくループを設計」「intent architect」「maker/checker 分離」など、本論文の human role 再定義と実務面で強く共鳴(独立ソース)。
- [[ai-code-review]] — 「説明できる著者」前提の崩壊・検証責任。本論文の verification fidelity / outcome auditor 論と同根の懸念。
- [[swarm-multi-agent]] / [[graph-multi-agent]] / [[multi-agent-patterns]] — Stage III「Multi-Agent Teams」の具体的実装パターン(本 wiki の Strands 系)。
- [[agent-skills]] — Hermes Agent の自己進化 Skills は Agent Skills 仕様の発展形。
- [[agent-loop]] — A=(M,𝒯,ℳ,Π) の反復実行ループの最小プリミティブ。

## 出典
- `raw/papers/the-end-of-software-engineering.md`(Zhenfeng Cao, arXiv:2606.05608v1, 2026-06-04)— 3つの中心的主張、形式モデル S/A、Proposition 2.1、3世代/AaaS、Agentic Engineering の定義と対比、SWE-bench/EvoClaw/Hermes/LangChain pilot の実証、4段階ロードマップ、提言のすべて。
- 論文が引用する一次資料(本 wiki 未 ingest): Karpathy "Software 2.0"[3]、Wang et al. survey[4]、Lingma SWE-GPT[5]、EvoClaw[6](arXiv:2603.13428)、LangChain Agentic Engineering blog[7]、ReAct[9]/CoT[8]、SWE-bench[10]、MetaGPT[11]、Hermes Agent[14]。

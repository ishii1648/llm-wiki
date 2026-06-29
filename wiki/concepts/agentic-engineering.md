---
title: Agentic Engineering
type: concept
aliases:
  - agentic engineering
  - エージェンティック・エンジニアリング
  - エージェント工学
  - intent architect
  - intent engineering
tags: [agentic-engineering, agentic-development, llm-agents, software-engineering, multi-agent, discipline]
created: 2026-06-10
updated: 2026-06-10
sources:
  - raw/papers/the-end-of-software-engineering.md
related:
  - "[[the-end-of-software-engineering]]"
  - "[[agent-as-a-service]]"
  - "[[loop-engineering]]"
  - "[[ai-code-review]]"
  - "[[multi-agent-patterns]]"
  - "[[agent-loop]]"
  - "[[weak-link-hypothesis]]"
  - "[[ai-productivity-task-vs-output]]"
---

## 概要
**Agentic Engineering(エージェンティック・エンジニアリング)** は、AI エージェントを「コードを速く生成する道具」でなく**ソフトウェアデリバリ全体を駆動するデジタルなチームメンバー**として扱う、従来のソフトウェア工学とは**核となる研究対象・制御モデル・人間の役割が異なる**創発的分野。LangChain が2026年4月に提唱した語で([[the-end-of-software-engineering]] が引用)、「役割・共有記憶・統一された observability 層を持つ AI エージェント群が、コードを速く書くためでなく**デリバリパイプライン全体を通してソフトウェアを駆動する** multi-agent coordination モデル」と定義される。

> 出典: 本ページの記述は Zhenfeng Cao, arXiv:2606.05608v1([[the-end-of-software-engineering]])が引用・整理した LangChain[7]・Wang et al.[4]・Guo et al.[13] の主張に基づく。本 wiki がその主張の真偽を検証したものではない。

## 詳細

### 「AI コーディングエージェント」との区別
Kumar & Ramagopal(LangChain Blog, 2026-04)による区別が中心:
- **AI coding agents** は「単一のユーザ駆動セッション内で **intent をコードへ翻訳する**」のが得意。
- **Agentic engineering** は「**一段上の抽象レベル**で動く **control plane**」—— cross-team のワークフローを orchestrate し、複数エージェント間で long-term memory を保持し、ソフトウェアデリバリ・ライフサイクル全体で state と traceability を管理する。

つまり Agentic Engineering は単一エージェントの賢さでなく **orchestration(共有 context・並列化・相互検証)** に価値の源泉を置く。実際 [[the-end-of-software-engineering]] の企業 pilot では、根本原因特定の93%短縮は「個々のエージェントの優秀さでなく orchestration から来た」とされる。本 wiki の [[loop-engineering]] が論じる「prompt でなく**ループを設計**する」「maker/checker 分離」も、この control-plane 視点の実務的具体化と読める(独立ソース)。

### エージェントの基本アーキテクチャ(perception-memory-action)
Wang et al.[4] のタクソノミーが示す3モジュール(LLM reasoning core が orchestrate):
- **Perception**: マルチモーダル入力の処理。
- **Memory**: semantic / episodic / procedural な知識の保持。
- **Action**: 内部推論 + 外部ツール呼び出し。

具体実装例として **Hermes Agent**(Nous Research)が挙げられ、perception-memory-action を **self-evolution 機構**付きで運用する: タスク完了後に再利用可能な **Skills**(parameterized procedural modules)を自律生成し、使用中に不足を検知すると自動 patch、FTS5 ベースの会話検索 + LLM 要約で cross-session の episodic memory を realize、subagent 委譲で早期の multi-agent coordination を示す(→ [[agent-skills]] の自己進化発展形)。

### 従来 SE との対比(論文 Table 2)
| 次元 | Traditional SE | Agentic Engineering |
|---|---|---|
| Core artifact | ソースコード(静的) | エージェントシステム(動的) |
| Control center | 人間エンジニア | LLM reasoning engine |
| Decision mechanism | 事前設計のロジック | 実行時生成の推論 |
| Development cycle | 線形(design→code→test) | 自律的な反復ループ |
| Human role | コードの著者 | intent architect / coordinator / auditor |
| Complexity ceiling | 人間の認知(O(1)) | モデル容量(計算量とともに成長) |
| Output unit | 動くソフトウェア | 納品される成果(outcomes) |
| Error handling | プログラマ定義 | モデル適応的 |
| Evolution | 手動リファクタ | 自己改変 |

### 人間の役割の再定義
コード生成スキルが commoditize される世界で、新たな差別化要因:
- **Intent articulation(意図の明確化)** — エージェントが意図せぬ結果を出さず自律動作できるだけの明瞭さと制約で目標を指定する力。
- **Architectural oversight** — 複数エージェントの協調方法・共有記憶・人間判断が介入すべき箇所をシステムレベルで理解する。
- **Quality calibration** — 「良い」の定義と、エージェントが self-correction に使える評価フレームの構築。
- **Ethical governance** — エージェント挙動を組織の価値・法・社会的期待に整合させる。

論文は「agent orchestration を極めた者の生産性乗数は従来の "10x engineer" を遥かに超える —— 速くタイプするのでなく、**swarm を複雑な成果へ調整する能力**によって」と主張する。これは [[ai-code-review]] が指摘する「検証・所有権の責任は人間に残る(outcome auditor)」という論点と表裏一体。

### 現状の到達点と限界
論文は agentic engineering を**今日は拡張(augmentation)パラダイムとして real かつ transformative**としつつ、完全自律には EvoClaw が露呈した崖(孤立タスク >80% → 連続的進化で最大38%)の克服 —— long-context state 管理・記憶アーキテクチャ・検証機構 —— が必要とする(詳細は [[the-end-of-software-engineering]])。発展段階は Tool-Augmented → Single-Task Autonomous → **Multi-Agent Teams** → Self-Evolving Ecosystems の4段階(Stage III の具体パターンは本 wiki の [[multi-agent-patterns]] / [[swarm-multi-agent]] / [[graph-multi-agent]] が対応)。

## 出典
- `raw/papers/the-end-of-software-engineering.md`(Zhenfeng Cao, arXiv:2606.05608v1, 第4節)— Agentic Engineering の定義(LangChain[7] 引用)、AI coding agent との区別、perception-memory-action(Wang et al.[4])、Hermes Agent の自己進化、Table 2 の対比、人間の役割4要素、生産性乗数の主張。
- 同 第5–6節 — orchestration による実証(LangChain pilot)、EvoClaw の限界、4段階ロードマップ。

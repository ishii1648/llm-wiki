---
title: Agent-as-a-Service (AaaS) と3世代のソフト配信
type: concept
aliases:
  - Agent-as-a-Service
  - AaaS
  - Software 3.0
  - エージェント・アズ・ア・サービス
  - Agent to Result
  - 3世代のソフトウェア配信
tags: [agentic-engineering, aaas, saas, software-delivery, business-model, paradigm-shift]
created: 2026-06-10
updated: 2026-06-10
sources:
  - raw/papers/the-end-of-software-engineering.md
related:
  - "[[the-end-of-software-engineering]]"
  - "[[agentic-engineering]]"
---

## 概要
**Agent-as-a-Service(AaaS / Software 3.0)** は、Zhenfeng Cao(arXiv:2606.05608v1, [[the-end-of-software-engineering]])が提唱する**ソフトウェア配信の第3世代**。商用ソフトの歴史を「**複雑性をエンドユーザから漸進的に移転してきた**過程」と捉え、licensed software(1.0)→ SaaS(2.0)→ **AaaS(3.0)** と整理する。各遷移は「複雑性を最もよく吸収できる主体が吸収し、最も扱えない主体が解放される」という同一パターンに従う。AaaS では**エージェントが理解・構築・実行を担い**、ユーザは「どう作るか」を指定する必要から解放され「**どんな成果がほしいか**」だけを述べる。

> 出典: 本ページの主張はすべて Zhenfeng Cao の論文([[the-end-of-software-engineering]])第3節に基づく。ポジションペーパーの整理であり、本 wiki が独立検証した事実ではない。

## 詳細

### 3世代のソフトウェア配信(論文 Table 1)
| 世代 | コア機構 | 複雑性の所有者 | 収益モデル | 例 |
|---|---|---|---|---|
| **Software 1.0(Local)** | コード+データを on-premise で実行 | エンドユーザ(インストール・保守) | ライセンス販売 | Microsoft, Oracle |
| **Software 2.0(SaaS)** | コード+データをクラウドで実行 | ベンダ(インフラ・更新) | サブスクリプション | Salesforce, AWS |
| **Software 3.0(AaaS)** | エージェントがクラウドで自律運用 | **エージェント**(理解・構築・実行) | **outcome-based(成果課金)** | OpenAI, Anthropic |

SaaS が企業を「サーバ室」から解放したように、AaaS は「**結果の作り方を指定する必要**」から解放すると論じる。

> ⚠️ 用語注: 論文の "Software 2.0" は Karpathy の "Software 2.0"(= 学習重みが手書きロジックを置換)とは**別の用法**で、ここでは配信形態としての SaaS を指す。論文は別箇所で Karpathy の Software 2.0 概念も(形式モデルの文脈で)引用しており、同じ語が二義的に使われる点に注意。

### 「AI → Software → Result」の失敗
現状主流の **AI-augmented development**(LLM で人間エンジニアのコード生成を高速化、従来ライフサイクル内)を論文は「AI → Software → Result」パイプラインと呼び、3つの構造的弱点を指摘:
1. **Bottleneck persistence** — 設計・アーキテクチャ・統合テスト・デプロイで人間が critical path に残る。AI は実装の一サブステップ(コード生成)を速めるだけで、どのフェーズからも人間を外さない。
2. **Complexity ceiling intact** — 最終成果物は依然 `S=(C,D,E)` の従来ソフト。複雑性は D のサイズとともにスケールし、改変には人間の理解が要る。AI は D の構築をやや速めただけ。
3. **Iteration latency** — AI 支援があっても機能変更は requirements→design→code→test→deploy の全鎖を辿る。このレイテンシは人間のコミュニケーション・調整速度を下回れない。

### 「Agent → Result」: 中間生成物の除去
代替パラダイムはソフトウェア成果物を必須の中間物として消す:
1. 人間がエージェントに **intent と制約**を articulate する。
2. エージェントが自律的に plan → execute(必要時にコード生成)→ validate → deliver。
3. 人間が outcome を audit しフィードバックする。

このモデルでは「ソフトウェアが納品されるのでなく、**成果(outcomes)が納品される**」。エージェントは数千行のコード生成・DB クエリ・外部 API 呼び出し・可視化を**すべて ephemeral に**行い、永続するのは**エージェントの能力であって中間生成物ではない**。これは「AI → Software → Result」が SaaS 相当の中間物(=ソフト)を残すのに対し、AaaS がそれをも除去する点で**第3のパラダイムシフト**だ、という論文の骨子。

### 位置づけ
AaaS は配信・ビジネスモデル側の主張で、その実装・実務の規律側が [[agentic-engineering]](control plane としての multi-agent orchestration)。両者は同じ論文の表裏で、AaaS が「何が売られるか(成果)」を、Agentic Engineering が「誰がどう作るか(エージェント群 + intent architect)」を扱う。

## 出典
- `raw/papers/the-end-of-software-engineering.md`(Zhenfeng Cao, arXiv:2606.05608v1, 第3節)— Table 1 の3世代、複雑性移転パターン、「AI→Software→Result」の3弱点、「Agent→Result」の3ステップと outcomes 納品、Kumar & Ramagopal[7] の control plane 引用。

---
title: Context Compression (コンテキスト圧縮)
type: concept
aliases: [context compression, コンテキスト圧縮, token compression, トークン圧縮, prompt caching, KV cache]
tags: [llm-cost, context, compression, token, kv-cache, prompt-caching]
created: 2026-06-11
updated: 2026-06-11
sources:
  - raw/articles/ai-tokens-ninety-percent-garbage.md
related:
  - "[[project-headroom]]"
  - "[[context-rot]]"
  - "[[conversation-management]]"
  - "[[mcp-tools]]"
  - "[[tejas-chopra]]"
---

## 概要
**Context Compression(コンテキスト圧縮)** は、LLM に送る入力(コンテキストウィンドウの中身)から冗長な部分を削り、トークン課金のコストを下げる手法群。コーディングエージェントの普及でトークン課金が「使うほど高くなる」構造問題になっており([[project-headroom]] の文脈)、人が書いた指示よりも**機械生成のボイラープレート/メタデータ**が最大のコスト要因という認識が前提。要約(不可逆)と、原文を復元できる**可逆圧縮**とで設計思想が分かれる。

## 詳細

### なぜトークンの大半が「ゴミ」なのか
- [[tejas-chopra]] の主張: トークンの**最大90%**が LLM にとって冗長。中身は冗長な JSON スキーマ、ネストされたテンプレート、繰り返されるカラム定義など「テキストのふりをした圧縮可能なデータ」。
- 2025年の研究では、**ユーザー入力の読み込みだけでトークン消費量全体の約76%**を占めるとされる。
- 圧縮率が高いデータ種: サーバログ(90%)/ MCP ツール出力(70%が冗長 JSON)/ DB 出力(スキーマは1つ)/ ファイルツリー(メタデータの繰り返し)。

### コスト構造の問題
- 従来の座席ライセンスは使用時間に依らず一定だが、トークン課金は**ツールが優秀で使い込むほど請求が膨らむ**(生産性とコストが同時に上がる矛盾)。
- 例: Uber は 2025年12月に Claude Code を導入、2026年3月までにエンジニアの84%がエージェント型コーディングへ移行し、2026年の AI 予算を4カ月で使い切った。月額コストは1人 $150〜250、ヘビーユーザーで $500〜2000。Microsoft は社内 Claude Code ライセンスの大半を取り消し GitHub Copilot CLI への移行を指示と報じられた。
- Goldman Sachs 予測: エージェント型 AI の普及でトークン消費量は2030年までに**24倍**、月間120京トークンに達しうる。単価が下がっても総量爆発でコストは上がる。

### プロバイダ側キャッシュ(prompt caching / KV cache)との関係
- AI プロバイダ側にもキャッシュ機構はあるが設定が不透明。例: **Claude のプレフィックスキャッシュは既定 5分**しか保持されず、5分操作しないとコンテキスト全体を再送信する必要がある。
- **1時間 TTL** 設定も API ドキュメントに存在するが、**書き込みに2倍のコスト**がかかり読み込みで90%節約する構造のため、損益分岐点の見極めは利用者任せ。
- system prompt に日付や毎回変わる UUID が混じるだけでキャッシュミスが起き、コストが跳ね上がる(→ [[project-headroom]] の CacheAligner がこの差分問題に対処)。

### 可逆圧縮という設計思想
- 要約は**不可逆**だが、[[project-headroom]] の **CCR(Compress Cache and Retrieve)** は圧縮箇所にマーカーを残し、必要時に **MCP サーバー**(→ [[mcp-tools]] / [[model-context-protocol]])経由で原文を復元できる**可逆**圧縮。原文はローカルの Redis/SQLite に保存。
- これは [[conversation-management]] の Summarizing / proactive compression(モデル提供 SDK 側のリアクティブ/先回り圧縮)とは別レイヤ — **プロバイダに届く前のローカルプロキシ**で型別に圧縮する点が異なる。

### トークン圧縮ツールの比較(記事掲載・公称値)
|  | Headroom | RTK | LeanCTX | TokenCompany |
|---|---|---|---|---|
| 対象 | ログ、JSON、ファイル、RAG、会話履歴 | シェルコマンド出力 | シェル出力＋ファイル＋プロジェクト | プロンプト全体 |
| 方式 | 型別ルーター＋統計分析 | コマンド別フィルター | シェルフック＋AST解析 | MLモデル |
| 可逆 | ○ | × | ○ | × |
| 運用 | ローカルプロキシ | ローカルCLI | ローカルCLI/MCP | クラウドAPI |
| 削減率 | 60〜95% | 60〜90% | 60〜99% | 最大20% |

- **The Token Company**(YCombinator 出資): 圧縮を API サービスとして提供。
- **RTK(Rust Token Killer)**: OSS。シェルコマンド出力を圧縮する CLI プロキシ。
- **LeanCTX**: RTK 同様の CLI 圧縮に加え、MCP サーバーとしてファイル読み込み・プロジェクトコンテキストの圧縮も行う。

> ⚠️ 削減率は各プロジェクトの公称値で、対象データや使用条件により変動する(記事の注記)。

## 出典
- `raw/articles/ai-tokens-ninety-percent-garbage.md`(情報の灯台「AIトークンの9割はゴミだった」2026-06-01)— トークン冗長性の主張と76%研究、コスト構造(Uber/Microsoft/Goldman Sachs)、プロバイダキャッシュの TTL とコスト、可逆圧縮、競合ツール比較表。

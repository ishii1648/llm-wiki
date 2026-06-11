---
title: Context Rot (コンテキスト腐敗)
type: concept
aliases: [context rot, コンテキスト腐敗, lost in the middle, ロストインザミドル]
tags: [llm, context, quality, long-context, retrieval, evaluation]
created: 2026-06-11
updated: 2026-06-11
sources:
  - raw/articles/ai-tokens-ninety-percent-garbage.md
related:
  - "[[context-compression]]"
  - "[[conversation-management]]"
  - "[[project-headroom]]"
---

## 概要
**Context Rot(コンテキスト腐敗)** は、データ統合企業 Chroma の研究チームが名付けた現象で、**入力(コンテキスト)が長くなるほど LLM のパフォーマンスが低下する**こと。18の LLM を検証し**すべてのモデルで確認**された。コンテキストウィンドウを大量の情報で埋めることはコストが高いだけでなく、モデルを混乱させて回答の質を下げうる — トークン圧縮([[context-compression]])がコスト削減と精度向上を両立しうる根拠になっている。

## 詳細

### Lost in the Middle(中間無視)
- Stanford 大学の研究チームの発見: LLM は**コンテキストウィンドウの先頭と末尾に注意を集中させ、中間部分を無視する**傾向がある。
- 20件の文書から情報を検索するタスクで、関連文書が**先頭にあるとき75%**の精度だったが、**中間に移動すると55%**まで低下した。

### Context Rot(Chroma)
- Chroma がこの現象を「context rot」と命名。18の LLM を検証し、**入力が長くなるほどパフォーマンスが低下する**ことを全モデルで確認した。

### 含意 — 「賢いモデル」より「何を読ませるか」
- 情報を削って本質だけを渡す方が、むしろ賢い回答が返ってくるという逆説。問題は「モデルが賢いかどうか」ではなく「**モデルに毎回何を読ませているか**」に移っている(→ [[tejas-chopra]] / [[context-compression]])。
- これは [[conversation-management]] が context window 内に履歴を保ちながら関連性・一貫性を維持しようとする動機(トークン上限・性能・関連性・一貫性)と同根の問題。圧縮・要約・proactive compression は、コストだけでなく**品質**の観点からも正当化される。

> ⚠️ 出典の範囲: 本ページは二次情報(joho-todai.com の記事)に基づく。Stanford / Chroma の原論文・具体的な実験条件は当該記事の引用範囲を超えるため未収録。

## 出典
- `raw/articles/ai-tokens-ninety-percent-garbage.md`(情報の灯台「AIトークンの9割はゴミだった」2026-06-01)— Stanford の lost-in-the-middle(75%→55%)、Chroma の context rot(18モデル)、「情報を削る方が賢い回答」という逆説。

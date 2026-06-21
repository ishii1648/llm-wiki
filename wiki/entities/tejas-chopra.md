---
title: Tejas Chopra
type: entity
aliases: [Tejas Chopra, テジャス・チョプラ, チョプラ]
tags: [person, engineer, netflix, llm-cost]
created: 2026-06-11
updated: 2026-06-11
sources:
  - raw/articles/ai-tokens-ninety-percent-garbage.md
related:
  - "[[project-headroom]]"
  - "[[context-compression]]"
---

## 概要
**Tejas Chopra(テジャス・チョプラ)** は Netflix のシニアエンジニアで、トークン圧縮ツール [[project-headroom]] の作者。「LLM に送られるトークンの最大90%は冗長」という主張と、可逆圧縮によるコスト削減を提唱する。

> ⚠️ 出典の範囲: 本ページの記述は ingest 済みの記事1本に基づく。詳しい経歴・他の業績などの伝記情報は当該記事に含まれないため未収録(推測で補わない)。

## 詳細

### Headroom 開発の経緯
- Claude Sonnet で **$287(約4万5600円)の請求**を受け取ったことがきっかけ。作業内容はデバッグ・リファクタリング・MCP ツールによるデータベースクエリという「ごく普通の個人開発」。
- 請求の内訳を調べると、コストの大半を食っていたのは自分が書いた指示ではなく、機械が吐き出したボイラープレートとメタデータ(冗長な JSON スキーマ、ネストされたテンプレート、繰り返されるカラム定義)だった。
- これを「これは散文でも創作でもない。**テキストのふりをした圧縮可能なデータ**だ」と表現した。

### 主張
- トークンの **最大90%** が LLM にとって冗長(本人の推定)。問題は「モデルが賢いかどうか」ではなく「**モデルに毎回何を読ませているか**」に移っている、というのが核心の問い(→ [[context-compression]])。
- 2026年5月、Open Source Summit North America(ミネアポリス)で Headroom の成果(約 $700K 削減、2000億トークン削減)を講演した。

## 出典
- `raw/articles/ai-tokens-ninety-percent-garbage.md`(情報の灯台「AIトークンの9割はゴミだった」2026-06-01)— 肩書(Netflix シニアエンジニア)、$287 請求の逸話、主張、講演での報告。

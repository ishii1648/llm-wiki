---
title: Project Headroom
type: entity
aliases: [Project Headroom, Headroom, headroom]
tags: [tool, open-source, llm-cost, context-compression, proxy, netflix]
created: 2026-06-11
updated: 2026-06-11
sources:
  - raw/articles/ai-tokens-ninety-percent-garbage.md
related:
  - "[[tejas-chopra]]"
  - "[[context-compression]]"
  - "[[context-rot]]"
  - "[[model-context-protocol]]"
  - "[[conversation-management]]"
---

## 概要
**Project Headroom(プロジェクト・ヘッドルーム)** は、LLM に送られる context window の中身を **モデルに届く前に可逆圧縮する** オープンソースツール。Netflix のシニアエンジニア [[tejas-chopra]] が、Claude Sonnet で受け取った $287 の請求をきっかけに開発した。2026年1月に公開され、GitHub で 2000+ スター・120+ フォークを集める([[context-compression]] の代表的実装)。

> ⚠️ 出典の範囲: 本ページは joho-todai.com の記事1本に基づく二次情報。Netflix **公式プロジェクトではない**(社内の複数チームが利用)。バージョン・数値は記事時点(0.22、2026-06)のもの。

## 詳細

### 何を圧縮するか
LLM に届く context window(モデルが一度に読む入力と出力の全領域)全体が対象。会話履歴に加え、**ログ・ツール出力・ファイル・RAG が引っ張ってきたドキュメント断片**を圧縮する。Chopra の主張では、コストの大半を食うのは人が書いた指示ではなく、冗長な JSON スキーマ・ネストされたテンプレート・繰り返されるカラム定義といった「テキストのふりをした圧縮可能なデータ」(→ [[context-compression]])。

### 動作形態
- **Python と Node.js** で動作。エンジニアのローカルマシン上で**プロキシ(ポート 8787)**として稼働。
- `headroom wrap codex` のように LLM をラップすると入力が自動的にパースされる。
- 処理がローカルワークフローに閉じ、**データが外部サービスに送信されない**点が、API 圧縮サービスに対する企業利用での差別化要因(→ 比較は [[context-compression]])。

### 圧縮パイプライン(多段)
1. **CacheAligner** — 既入力との変更部分だけを検出し**差分のみ送る**。KV キャッシュ(プロバイダがコンテキストを保持するキャッシュ)の全置換を回避する。system prompt に日付フィールドやセッションごとに変わる UUID が混じるだけで毎回キャッシュミスが起き、コストが跳ね上がるという問題への対処。
2. **ルーター** — コンテンツの種類を推定し適切なコンプレッサーに振り分ける。
3. **コンプレッサー群** — **AST(抽象構文木)コンプレッサー**がコードを、**JSON コンプレッサー**と **DOM コンプレッサー**がそれぞれ JSON と Web のボイラープレートを削る。**「スカッシャー」**(統計分析ベースのフィルター)が関連性のある部分だけを残す。
4. **CCR(Compress Cache and Retrieve)** — Headroom の設計思想を象徴する仕組み。圧縮箇所にマーカーを残し、LLM が原文を必要とした場合は **Headroom の MCP サーバー**(→ [[model-context-protocol]])経由でローカルマシンから取得できる。**圧縮は可逆**で、原文は Redis または SQLite に保存される(要約=不可逆との決定的な違い)。

### 圧縮が効くデータ
サーバログ(90%削減可能)/ MCP ツール出力(70%が冗長な JSON)/ データベース出力(スキーマは1つ)/ ファイルツリー(メタデータの繰り返し)。

### 採用・実績(記事時点)
- 2026年1月に OSS 公開。Open Source Summit North America(2026年5月、ミネアポリス)の講演で報告: 推定**約 $700K(約1億1100万円)のコスト削減**、ユーザー全体で削減トークン数**2000億**。
- GitHub: 2000+ スター、120+ フォーク。現在 **v0.22**(初期段階)。
- ロードマップ: テスト精度の検証強化、音声・画像・動画への対応拡大、マルチモデル環境でトークン出所を追跡するツール **「Headlight」** の公開。
- 応用事例: 音声アプリのフォーク(沈黙すらトークンを生成し、自然な応答に 200ms 以内が要るためレイテンシ削減に活用)。

## 出典
- `raw/articles/ai-tokens-ninety-percent-garbage.md`(情報の灯台「AIトークンの9割はゴミだった」2026-06-01)— 開発経緯、動作形態、CacheAligner/ルーター/各コンプレッサー/CCR の多段構成、効くデータ、採用実績と数値、ロードマップ。
- GitHub: https://github.com/chopratejas/headroom (記事の参照元として記載)

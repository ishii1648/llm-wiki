---
title: OpenCode Go
type: entity
aliases: [OpenCode Go, Opencode Go]
tags: [product, subscription, ai-gateway, claude-code]
created: 2026-07-05
updated: 2026-07-05
sources:
  - raw/articles/opencode-go-with-claude-code.md
related:
  - "[[claude-code-non-anthropic-models]]"
  - "[[kristof-kovacs]]"
---

## 概要
**OpenCode Go** は、複数の LLM プロバイダのモデルへのアクセスを提供するサブスクリプションサービス(エンドポイントは `https://opencode.ai/zen/go/`)。提供モデルの一部は Anthropic Messages API 互換(`@ai-sdk/anthropic` パッケージ)で叩けるため、Claude Code のバックエンドとして差し替えて使うことができる([[claude-code-non-anthropic-models]] 参照)。

## 詳細
- モデル一覧は OpenCode Go 公式サイト(`https://opencode.ai/docs/go/#endpoints`)の "AI SDK PACKAGE" 列で確認でき、`@ai-sdk/anthropic` と表示されているものだけが Claude Code から Anthropic 互換で呼び出せる。
- 2026-06-14 時点で Anthropic 互換だったのは **MiniMax** と **Qwen** 系モデルで、上位モデルは `minimax-m3` / `qwen-3.7-plus` / `qwen-3.7-max`。
- 性能評価(著者所感、推測含む): 「Opus レベルには届かないが、数ヶ月前の Opus 程度」。

> ⚠️ 陳腐化に注意: モデルラインナップは執筆時点(2026-06-14)のスナップショットであり、OpenCode Go 側で随時変わりうる。最新情報は公式サイトを確認すること。

## 出典
- `raw/articles/opencode-go-with-claude-code.md`(Kristof Kovacs, "Using your Opencode Go subscription in Claude Code", 2026-06-14)

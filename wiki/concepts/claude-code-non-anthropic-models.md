---
title: Claude Code で非 Anthropic モデルを使う(Anthropic 互換ゲートウェイ経由)
type: concept
aliases: [Claude Code non-Anthropic models, Claude Code model backend swap]
tags: [claude-code, llm-gateway, environment-variables, devops]
created: 2026-07-05
updated: 2026-07-05
sources:
  - raw/articles/opencode-go-with-claude-code.md
related:
  - "[[opencode-go]]"
  - "[[kristof-kovacs]]"
---

## 概要
Claude Code は環境変数でモデルのリクエスト先(`ANTHROPIC_BASE_URL`)と使うモデル名を差し替えられるため、Anthropic Messages API 互換のエンドポイントを提供するゲートウェイ経由であれば、Claude Code というハーネスはそのままに中身のモデルだけを非 Claude モデルに置き換えて動かせる。[[kristof-kovacs]] のブログ記事は [[opencode-go]] を例にこの手順を示している。

## 詳細

### 設定方法
以下の環境変数を設定するだけで、Claude Code の Opus/Sonnet/Haiku 相当・サブエージェント全てを指定モデルに向け替えられる:

```
export ANTHROPIC_DEFAULT_OPUS_MODEL=minimax-m3
export ANTHROPIC_DEFAULT_SONNET_MODEL=minimax-m3
export ANTHROPIC_DEFAULT_HAIKU_MODEL=minimax-m3
export CLAUDE_CODE_SUBAGENT_MODEL=minimax-m3

export ANTHROPIC_BASE_URL="https://opencode.ai/zen/go/"
export ANTHROPIC_AUTH_TOKEN=""
export ANTHROPIC_API_KEY="$OPENCODE_API_KEY"
```

### 制約: 使えるのは Anthropic 互換モデルのみ
ゲートウェイ側が提供する全モデルが使えるわけではない。[[opencode-go]] の場合、モデル一覧の "AI SDK PACKAGE" 列が `@ai-sdk/anthropic` になっているものだけが対象。2026-06-14 時点では MiniMax / Qwen 系(`minimax-m3`, `qwen-3.7-plus`, `qwen-3.7-max`)がこれに該当する。

### 性能・動機
- 性能は現行の Opus には及ばず「数ヶ月前の Opus 程度」と著者は評価している(推測含む所感)。
- 著者はこれを、有料の Claude サブスクリプションを持たずに Claude Code ハーネスの新機能を試すための、最も安く手軽な方法として使っている。普段 Claude モデル自体が必要なときは OpenRouter 経由で使っている、とも述べている。
- 著者の考え: 安いモデルで使いこなせれば、高いモデルでも間違いなく使いこなせるようになる。

## 出典
- `raw/articles/opencode-go-with-claude-code.md`(Kristof Kovacs, "Using your Opencode Go subscription in Claude Code", 2026-06-14)— 環境変数設定、対応モデル、動機の全記述。

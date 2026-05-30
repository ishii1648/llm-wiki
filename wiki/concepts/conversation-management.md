---
title: Conversation Management
type: concept
aliases: [conversation management, 会話管理, ConversationManager, conversation manager]
tags: [strands, agent, context, conversation, token-limit]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-conversation-management.mdx
related:
  - "[[strands-agents]]"
  - "[[agent-loop]]"
  - "[[state-management]]"
  - "[[mcp-tools]]"
---

## 概要
**Conversation Management(会話管理)** は、会話 context(user/agent メッセージ・ツール結果・system prompt)を `ConversationManager` インタフェースで管理する仕組み。トークン上限・性能・関連性・一貫性のために、履歴を context window 内に保ちながら重要情報を保つ。

## 詳細

### 組み込み Conversation Manager(3種)
| Manager | 挙動 | 用途 |
|---|---|---|
| `NullConversationManager` | 履歴を変更しない | 短い会話・デバッグ・手動管理 |
| `SlidingWindowConversationManager` | 直近 N メッセージを保持(**デフォルト**) | 多くのアプリ |
| `SummarizingConversationManager` | 古いメッセージを要約して保持 | 長時間タスク・情報保全 |

> ⚠️ **現状コードでは未指定 = デフォルトの sliding window**。Investigation Assistant のように MCP tools 経由で大量 context を抱える構成(→ [[mcp-tools]])では、`SummarizingConversationManager` への切替や proactive compression の明示制御を検討すべき。

### SlidingWindowConversationManager(デフォルト)
```python
SlidingWindowConversationManager(
    window_size=20,
    should_truncate_results=True,  # 大きすぎるツール結果を切り詰め
)
```
- window 超過時に古いメッセージを除去。**dangling message cleanup**(不完全なメッセージ列の除去)で会話状態の妥当性を保つ。
- **overflow trimming**: context 溢れ時、リクエストが収まるまで最古から削る。
- **tool result truncation**: 既定で有効。テキストは先頭・末尾を残し `<truncated chars="N"/>` を挿入、画像/動画/巨大 JSON は型付きプレースホルダ(例 `[image: png, source: bytes, 12345 bytes]`)に置換。`status`/`error` は保持。
- **per_turn**(Python): `True` で毎モデル呼び出し前、整数 `N` で N 回ごとに管理を前倒し適用。ツール呼び出しが多い長時間ループに有用(TS は非対応)。

### SummarizingConversationManager
古いメッセージを破棄せず要約。主要パラメータ:
- `summary_ratio`(既定 0.3、0.1–0.8 にクランプ): 削減時に要約する割合。
- `preserve_recent_messages`(既定 10): 常に残す直近メッセージ数。
- `summarization_agent`(任意): 要約専用 agent(別モデル=より安価/高速にできる)。`summarization_system_prompt` とは併用不可。
- `summarization_system_prompt`(任意): ドメイン特化の要約プロンプト。
- 特徴: context 自動縮小 / 構造化 bullet 要約 / **tool use と result のペアを壊さない** / fallback safety。

### Proactive Context Compression(先回り圧縮)
既定の manager は**リアクティブ**(モデルが overflow を返してから縮小)。`proactive_compression`(TS: `proactiveCompression`)を渡すと、**モデル呼び出し前**に投影入力トークンが閾値(既定 0.7 = context window の 70%)を超えた時点で縮小する。

```python
SlidingWindowConversationManager(
    window_size=50,
    proactive_compression={"compression_threshold": 0.7},
)
```
- `BeforeModelCallEvent` ごとに発火するため、ツール使用サイクル内でも **自動 in-loop 圧縮** が効く。best-effort で、失敗してもモデル呼び出しは続行。
- 閾値判定にはモデルの `contextWindowLimit` が必要。既知モデルは自動補完、未知モデルは `context_window_limit=128_000` 等で手動上書き。
- **トークン推定**: 直近 assistant メッセージの `metadata.usage` をベースに差分を `countTokens()` で見積もる(文字数 ÷4、JSON は ÷2 のヒューリスティック。プロバイダによっては native トークンカウント可)。

### カスタム ConversationManager
Python は `apply_management` / `reduce_context` / `removed_message_count`(/任意 `register_hooks`)を実装。TS は抽象 `ConversationManager` を継承し `reduce(options)` を実装(`initAgent` で proactive 管理を追加。`super` 呼び出し必須)。

## 出典
- `raw/articles/strands-conversation-management.mdx` — 3種 manager の挙動・パラメータ、per_turn、proactive compression、トークン推定、カスタム実装。

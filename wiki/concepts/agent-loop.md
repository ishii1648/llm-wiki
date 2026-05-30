---
title: Agent Loop
type: concept
aliases: [agent loop, エージェントループ, event loop]
tags: [strands, agent, core, loop]
created: 2026-05-30
updated: 2026-05-30
sources:
  - raw/articles/strands-agent-loop.md
related:
  - "[[strands-agents]]"
  - "[[conversation-management]]"
  - "[[state-management]]"
  - "[[custom-tools]]"
---

## 概要
**Agent Loop(エージェントループ)** は、モデルの「推論」と「行動(ツール実行)」のサイクルを管理する [[strands-agents]] のオーケストレーション層であり、最も基礎的な概念。言語モデルは「質問に答える」だけだが、agent loop によってエージェントは「何かを実行する(do things)」ことができる。

## 詳細

### ループの動作原理
単純な原則で動く: **モデルを呼ぶ → ツールを使いたいか確認 → 使うなら実行 → 結果を添えて再びモデルを呼ぶ → 最終応答が出るまで繰り返す**。

```
Reasoning(LLM) → Tool Selection → Tool Execution → (戻る)Reasoning ...
```

強力さの源泉は **context の蓄積**。各反復で会話履歴に追記され、モデルは元の要求だけでなく、これまで呼んだ全ツールと全結果を見る。これが高度な多段推論を可能にする。

### メッセージと会話履歴
メッセージは `user` / `assistant` の2ロールで流れる(→ [[state-management]])。
- **user メッセージ**: 初期要求、フォローアップ指示、過去ツールの結果、メディア。
- **assistant メッセージ**: テキスト応答、ツール使用要求、reasoning trace。

会話履歴はループ反復をまたいで全メッセージを蓄積する「作業記憶」。これを context window 内に収めるのが [[conversation-management]] の役割。

### ツール実行
モデルがツールを要求すると、実行系は schema 検証 → registry から特定 → エラーハンドリング付きで実行 → 結果をツール結果メッセージに整形。**ツール失敗時は例外でループを終了させず、エラー結果としてモデルに返す**ので、モデルは回復・代替を試みられる。

### Stop Reason(停止理由)
各モデル呼び出しは stop reason で終わり、次の挙動を決める:
- **End turn**: 正常終了。最終メッセージを返す。
- **Tool use**: ツールを実行し結果を履歴に追加して再びモデル呼び出し。
- **Cancelled**: `agent.cancel()` による外部停止。
- **Max tokens**: トークン上限で切れた。現ループ内では回復不能でエラー終了。
- **Stop sequence**: 設定した停止シーケンス到達。正常終了。
- **Content filtered** / **Guardrail intervention**: 安全機構/ガードレールによる停止。

### ライフサイクルとキャンセル
- 各 invocation・各モデル呼び出し・各ツール実行の前後でライフサイクルイベントを発火(→ hooks。[[plugins]] が利用)。
- `agent.cancel()` はスレッドセーフ・冪等。チェックポイント(ループ先頭・ストリーミング中・ツール実行前・逐次ツール間)で停止。`stop_reason="cancelled"` を返し、signal は自動クリアされ再利用可。TS では `cancelSignal`(`AbortSignal`)も渡せる。
- ツール実行中のキャンセルは **協調的(cooperative)**: ツール自身が signal を転送/ポーリングしない限り完走する。

### よくある問題
- **Context Window Exhaustion**: ツール出力を要約/抜粋に絞る、schema を単純化、[[conversation-management]] で戦略設定、タスク分割。
- **不適切なツール選択**: 曖昧なツール説明が原因。説明を見直す。
- **MaxTokensReachedException**: context 縮小・上限引き上げ・タスク分割で対処。

## 出典
- `raw/articles/strands-agent-loop.md` — ループの仕組み、メッセージ、ツール実行、stop reason、キャンセル、よくある問題のすべて。

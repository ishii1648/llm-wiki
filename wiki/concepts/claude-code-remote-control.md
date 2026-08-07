---
title: Remote Control(Claude Code)
type: concept
aliases: [Remote Control, リモートコントロール, remote-control, claude remote-control]
tags: [claude-code, remote-control, mobile, security, trusted-devices]
created: 2026-07-10
updated: 2026-08-07
sources:
  - raw/articles/claude-code-remote-control.md
  - raw/articles/claude-code-remote-control-ja.md
related:
  - "[[loop-engineering]]"
  - "[[mcp-tools]]"
  - "[[self-hosted-environment]]"
---

## 概要
**Remote Control** は、claude.ai/code や Claude モバイルアプリ(iOS/Android)から、**手元のマシンで動いている Claude Code セッションをそのまま操縦する**機能(research preview、全プランで利用可能)。[[loop-engineering]] で扱う Channels(外部イベントをセッションへ push する)とは逆方向で、こちらは**人間がリモートから能動的にセッションを操縦する**ための primitive。

## 詳細

### 仕組み — セッションは常にローカルで動く
Remote Control を開始しても Claude はローカルマシン上で動き続け、クラウドには一切移らない。web/モバイル UI は「そのローカルセッションへの窓」に過ぎない。これにより:
- ファイルシステム・[[mcp-tools]](MCP サーバー)・ツール・プロジェクト設定がそのまま使える。
- 端末・ブラウザ・スマホから相互に交換可能にメッセージを送信でき、会話は全デバイス間で同期される。
- スマホ/ブラウザから画像・ファイル添付を送ると、Claude Code がローカルにダウンロードし `@` file reference として Claude に渡す。
- ラップトップのスリープやネットワーク切断からは、オンライン復帰時に自動再接続する。

対して [Claude Code on the web] はクラウドインフラ上でセッションを実行する別機能で、ローカルファイルにはアクセスしない(「クローンしていない repo で作業したい」「並列に複数タスクを走らせたい」場合はこちらが適する)。この cloud session を Anthropic のインフラではなく**自社インフラで実行させる**のが [[self-hosted-environment]](Team/Enterprise の public beta)で、公式ドキュメントも「常時稼働の自分のマシンを他デバイスから操縦したいだけなら Remote Control(Pro/Max でも可)」と両者を明確に切り分けている。

### 起動方法(3経路)
| 方法 | コマンド | 特徴 |
|---|---|---|
| サーバーモード | `claude remote-control` | ターミナルは接続待受のまま。`--spawn worktree` で on-demand セッションごとに独立 git worktree、`--capacity N`(既定32)で同時セッション上限、QR コード表示可 |
| 対話セッション | `claude --remote-control`(`--rc`) | 通常の対話セッションとしてローカルでも入力しつつリモートからも操縦できる |
| 既存セッションから | `/remote-control`(`/rc`) | 今の会話履歴を引き継いだままリモート化する |

VS Code 拡張では `/remote-control` コマンドで同様に接続する(v2.1.79+)。`--name` でセッション名を指定でき、未指定時は `myhost-graceful-unicorn` のような自動生成名になる。

### 接続とセキュリティ
- ローカルセッションは **アウトバウンド HTTPS のみ**で、インバウンドポートは一切開かない。Anthropic API に登録してポーリングし、別デバイスからの接続はこの API 経由でストリーミングリレーされる。
- 認証は claude.ai OAuth 必須(API キー認証は非対応)。`claude setup-token`/`CLAUDE_CODE_OAUTH_TOKEN` の推論専用トークンでも確立できない。
- `ANTHROPIC_BASE_URL` が `api.anthropic.com` 以外(LLM gateway/proxy 等)を指している場合は無効(v2.1.196+)。Amazon Bedrock/Google Cloud's Agent Platform/Microsoft Foundry でも利用不可。

### Enterprise 制御と Trusted Devices
- Team/Enterprise では **デフォルト OFF**。Owner が [Claude Code admin settings] の Remote Control トグルを有効化するまで使えない(Channels の `channelsEnabled` と同じ構造)。IT 管理者は managed settings の `disableRemoteControl` で個別デバイス単位にも無効化できる。
- **Trusted Devices**(β、Team/Enterprise、既定 OFF): 組織全体で「登録済みデバイス」+「18時間以内のサインイン」の両方を Remote Control 利用の必須条件にできる追加のセキュリティ層。生体認証(Face ID/Touch ID/Windows Hello/passkey)でサインインの鮮度を確認する仕組みで、指紋や顔データ自体は Anthropic に送られない(公開鍵とデバイスメタデータのみ保存)。適用は Remote Control のみで、通常の Claude チャットやターミナルの Claude Code、API 利用には影響しない。有効化後に開始されたセッションのみが対象(遡及保護なし)。

### 制限事項
- 対話型プロセスごとに同時リモートセッションは1つ(複数同時に受けたい場合はサーバーモードを使う)。
- ローカルプロセス(ターミナル/VS Code)を閉じるとセッションは終了する。常時稼働させたいなら残し続ける必要がある。
- ネットワーク断が約10分を超えるとセッションはタイムアウトして終了する。
- Ultraplan セッション開始は Remote Control を切断する(両方とも claude.ai/code の同じインターフェースを占有するため)。
- `/plugin`・`/resume` 等の対話的ピッカーを開くコマンドはローカル CLI 専用。`/compact`・`/mcp`・`/config` 等のテキスト出力コマンドはモバイル/web からも実行できる。

### モバイルプッシュ通知
Remote Control が有効な間、長時間タスクの完了時や判断が必要な時に Claude がスマホへ push 通知を送れる(`/config` で "Push when Claude decides"/"Push when actions required" を有効化)。プロンプトで明示的に依頼も可能(例: `notify me when the tests finish`)。イベント単位の細かい設定はなく、on/off の2トグルのみ。

### 関連機能との使い分け(公式の "Choose the right approach")
| 機能 | トリガー | Claude の実行場所 | 向いている用途 |
|---|---|---|---|
| Dispatch | モバイルアプリからタスクをメッセージ | 自分のマシン(Desktop、要ペアリング) | 離席中の作業委任、最小セットアップ |
| **Remote Control** | claude.ai/code やモバイルアプリから操縦 | 自分のマシン(CLI/VS Code) | **進行中の作業を別デバイスから操縦** |
| [[loop-engineering|Channels]] | チャットアプリ(Telegram/Discord)や自前サーバーからの push | 自分のマシン(CLI) | CI 失敗やチャットメッセージなど外部イベントへの反応 |
| Slack | チームチャンネルでの `@Claude` メンション | Anthropic クラウド | チームチャットからの PR・レビュー |
| Scheduled tasks | スケジュール設定 | CLI/Desktop/クラウド | 毎日のレビュー等、定期自動化 |

Dispatch はこの表で初出の別機能で、本 wiki は未 ingest。

## 出典
- `raw/articles/claude-code-remote-control.md`(Claude Code 公式ドキュメント、英語)— 概要、要件、起動方法3経路とフラグ、接続とセキュリティ、Trusted Devices、Remote Control vs Claude Code on the web、モバイルプッシュ通知、制限事項、トラブルシューティング、Choose the right approach 比較表のすべて。
- `raw/articles/claude-code-remote-control-ja.md`(同上、日本語版)— 英語版と技術的内容が一致する忠実な翻訳。本文への追加反映なし、出典として並記のみ。

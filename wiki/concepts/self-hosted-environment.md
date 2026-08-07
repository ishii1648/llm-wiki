---
title: Self-hosted environments(Claude Code)
type: concept
aliases: [self-hosted environment, セルフホスト環境, self-hosted environments, BYOC, bring your own compute, cloud session]
tags: [claude-code, self-hosted, cloud-session, infrastructure, security, enterprise]
created: 2026-08-07
updated: 2026-08-07
sources:
  - raw/articles/claude-code-self-hosted-environments.md
  - raw/articles/claude-code-self-hosted-environments-deploy.md
related:
  - "[[self-hosted-runner]]"
  - "[[self-hosted-runner-extensions]]"
  - "[[session-identity-token]]"
  - "[[claude-code-remote-control]]"
---

## 概要
**Self-hosted environments** は、Claude Code の **cloud session** を自社が運用するインフラ上で実行させる仕組み(2026-08 時点で public beta、Team/Enterprise 限定、既定 OFF)。移るのは**セッションの実行だけ**で、キューイング・claude.ai の UI・セッション記録といった制御プレーンは Anthropic 側に残る。実行主体である runner プロセスの運用は [[self-hosted-runner]] を参照。

## 詳細

### cloud session とは / どこまでが対象か
cloud session は「開発者のマシン以外で動くセッション」の総称で、claude.ai・モバイル/デスクトップアプリ・ターミナルの `claude --cloud`・scheduled routines から起動される。既定では Anthropic のインフラで実行され、self-hosted environment を選ぶと同じセッションが自社ネットワーク内で走る。開発者体験は(下記の制限と既知の問題を除いて)変わらない。

- ターミナル/IDE のセッションは**常に開発者のマシンで動く**ので、cloud session を使わないチームには設定するものが何もない。
- 「自分の常時稼働マシンで動く Claude Code を他デバイスから操縦したい」だけなら [[claude-code-remote-control]] が該当機能で、こちらは Pro/Max でも使える。

### 3つの構成要素
| 用語 | 実体 |
|---|---|
| Environment | セッションの送り先となる名前付きの宛先。claude.ai の admin settings で作成し、runner の集合をまとめる。API フィールド・トークンクレーム・メトリクス名では `pool` と綴られ、ID は `ccpool_...` |
| Environment secret | runner が環境へ認証・登録するための唯一の共有クレデンシャル。作成時に1度だけ表示され後から取得できず、365日で失効。admin UI 上のラベルは **environment key** |
| Runner | 自社ホスト上で動かす長命プロセス。環境に登録して runner トークンを受け取り、仕事をポーリングする。発想は self-hosted CI runner と同じ |
| Session | 開発者が始めた1つの Claude Code タスク。runner が子 Claude Code プロセスとして spawn する |

### セッションが流れる経路
1. 開発者がセッション開始 UI の environment picker で自社環境を選ぶ(Anthropic ホスト環境と並んで表示される)。
2. Anthropic の制御プレーンが、その環境のキューにセッションを載せる。
3. 空き容量のある runner が claim して lease を保持し、リポジトリを clone して子プロセスを spawn する。
4. 子プロセスは HTTPS でイベントをストリーム返しし、runner のポーリングが lease 更新とハートビートを兼ねる。
5. runner のポーリングが**約60秒**止まると、サーバはセッションを別 runner へ requeue する。

### ネットワークはすべてアウトバウンド
Anthropic 側から自社ネットワークへの inbound 接続は一切必要ない。runner の制御プレーンポーリング、セッションのイベントストリーム、モデル推論、git — いずれも自社からの outbound HTTPS で、唯一の WebSocket は orchestrator の SCM connector(GitHub Enterprise Server を内側から中継する任意機能)だけ。企業の egress プロキシは `HTTPS_PROXY` / `NO_PROXY` 等の環境変数で対応するが、**セッションのストリームは SSE なのでレスポンスをバッファするプロキシは使えない**。

egress の必須先は次の2つのみ:

| ホスト | 用途 |
|---|---|
| `api.anthropic.com` | runner 制御プレーン、セッションストリーム、モデル推論、feature flag、[[session-identity-token]] の JWKS 取得、commit signing、git proxy 利用時の git、SCM connector トンネル |
| 自社の git ホスト | clone / push(`--use-anthropic-git-proxy` を使う場合は不要) |

条件付きで必要になるのは `downloads.claude.ai`(インストール時・公式マーケットプレイスの plugin)、`storage.googleapis.com`(plugin カタログ・Artifact)、`code.claude.com` / `claude.com`(ドキュメント参照)、`*.frame.claudeusercontent.com`(Artifact ツール)、`raw.githubusercontent.com`(リリースノート)、`registry.npmjs.org`(plugin の Node 依存・`npx` 起動の MCP サーバ)、Datadog 2ホスト(既定 OFF)。

逆に**ドキュメントが明示的に「不要」と述べているホスト**があるのが実務上重要で、`statsig.anthropic.com`・`*.sentry.io`・`claude.ai`・`platform.claude.com`・`mcp-proxy.anthropic.com` は古い企業向けチェックリストに載っていても runner/セッションのために開ける必要はない。ただし**ホスト側の作業**(ワンライナーインストーラの `install.sh` 取得と対話的な `claude auth login`)は `claude.ai` 等に到達するので、セッションコンテナの egress を広げるのではなく別ホストから実行する。

### 何が自社に残り、何が残らないか
- **残る**: リポジトリの checkout、ビルド成果物、シークレット、セッションが作成・変更したファイル。
- **残らない**: 会話そのもの(プロンプト・応答・ツール実行結果)はモデル推論のため `api.anthropic.com` へ送られ、transcript は Anthropic 側に保存される(どのサーフェスからでもセッションを再開できるようにするため)。セッションのオーケストレーション・キュー・claude.ai の UI も Anthropic ホストのまま。

> つまり self-hosted environment が動かすのは**実行だけで、制御プレーンではない**。コンプライアンス上の主張も「checkout と成果物が自社に留まる」までで、「会話内容が外に出ない」ではない。

### 可用性と制限(2026-08 時点)
- **プラン**: Team/Enterprise の public beta。既定 OFF で、Owner または admin が **Cloud environments** admin ページの *Allow self-hosted environments* を有効化する。前提として組織で Claude Code on the web が有効である必要がある。
- **Zero Data Retention を有効にしている組織では利用できない**。
- **推論経路は固定**: セッションは Anthropic API を使う。Amazon Bedrock / Google Cloud's Agent Platform / Microsoft Foundry / LLM gateway 経由には**できない**。制御プレーンが配る推論クレデンシャルが Anthropic 発行のセッションスコープ OAuth トークンで、他プロバイダが受け付けないため。
- **対応サーフェス**: web、モバイル/デスクトップアプリ、scheduled routines、`claude --cloud`、スクリプトからの `--environment` dispatch。Claude Tag(Slack)・Claude Security・Code Review のセッションは**まだ回らない**。
- **リポジトリ**: GitHub からの checkout。
- **課金**: Anthropic ホスト環境と同じく組織の Claude Code 利用量を消費する(自前インフラで動かしても利用量は減らない)。

### 自前で持つ理由と、その代償
ドキュメント自身が「大半のチームは Anthropic ホスト環境の方が適する」と明言しており、self-host は**ネットワーク・ツール・コンプライアンス要件がそれを要求するチーム向け**と位置づけられている。

| 得るもの | 負うもの |
|---|---|
| 内部サービス・DB・レジストリへ、公開せずに到達できる | runner イメージのビルドと保守 |
| コンパイラ・SDK・社内 CLI をイメージにプリインストールできる | fleet の運用(スケール・アップグレード・監視) |
| checkout とビルド成果物が自社管理のインフラに留まる | ネットワーク境界の設計と維持 |

### 脅威モデル — 何が既定で開いているか
- runner は**組織の任意のメンバーが投げたタスクについて、モデルが生成した任意コードを自社インフラ上で実行する**。environment 単位の dispatch アクセス制御は存在せず、dispatch は組織全体に開かれている。`--lock-to-account` は「そのホストがどのアカウントのセッションを実行するか」を縛るだけで、環境への dispatch 自体は縛れない。したがって**組織の誰にも読まれてよいデータ・クレデンシャルしか runner ホストに置いてはいけない**。
- 既定の pre-approved ツールに `Bash` が含まれるため、permission mode によらずシェル経由の外部通信は人間の承認なしに走る。**default-deny egress が実質的に唯一の境界**になる。
- 組織の IP allowlist は既定では runner トラフィックに適用されない。ネットワーク制御として当てにせず、自社の境界で default-deny を適用する。
- 具体的なハードニング項目は [[self-hosted-runner]]、セッションからの内部サービス呼び出しを検証する仕組みは [[session-identity-token]]。

### 既知の制限(beta)
- **connector のトラフィックは自社ネットワークを通らない**: GitHub/Slack/Linear などの claude.ai connector は Anthropic 側から呼ばれる。ネットワーク内に留めたいなら同等機能をローカル MCP サーバとして runner イメージに持たせる(→ [[self-hosted-runner-extensions]])。
- **再開したセッションは未 push の作業を失う**: idle release や runner 再起動でセッションが解放されると、次のメッセージで別 runner が元ブランチから clone し直す。`--push-outcome-on-release` は commit 済みの作業だけを救う(dirty な working tree は救わない)。
- **セッション開始後にプライベート repo を追加できない**: 必要な repo はセッション作成時に全部選ぶ。
- **未接続の connector はセッション内に現れない**: claude.ai の Settings で先に接続し、セッションを取り直す。

## 出典
- `raw/articles/claude-code-self-hosted-environments.md`(Claude Code 公式ドキュメント)— 3構成要素、セッション/runner ライフサイクル、ネットワーク経路、可用性と制限、self-host の理由、自社に残るもの。
- `raw/articles/claude-code-self-hosted-environments-deploy.md`(同)— egress の必須/条件付き/不要ホスト、default-deny egress、脅威モデル(組織全体 dispatch・IP allowlist 非適用)、既知の制限。

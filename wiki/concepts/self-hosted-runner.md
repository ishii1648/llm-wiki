---
title: Self-hosted runner(Claude Code)
type: concept
aliases: [self-hosted runner, セルフホストランナー, claude self-hosted-runner, ccr runner]
tags: [claude-code, self-hosted, runner, kubernetes, operations, observability, security]
created: 2026-08-07
updated: 2026-08-07
sources:
  - raw/articles/claude-code-self-hosted-environments-quickstart.md
  - raw/articles/claude-code-self-hosted-environments-deploy.md
  - raw/articles/claude-code-self-hosted-environments-reference.md
  - raw/articles/claude-code-self-hosted-environments-testing.md
related:
  - "[[self-hosted-environment]]"
  - "[[self-hosted-runner-extensions]]"
  - "[[session-identity-token]]"
---

## 概要
**runner** は [[self-hosted-environment]] においてセッションを実際に実行するプロセス。専用バイナリではなく**標準の `claude` バイナリのサブコマンド** `claude self-hosted-runner`(v2.1.224 以降)で、Anthropic は runner イメージを配布しないため**自分でビルドして運用する**。このページは runner 自体の立ち上げ・ライフサイクル・フラグ・監視・トラブルシュートを扱う。wrapper script や lifecycle hook による拡張は [[self-hosted-runner-extensions]]。

## 詳細

### 前提と最小構成
ホスト要件:
- **Linux または macOS**。Windows は runner ホストとして非対応(Linux コンテナで動かす)。
- `api.anthropic.com`・インストール用ホスト・git ホストへの outbound HTTPS。
- **NTP 等で時刻同期**。5分以上ずれると認証が失敗する。
- Claude Code **v2.1.224 以降**と **git 2.24 以降**。`claude self-hosted-runner --help` が runner の usage を出せば OK(古いバージョンでは `claude --help` が出る)。native installer の既定 `latest` チャネルは即時、`stable` / Homebrew cask / stable apt・dnf・apk は約1週間遅れる。

立ち上げは2通り:
- **ガイド付き**: `claude self-hosted-runner setup` — Owner/admin でサインイン済みのマシンで対話的セッションが環境作成・runner 起動・登録確認まで案内し、`./runner-setup/CHEAT-SHEET.md` を書き出す。API キーや third-party provider では使えない。
- **手動**: admin UI で環境を作成 → environment secret をファイルへ(`(umask 077 && cat > /etc/claude/environment-secret)` で履歴とパーミッションを汚さない)→ `claude self-hosted-runner --environment-secret-file <path> --base-dir <writable-dir>`。

secret の紛失・ローテーションは「環境の Configuration タブで新 secret 作成 → fleet へ配布 → 旧 secret を revoke」の順。revoke された secret を持つ runner は次のポーリングで `poll auth failed` を吐いて exit するので、orchestrator が新 secret で再起動する形になる。

### runner ライフサイクル — 1 runner = 1 ユーザー
これが fleet 設計を決める最重要ルール。

- **最初に拾ったセッションのアカウントに runner がロックされる**。以後はそのアカウントのセッションだけを `--capacity` の上限まで実行する。checkout されたコードがユーザー間で混ざらないための仕組み。
- したがって **fleet の最小数 = 同時にアクティブなユーザー数**。`--capacity` は「1ユーザー内の並列度」であって、ユーザー間の並列度ではない。
- アクティブなセッションが終わった後の挙動は `--drain-grace-sec` 次第:
  - 既定 `0`: 追加のポーリングをせず即 exit。orchestrator(Kubernetes 等)が**まっさらなディスクで再起動**し、次は任意のアカウントに使える。
  - 正の値: その秒数だけロック中アカウントのキューをポーリングし続けてから exit。
- **`SIGTERM` なら追加フラグ不要**でドレインする。逆に**シグナルなしで既知時刻にホストが壊される**環境(sandbox の寿命上限、spot インスタンスの回収)では `--retire-at <epoch-seconds>` をその数分前に設定する。retire 時刻で新規受付を停止 → 各セッションを release パスで解放(mid-turn ならターン終了時、バックグラウンドタスクが残っていても最大60秒で解放)→ 全解放後に exit 0。`--retire-at` なしのシグナルレス kill はクラッシュと区別できず、制御プレーンは lost worker として記録し requeue する。

### 主要フラグ
全量は `claude self-hosted-runner --help` とリファレンス。実務で効くものを抜粋:

| フラグ | 既定 | 効き方 |
|---|---|---|
| `--environment-secret-file <path>` | 必須 | environment secret、または orchestrator が発行した単回の work-order JWT のパス。旧 `--pool-secret-file` も動くが deprecation 警告が出る |
| `--base-dir <path>` | `/workspace` | checkout とセッション作業ディレクトリの親。**環境内の全 runner で同じ値にする** |
| `--capacity <n>` | `1` | 同時セッション数(全て同一ロックアカウント)。**環境内で揃える** |
| `--drain-grace-sec <n>` | `0` | 上記ライフサイクル。正の値はコンテナ単位の分離を犠牲にする |
| `--drain-wait-sec <n>` | `0` | `SIGTERM` 時に進行中ターンの完了を待つ秒数 |
| `--release-idle-session-min <n>` | `0` | アイドルなセッションのスロットを解放。**mid-turn・終わらないバックグラウンドタスク・ツール内からの承認待ちは idle と見なされない** |
| `--kill-session-after-min <n>` | `0` | セッションの wall-clock 上限。上の穴を塞ぐハードバックストップとして必ず併用する |
| `--startup-timeout-min <n>` | `15` | 子プロセスの init シグナルが来なければスロット解放 |
| `--confine-repo-settings <mode>` | `warn` | repo にコミットされた設定が workspace 外への書き込み許可・`env` ブロック・`sandbox.enabled: false` 等を要求していないかスキャン。`enforce` で拒否、`off` で無効 |
| `--trust-workspace` | on | repo コミット済みの `permissions.allow` / `additionalDirectories` を尊重するか |
| `--lock-to-account <id>` | unset | 起動時点で特定アカウントに固定(email か `user_...`) |
| `--health-port <port>` | `8080` | `/healthz` と `/metrics`。`0` で無効 |
| `--retire-at <epoch-seconds>` | unset | 既知時刻のホスト破棄に備える |
| `--push-outcome-on-release` | off | runner 起因の終了時に outcome ブランチを best-effort で push |

> ⚠️ 落とし穴: **フラグは分/秒、対応する環境変数は必ずミリ秒**(`_MS` サフィックス)。`--exit-if-unused-min 10` ≡ `SELF_HOSTED_RUNNER_IDLE_SHUTDOWN_MS=600000` であり、Helm 値に `SELF_HOSTED_RUNNER_STARTUP_TIMEOUT_MS: "15"` と書くと 15分ではなく **15ミリ秒**になる。上限超過時の挙動も非対称で、フラグは起動エラー、環境変数はタイマー上限へ黙ってクランプされる。

### base-dir と capacity は環境内で揃える
runner が死ぬとセッションは requeue され、別 runner が拾う。その runner は checkout パスを**自分の** `--base-dir` と `--capacity` から導出する(`--capacity 1` は base-dir 直下、2以上はセッションごとの worktree)。値がバラバラだと再開後に作業ディレクトリが変わり、エージェントが記録した絶対パスが存在しない場所を指す。インスタンス ID やホスト名を混ぜた per-host な値も同じ理由で不可。base-dir は runner 実行ユーザーが書ける必要があり、**起動時にはチェックされない**ため、不備は「pickup 直後にセッションが失敗する」形(`EACCES`)で現れる。

### git の設定 — 3つの選択肢
runner は checkout を管理するが git の identity とクレデンシャルは既定で設定しない。identity がないと `git commit` が `Please tell me who you are` で失敗し、セッションが進めなくなる。

| 方式 | 内容 | 注意 |
|---|---|---|
| `--configure-git` | Anthropic ホストと同じ `user.name = Claude` / `user.email = noreply@anthropic.com` と、Anthropic の署名サービス経由の SSH 形式コミット署名を起動時に書く | git **2.34+** 必須(古いと起動時にエラー終了)。push クレデンシャルは設定しない |
| イメージに同梱 | `git config --system` で identity(必要なら `safe.directory '*'`)を焼き込む | **広いスコープの push クレデンシャルを共有イメージに入れてはいけない**。組織全員の全セッションから読める |
| `--use-anthropic-git-proxy` | Anthropic の git proxy 経由で clone。ユーザーセッションは作成者の GitHub OAuth トークン、bot/agent セッションは組織の GitHub App installation トークンを使う。**イメージに git クレデンシャルが一切不要**になる | `--capacity 1` と git **2.32+** が必須(満たさないと起動拒否)。git ホストが Anthropic 側から到達可能である必要があり、社内限定のホストには使えない(その場合は `checkout` hook)。有効時は URL 書き換えフラグは無効 |

社内 DNS 事情には `--git-host-rewrite <from>=<to>`(split-horizon DNS)と `--git-ssh-rewrite <host>`(SSH 専用ホスト)があり、ホスト書き換えが先に走る。

### runner イメージ
Anthropic は pre-built イメージを配布しない。`claude` バイナリを中心に、リポジトリが必要とする言語ランタイム・コンパイラ・パッケージマネージャ・MCP サイドカーを重ねて自分でビルドする。公式の最小 Dockerfile は debian-slim に `git curl ca-certificates openssh-client` を入れ、リリース URL から `claude` を取得し、`git config --system` で identity と `safe.directory '*'` を設定して `ENTRYPOINT ["claude"]` とするもの。ARM や musl 向けはダウンロード URL のプラットフォーム部分を差し替える。バイナリは署名済みマニフェストで検証できる。

**バージョンは固定できる**: 各セッションの子プロセスは runner 自身のバイナリで動き、runner はセッション内の auto-update を無効化する。したがってイメージに焼いたバージョンが fleet 全体で動く。plugin マーケットプレイスも auto-update しないので、バイナリを固定したまま plugin だけ更新したい場合は `FORCE_AUTOUPDATE_PLUGINS=1`。

### デプロイ: Kubernetes / Compose と shutdown timing
runner は既定で `GET /healthz` を 8080 で出すので、liveness/readiness probe はそのまま使える。ただし**このエンドポイントはプロセスが生きていれば 200 を返す**ので、検出できるのは「死んだプロセス」だけ。「ポーリングが止まった runner」を捕まえるには `/metrics` の `last_poll_age_seconds` にアラートを張る。

shutdown で最も事故りやすいのが**猶予時間**:
- `SIGTERM` で runner は新規受付を止め、`--drain-wait-sec` まで進行中ターンを待ち、子を停止し、`post-session` hook を走らせる。
- 必要な合計は `--session-stop-grace-sec` + `--drain-wait-sec` + `--post-session-hook-timeout-sec` + 固定15秒(+ `--push-outcome-on-release` 時は30秒)。**既定で80秒**で、runner は起動時にこの合計をログに出す。セッションは並列にドレインするので `--capacity` を上げても合計は増えない。
- **Kubernetes の既定 `terminationGracePeriodSeconds: 30` はこれより短く、post-session hook の途中で pod を殺す**。公式レシピは 90 秒(Compose は `stop_grace_period: 90s`)。
- ドレイン中も runner は capacity 0 でハートビートを打ち続け、hook が書き出している最中に lease が切れて requeue されるのを防ぐ。

### pre-warm した checkout の再利用
大きなリポジトリでは clone がセッション起動時間を支配する。`--capacity 1` かつ `checkout` hook なしのとき、runner は `<base-dir>/<owner>/<repo>` に**リポジトリごとの正典 clone を1つ保持して再利用**する(fetch → detach → hard reset)。イメージにその位置の clone を焼いておけば、ディスクを再利用せずに毎回ウォームな状態から始められる。

保証されること/されないこと:
- clone の形は問わない(full/shallow/single-branch をそのまま使う。既存 clone への fetch に `--depth` は付かない)。`CLAUDE_RUNNER_FETCH_DEPTH`(既定 50)が効くのは**新規 clone のときだけ**。
- **tracked な変更は hard reset で消えるが、`git clean` は走らないので untracked ファイルは残る**(同一ロックアカウントの前セッションの残骸が見える)。
- git proxy 併用時は reset ではなく毎回フルの working-tree checkout になり、submodule の pre-warm は非対応。
- 長い clone に回避策は不要(120秒の無進捗ウォッチドッグ + 30分のハードキャップで、進捗が出ている限り完走する)。

### 監視 — メトリクスの読み方
`/metrics` に Prometheus 形式で出る。runner 側の主役は `..._last_poll_age_seconds`(60秒超でアラート)、`..._poll_errors_total{error_kind}`、`..._active_sessions` / `..._capacity`、`..._session_init_duration_seconds`、`..._session_init_errors_total`、`..._locked_account{email}`。最後のものは**アカウントの email がラベル値に入る**ので、メトリクスストアが広く読まれる環境では scrape 時に落とすかハッシュ化する。

orchestrator を使う場合は `..._orchestrator_pool_pending_sessions`(環境全体のキュー深さ。全インスタンスで同値なので `SUM` ではなく `MAX`)、`..._orchestrator_connected`、`..._orchestrator_queue_circuit_broken_sessions`(0超でアラート)。オートスケールでは `connected == 1` でゲートしないと、切断されたレプリカの古い値がスケーラに流れる。**全レプリカが切断した全断時、gated query は空を返す。HPA は現状維持だが KEDA は既定 `ignoreNullValues: "true"` でゼロと解釈してスケールインする**ため `"false"` を設定する。

> ⚠️ 落とし穴: **one-shot 環境(`--capacity 1` + `--drain-grace-sec 0`)では終端カウンタが観測できない**。`sessions_completed_total` / `_failed_total` / `_interrupted_total` はセッション終了の直前にしか増えず、その直後に runner が消えるので 15〜60 秒間隔の scrape はまず取りこぼす。スループットは orchestrator の `spawn_hooks_total{result="ok"}`、稼働率は `active_sessions` / `capacity`、バックログは `pool_pending_sessions` を使う。
>
> ⚠️ 矛盾に見えるが仕様: 同じイベントでも **`post-session` hook の `CLAUDE_RUNNER_EXIT_REASON` とメトリクスの分類が食い違う**。idle release・startup timeout・server deassign は hook からは `interrupted`、カウンタ上は `completed`。hook の受領数と `sessions_completed_total` を突き合わせると completion を過小評価する。hook は per-session 保証、カウンタは集計レート、と用途を分ける。

### 本番ハードニング
ドキュメントの必須チェックリスト(→ 背景は [[self-hosted-environment]] の脅威モデル):
- **セッションごとの使い捨てコンテナ**: `--capacity 1` + `--drain-grace-sec 0` で1コンテナ1セッション、プロセス終了でコンテナごと破棄。pre-warm 目的を除きファイルシステムを再利用しない(アカウントを跨いだ再利用は絶対に不可)。
- **イメージに広いクレデンシャルを入れない**: push トークン等はセッション単位で wrapper script から発行する。wrapper より前に走る初回 clone は `checkout` hook か git proxy で賄う。
- **environment secret をセッション実行ホストに置かない**: 固定 fleet では全 runner ホストに secret ファイルがあり、**セッションのコードから読める**。可能なら on-demand runner にして secret を orchestrator ホスト(ユーザーコードを実行しない)だけに置く。固定 fleet を採るなら「全セッションから読めるもの」として扱い、侵害の疑いがあればローテーションする。
- **default-deny egress**: 製品側で検証も強制もできないので、自社の境界で全環境に適用する。
- **ホスト IAM は最小権限**、かつ**クラウドメタデータエンドポイントをセッションからブロック**する。サブネットレベルの egress ポリシーは link-local(`169.254.169.254`)を捕まえないので、コンテナのネットワーク名前空間内で塞ぐ(IMDSv2 hop limit 1、GKE metadata concealment、明示的 deny)。wrapper script と lifecycle hook も同じコンテナを共有するので同様にブロックされる点に注意。
- **runner ごとのファイルシステム分離**と、`--hooks-dir`・wrapper・ホストの `~/.claude/` をセッションから read-only にすること。
- **repo 設定ガードを enforce に**する検討(`--confine-repo-settings`)。ただしガードは repository hooks・`.mcp.json`・Bash ルールまではカバーしない。

### トラブルシュート
`claude self-hosted-runner doctor` が runner のログと状態に read-only アクセスできる対話セッションを立ち上げる(唯一の変更操作は詰まったセッションの requeue)。ホストで `claude auth login` 済みなら環境・runner・キューを問い合わせられる。ログのローカル tail には `--log-file` が必要。

| 症状 | 主な原因 |
|---|---|
| runner が環境に現れない | `api.anthropic.com` 到達性、secret の失効、**ホスト時刻が5分以上ずれている**。認証失敗時は `[runner:fatal]` に理由が出る |
| セッションが queued のまま | オンラインの runner が**全て別アカウントにロックされている**可能性。`locked_account` メトリクスか `Picked up session` ログで確認し、レプリカを増やす |
| pickup 直後に失敗 | イメージの git クレデンシャル不足、ビルドツール不足、base-dir が書けない(`EACCES`) |
| 起動に数分かかる | 初回 clone が支配的。`session_init_duration_seconds` で確認し、pre-warm か浅い `CLAUDE_RUNNER_FETCH_DEPTH` で削る |
| ドレイン中に pod が殺される | `terminationGracePeriodSeconds` が runner のログに出る合計より短い |

runner のライフサイクルログは stdout、デバッグ出力は stderr で、いずれも JSON ではないプレーンテキスト。

### イメージの検証(CI スモークテスト)
新しい runner イメージを本番環境へ昇格させる前に、テスト環境に対してセッションを1本通す。読み戻しは Claude Code の **Stop hook** を使い、ターン最終応答(`last_assistant_message`)を `$E2E_REPLY_DIR/<session_id>.txt` に追記させる。Anthropic API を叩くのは2回の dispatch だけで済む。

1. `claude -p "<prompt>" --environment <ccpool_...> --ref <branch> --output-format json` でセッション作成(git checkout 内から実行すると `origin` からリポジトリを自動判別)。応答を待たず `session_id` を返して終了する。
2. Stop hook が書いたファイルに sentinel が現れるのを待つ。
3. `claude -p "<message>" --cloud <session_id> --output-format json` でフォローアップ。
4. 同様に待つ。

注意点:
- **hook は runner 起動前に設置する**(runner は `~/.claude/` を起動時に1度スナップショットする)。`E2E_REPLY_DIR` は runner プロセスの環境に export する。この capture hook は本番イメージに持ち込まない。
- テスト runner が別インフラにある場合は、ファイル書き込みの代わりに driver のエンドポイントへ POST する変種を使う。
- **認証は claude.ai の OAuth のみで API キーは不可**。`user:sessions:claude_code` スコープはサーバ側で30日上限のため `claude setup-token` の1年トークンでは代替できず、environment secret も(runner 登録用であってセッション作成用ではないので)使えない。長命 CI ホストなら30日ごとに `claude auth login` を再実行、エフェメラルなら `CLAUDE_CODE_OAUTH_REFRESH_TOKEN` / `CLAUDE_CODE_OAUTH_SCOPES` を渡す。**人間アカウントに紐づかない machine identity の経路は現時点で存在しない**。
- 環境自体も API(`POST/DELETE /v1/code/runners/self-hosted/pools`、`anthropic-beta: ccr-byoc-2025-07-29`)で作成・削除できるので、CI 実行ごとにクリーンな環境を切れる。レスポンスの `pool_secret` は runner を登録できる長命クレデンシャルなのでマスク必須。

## 出典
- `raw/articles/claude-code-self-hosted-environments-quickstart.md`(Claude Code 公式ドキュメント)— 前提条件、ガイド付き/手動セットアップ、secret のローテーション手順。
- `raw/articles/claude-code-self-hosted-environments-deploy.md`(同)— ハードニング、git 設定3方式、イメージ構築、Kubernetes/Compose レシピ、shutdown timing、pre-warm checkout、バージョン固定、既知の問題、トラブルシュート。
- `raw/articles/claude-code-self-hosted-environments-reference.md`(同)— CLI フラグ表、環境変数のミリ秒規約と上限、`/healthz`、Prometheus メトリクスとセッションカウンタの意味論。
- `raw/articles/claude-code-self-hosted-environments-testing.md`(同)— Stop hook による読み戻し、CI スモークテストのスクリプト、CI 認証の制約、テスト環境の API 作成/削除。

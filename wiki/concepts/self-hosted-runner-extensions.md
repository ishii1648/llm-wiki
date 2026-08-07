---
title: Self-hosted runner の拡張点(wrapper / lifecycle hooks / orchestrator)
type: concept
aliases: [self-hosted runner extensions, wrapper script, lifecycle hooks, spawn-runner, on-demand runners, orchestrator]
tags: [claude-code, self-hosted, runner, hooks, credentials, mcp, permissions]
created: 2026-08-07
updated: 2026-08-07
sources:
  - raw/articles/claude-code-self-hosted-environments-configuration.md
related:
  - "[[self-hosted-runner]]"
  - "[[self-hosted-environment]]"
  - "[[session-identity-token]]"
---

## 概要
[[self-hosted-runner]] は既定では「clone → Claude Code を spawn → 片付け」しかしない。その既定が合わないとき用に4系統の拡張点がある: セッションごとの前処理を差し込む **wrapper script**、パイプラインの各段を置き換える **lifecycle hooks**、固定 fleet の代わりにセッション単位で runner を起動する **on-demand orchestrator**、そしてセッションに配る MCP サーバと権限の設定。いずれも runner ホスト(Linux/macOS)上の実行可能ファイルとして動く。

> 命名の揺れ: フラグと環境変数は `environment` 系(`--environment-secret-file`)だが、hook の環境変数には `CLAUDE_RUNNER_POOL_ID` のように `pool` が残っている。

## 詳細

### wrapper script(`--exec-path`)
runner が Claude Code バイナリの代わりに起動するスクリプト。**セッションごとに1回**呼ばれる。用途は、セッション作成者にスコープした短命クレデンシャルの発行、環境固有シークレットの export、言語ツールチェーンの準備、子プロセスへのリソース制限。

**必ず `exec "$CLAUDE_RUNNER_CLAUDE_BIN" "$@"` で終わること**。シグナルと終了コードが正しく伝播し、環境も丸ごと引き継がれる。

runner が wrapper に渡す主な変数:

| 変数 | 中身 |
|---|---|
| `CLAUDE_CODE_SESSION_ACCESS_TOKEN` | セッション JWT(`sk-ant-cc-` prefix)。`act` クレームに作成者。→ [[session-identity-token]] |
| `CCR_SESSION_ACCOUNT_EMAIL` | 作成者 email を**署名検証せずに**runner が抽出したもの。commit trailer 等のラベル用途限定。PII として扱う |
| `CLAUDE_RUNNER_CLAUDE_BIN` | runner 自身のバイナリの絶対パス。インストール先をハードコードせず exec する |
| `CLAUDE_CODE_REMOTE_SESSION_ID` / `_UUID` | `cse_...` 形式のセッション ID と UUID 形式 |
| `CLAUDE_SESSION_INGRESS_TOKEN_FILE` | 常に最新の JWT を持つファイル。添付ファイルのダウンロードに使う。環境を作り直す wrapper は引き継がないと**添付が黙って壊れる** |
| `CLAUDE_CONFIG_DIR` | セッション専用の config ディレクトリ |
| `ANTHROPIC_BASE_URL` | 制御プレーンが配る API base URL。**上書きしない**(推論クレデンシャルは他プロバイダが受け付けない) |
| `CLAUDE_CODE_OAUTH_TOKEN` | 推論とファイルアップロード専用の短命 OAuth トークン(約30分)。漏れれば30分間使える bearer 資格として扱い、ログにもディスクにも出さない |

> ⚠️ 最大の落とし穴: **子の stdin と file descriptor 3 を切ってはいけない**。stdin は runner の制御チャネルで、トークンのローテーションとセッション終了シグナルが流れる。fd 3 は idle/startup タイムアウトを駆動する活動シグナル用のパイプ。素の `exec` なら両方保たれるが、`&` でバックグラウンド化すると stdin が切れ、**初回 OAuth トークンの寿命(約30分)まで正常に見えたあと、全 API 呼び出しが `401 authentication_error` になる**。どうしても background するなら `exec 4<&0` で退避して `<&4` で明示的に繋ぎ直す。

作成者に紐づくクレデンシャル発行は `self-hosted-runner decode-token` サブコマンドで JWT のクレームを読む。認可判断に使うクレームの抽出では `jq -r` ではなく **`jq -re`** を使い、クレーム欠落時に `null` という文字列が下流へ流れるのではなく非ゼロ終了させる。bot/agent セッションは `act.sub` が `user:` ではなく `agent:` になるため、拒否するのかデフォルトクレデンシャルへフォールバックするのかを**明示的に決める**必要がある。

### lifecycle hooks(`--hooks-dir`)
指定ディレクトリ内の**決められた名前の実行可能ファイル**が、runner の per-session パイプラインの各段を置き換える。存在しない hook は組み込み動作にフォールバックするので、必要なものだけ書けばよい。hook は runner の権限で動き、セッションの子プロセスも同じ UID を共有するので、**hooks ディレクトリは read-only でマウントするかイメージに焼く**。

セッションの**内側**で動く Claude Code hooks(`PreToolUse` / `Stop` 等)とは別物で、こちらは**セッションの外側・runner 上**で動く。

| hook | タイミング | 使いどころ |
|---|---|---|
| `checkout` | リポジトリごとに1回、組み込みの clone/fetch の代わり | read-through ミラーからの clone、アーカイブからの working tree 展開、セッション単位の git 認証。`CLAUDE_RUNNER_CHECKOUT_PATH` に指定 revision の working tree を残す。runner は後で `.git` の存在を検証するので、Perforce や tarball など非 git を展開する場合は `CLAUDE_RUNNER_SKIP_GIT_VERIFY=1`。**非ゼロ終了はセッションを失敗させ、stderr の末尾がユーザーに見える** |
| `post-session` | 子プロセス終了後、workspace 破棄前 | **未コミットの作業を救う唯一の機会**。`--capacity` 2以上では hook 直後に worktree が消え、`--capacity 1` でも次セッション開始時に hard reset される。rescue ブランチへの push、ログのアーカイブ、自社システムへのイベント送出。終了ステータスはセッションの結果に影響しない(失敗はログのみ)。既定60秒 |
| `command` | checkout 後、組み込みの子 spawn の代わり | wrapper script と同じ環境を受け取る。カスタマイズを hooks ディレクトリに集約したいとき。`--exec-path` が併設されていればフラグが勝ち、この hook は無視される |

`checkout` hook には**git クレデンシャルが渡されない**。セッションの JWT を JWKS で検証し、`act` クレームの identity 向けに短命の clone クレデンシャルを自社サービスから発行する設計が想定されている(この環境では `CLAUDE_RUNNER_CLAUDE_BIN` が未設定なので `decode-token` は使えず、標準的な JWT ライブラリで検証する)。

`post-session` の `CLAUDE_RUNNER_EXIT_REASON` は `completed` / `failed` / `interrupted` / `abandoned`(現状 fire しない)。VM の preemption や電源断のような**唐突な停止では hook は動かない**ので、それに対する保証が要るならセッション内の `PostToolUse` hook で定期スナップショットを取る。

公式のサンプル `post-session` は、**セッションが `.git/config` に仕込みうる設定を `-c` で無効化してから** git を叩く(`core.fsmonitor` / `core.hooksPath` / `commit.gpgsign`)。repo ローカルの `credential.helper`・`core.sshCommand`・`pushurl` は依然効くので、**hook がセッションの持たないクレデンシャルを握っている場合は push 先 URL と helper も固定する**。

### on-demand runners(orchestrator + `spawn-runner`)
固定 fleet の代わりに、セッションごとに runner を1つ起動する方式。`claude self-hosted-runner orchestrator` はステートレスな別サブコマンドで、「runner が居ないまま queued になったセッション」の spawn 要求をポーリングし、`spawn-runner` hook を呼ぶ。hook は Kubernetes Job・EC2 インスタンス・Nomad dispatch など**自社プラットフォームへ非同期に投入するだけ**で、runner の起動完了を待ってはいけない(既定60秒の `--hook-timeout` 内に返す)。

**セキュリティ上の主目的はクレデンシャル衛生**: 固定 fleet では environment secret がユーザーコードを実行するホスト全部に置かれる。orchestrator 方式なら secret はユーザーコードを実行しない orchestrator ホストだけに残り、各 runner は**1回限りの work order**(runner を1つだけ登録して失効する署名付き JWT)を受け取る。

hook の契約4条:
1. **`CLAUDE_RUNNER_ORDER_ID` で冪等に**。同じ要求が再配送されても runner は高々1つ。ID からリソース名を決定的に導出してプラットフォーム側に重複を弾かせる。
2. **ワークロードをリトライしない**。登録されなければ Anthropic が `--expected-spawn-seconds` 経過後に新しい order ID で再要求する。
3. **終了コード契約**: 0 = 投入済み、1 = リトライ可(backoff して再オファー)、2以上 = リトライ不可で、**Owner/admin が環境の Activity タブで Retry を押すまでそのセッションはブロックされる**。非ゼロ時は stderr の末尾が失敗理由として表示されるので、実行可能なエラーだけを書き、シークレットは絶対に書かない。
4. **`--expected-spawn-seconds` は p99 起動時間以上に**。これはサーバ側の lease で、全レプリカで同じ値にする。

spawn された runner は environment secret の代わりに work order JWT で登録する(`--environment-secret-file` にそのファイルを指すか `SELF_HOSTED_RUNNER_ENVIRONMENT_SECRET` に値を渡す)。**work order ファイルは hook 終了後に削除される**ので、パスを渡すのではなく JWT を投入するワークロード(Kubernetes Secret など)へコピーする。セッションに紐づく work order は runner 1つを束縛するので `--capacity 1` にする。`--min-idle` による事前ウォーミングの work order だけはセッション非束縛で、固定 fleet の runner と同様にキューから拾う。

orchestrator はステートレスなので可用性のため複数レプリカを立てられる(各 spawn 要求はサーバ側でちょうど1レプリカに claim される)。GitHub Enterprise Server が社内からしか到達できない場合は、orchestrator の **SCM connector**(`--scm-connector-host`)が唯一の WebSocket トンネルとして、リポジトリピッカーや ref 解決といったホスト側の事前フローを内側へ中継する。

### MCP サーバをセッションに配る
イメージビルド時に `claude mcp add --scope user ...` を実行しておく(**`--scope user` が必須**。既定の local scope はディレクトリ単位のキーに書かれ、runner がセッションへ配らない)。bare プロセス運用なら runner のユーザーで同じコマンドを実行してから runner を再起動する。

runner は**起動時に1度だけ**ホストの設定をスナップショットする。捕まえるのは `~/.claude/` の隣にある `.claude.json` の `mcpServers` キーだけで、アカウント状態やプロジェクト履歴は落とされる。`type` が認識できないエントリは起動時に警告を出して落とすので、黙って失敗する代わりに気づける。`SELF_HOSTED_RUNNER_HOST_CONFIG_DIR` を空ディレクトリに向ければ seeding 自体を無効化できる。

他の経路は enterprise scope の managed MCP ファイル(Linux は `/etc/claude-code/managed-mcp.json`、macOS は `/Library/Application Support/ClaudeCode/managed-mcp.json`。管理者が列挙したサーバだけを読み込ませたい fleet 向け)と、リポジトリにコミットする `<repo>/.mcp.json`(cloud session では自動承認される)。`settings.json` / `managed-settings.json` に MCP サーバ定義は**書けない**(スキーマに `mcpServers` トップレベルフィールドが存在しない)。

なお claude.ai の connector は制御プレーンから配信され、**プログラムで作られたセッション(CLI dispatch 等)には配信されない**。その場合はホストスナップショット・managed MCP・`.mcp.json` のいずれかで渡す。connector のトラフィックが自社ネットワークを通らない件は [[self-hosted-environment]] の既知の制限を参照。

### セッションに push を促す Stop hook
Anthropic ホストのセッションには「作業を commit / push しろ」と促す `Stop` hook が入っているが、**runner はこれをインストールしない**。無いと、未コミットのまま終わったセッションの作業が runner のディスクにしか残らず、claude.ai/code の **Create PR** ボタンもブランチが無いので非活性のままになる。公式のリファレンス実装(runner ホストの `~/.claude/settings.json` + `~/.claude/hooks/stop-hook-nudge.sh`)は、未コミット変更または未 push コミットがあるときに1ターン1回だけ `{"decision":"block","reason":...}` を返して促す。実装上の注意として、`stop_hook_active` による再入ガード、`.claude/` の除外(オペレータが配った設定と CLI のランタイム状態が入るため)、ブランチ名を JSON に埋める際のエスケープ(ref 名に `"` を含められるため)が織り込まれている。

### 権限とツール承認
self-hosted セッションには端末が繋がっていないので、**未応答の権限プロンプトは UI でユーザーが答えるまでターンを止める**。制御プレーンがツール一覧と権限ルールをワークペイロードで送り、既定では `Bash` を含む定型ツールが pre-approve され、cloud session ではモードによらずファイル編集が pre-approve される。

- プロンプトを最小化したいなら wrapper / `command` hook から **auto mode** を固定する: `exec "$CLAUDE_RUNNER_CLAUDE_BIN" "$@" --permission-mode auto`。runner はサーバ計算のフラグを wrapper 呼び出し前に付けるが、単値フラグは**最後の出現が勝つ**ので `"$@"` の後ろに置けば上書きできる。auto mode は別の分類モデルが実行前にアクションを審査して拒否するもので、明示的な ask ルールは依然プロンプトを強制する。
- **auto mode を有効化してよいのは default-deny egress とハードニングが済んだ環境だけ**。既定 pre-approve でも auto mode でも `Bash` のネットワークアクセスは人間を挟まないので、境界はネットワーク側にしかない。
- 個別に絞るなら `--allowed-tools "Bash(bazel *) mcp__internal__*"` のようにする。**リスト型フラグは上書きではなく累積**し、`--disallowed-tools` は他のルールが許可していても拒否する。

**設定の組み立て順**: runner が起動時に取ったホスト `~/.claude/` のスナップショット(`settings.json`・`CLAUDE.md`・hooks・agents・commands・skills)が user レベルのベースライン → repo にコミットされた `.claude/settings.json` が project 設定として重なる → `managed-settings.json` は1ソースのみ有効で、**server-managed settings が配信されていればイメージ内の managed ファイルは無視される**(`env` ブロックだけはキー単位でマージ)。ホスト設定の変更は runner 再起動まで効かない。

repo にコミットする権限ルールでは、**裸の `"Edit"` / `"Write"` / `"NotebookEdit"` を `permissions.allow` に置かない**。パスを問わずマッチしてしまい、workspace ではなくホスト全体への書き込み許可になるため confine guard に引っかかる(`--confine-repo-settings enforce` ならセッションが起動しない)。そもそも cloud session はファイル編集を pre-approve するのでルール自体不要で、書くなら `"Edit(/**)"` のように workspace へスコープする。`defaultMode: auto` はイメージ/ユーザーレベルの設定ファイルからしか効かないので、**checkout されたリポジトリが自分に auto mode を与えることはできない**。

## 出典
- `raw/articles/claude-code-self-hosted-environments-configuration.md`(Claude Code 公式ドキュメント)— wrapper script の変数表と stdin/fd3 の制約、`decode-token` によるクレデンシャル発行、`checkout` / `post-session` / `command` hook、on-demand orchestrator と `spawn-runner` の契約、MCP サーバの配布経路、push を促す Stop hook のリファレンス実装、権限とツール承認および設定の組み立て順。

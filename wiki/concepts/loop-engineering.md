---
title: Loop Engineering
type: concept
aliases: [loop engineering, ループエンジニアリング, loop design, ループ設計]
tags: [agentic-development, coding-agents, automation, loop, claude-code, codex, addy-osmani]
created: 2026-06-10
updated: 2026-07-05
sources:
  - raw/articles/loop-engineering.md
  - raw/articles/claude-code-scheduled-tasks.md
  - raw/articles/claude-code-goal.md
  - raw/articles/claude-code-hooks-guide.md
  - raw/articles/claude-code-workflows.md
  - raw/articles/claude-code-tools-reference.md
  - raw/articles/claude-code-channels-reference.md
related:
  - "[[addy-osmani]]"
  - "[[agent-loop]]"
  - "[[agent-skills]]"
  - "[[mcp-tools]]"
  - "[[plugins]]"
  - "[[multi-agent-patterns]]"
  - "[[ai-code-review]]"
  - "[[agentic-engineering]]"
---

## 概要
**Loop engineering(ループエンジニアリング)** とは、「**エージェントに prompt する人間としての自分自身を置き換え、代わりにそれを行うシステムを設計する**」こと([[addy-osmani]] のブログ記事 "Loop Engineering", 2026-06-07)。ここでの loop は **recursive goal**(目的を定義し AI が完了まで反復する再帰的ゴール)と捉えられる。Peter Steinberger の「もはやコーディングエージェントに prompt すべきでない。エージェントに prompt する**ループを設計**せよ」、Boris Cherny(Anthropic の Claude Code 責任者)の「私はもう Claude に prompt しない。Claude に prompt し何をするか考えるループを走らせている。私の仕事はループを書くことだ」という発言を起点に、コーディングエージェントとの働き方の未来形として提示される。

> 著者自身は「まだ初期段階で懐疑的」とし、特に **token コスト**(トークンに富むか貧しいかで使い方が大きく変わる)に注意せよと釘を刺している。

## 詳細

### prompt engineering からの転換
過去2年ほど、コーディングエージェントから成果を得る方法は「良い prompt を書き十分な文脈を共有する」ことだった。入力 → 返答を読む → 次を入力、という具合に、人間がずっとツールを握り、1ターンずつ進める。Loop engineering はこれを置き換える: **仕事を見つけ、割り振り、検証し、完了を記録し、次を決める小さなシステム**を構築し、人間の代わりにそのシステムがエージェントを突く。

これは著者が以前書いた **agent harness engineering**(単一エージェントが動く環境づくり)や **factory model**(ソフトウェアを作るシステム)の一階上に位置づけられる ——「harness だが、タイマーで動き、小さなヘルパーを spawn し、自分自身に食わせる」もの。なお [[agent-loop]] が単一エージェント内の推論↔ツール実行サイクルなら、loop engineering はその外側で複数の実行を**スケジュール・分離・検証・記憶**する一段上の制御層にあたる(本 wiki による位置づけ)。

### もはやツールの問題ではない
1年前ならループは大量の bash を自前で書き永久に保守する必要があったが、今や**部品が製品内に同梱**されている。Steinberger の挙げる要素は Codex app にほぼそのまま、Claude Code にもほぼ同じ形で対応する。形が同じだと気づけば「どのツールか」の論争をやめ、どちらに座っていても通用するループを設計できる、というのが記事の通底するパターン。

### 5つの構成要素 + 記憶
ループには5つの要素と、状態を覚える1か所が要る。

1. **Automations** — スケジュールで発火し、発見(discovery)とトリアージ(triage)を自律実行する。
2. **Worktrees** — 2つのエージェントが並列作業で衝突しないよう分離する。
3. **Skills** — エージェントが推測で埋めてしまうプロジェクト知識を書き留める(→ [[agent-skills]])。
4. **Plugins / connectors** — 既存ツールにエージェントを接続する(→ [[mcp-tools]], [[plugins]])。
5. **Sub-agents** — 一方が着想し、別の一方が検証する。

そして6番目、**memory(記憶)**: 単一の会話の外に生き、「何が済み次は何か」を保持する markdown ファイルや Linear ボード。一見あまりに単純だが、これは長時間稼働エージェントが依存する同じトリックである(著者の "long-running agents" 参照)—— **モデルは run 間で全てを忘れるので、記憶は context ではなくディスクに置く**必要がある。「エージェントは忘れるが repo は忘れない」。

#### Codex app と Claude Code の対応(記事の核)
両製品に5要素がすべて揃っている。名前は違っても能力は同じ。

| Primitive | ループ内の役割 | Codex app | Claude Code |
|---|---|---|---|
| **Automations** | スケジュールでの発見+トリアージ | Automations タブ(project / prompt / cadence / environment を選択。結果は Triage inbox へ。run-until-done に `/goal`) | スケジュールタスク・cron、`/loop`、`/goal`、hooks、GitHub Actions |
| **Worktrees** | 並列機能の分離 | スレッドごとに組み込み worktree | `git worktree`、`--worktree`、サブエージェントへの `isolation: worktree` |
| **Skills** | プロジェクト知識の符号化 | Agent Skills(`SKILL.md`)。`$name` または暗黙で起動 | Agent Skills(`SKILL.md`)→ [[agent-skills]] |
| **Plugins / connectors** | 自分のツールへ接続 | Connectors(MCP)+ 配布用 plugins | MCP サーバ + plugins(→ [[mcp-tools]], [[plugins]]) |
| **Sub-agents** | 着想と検証 | `.codex/agents/` の TOML で定義する Subagents | `.claude/agents/` の Task サブエージェント、agent teams |
| **State** | 完了の追跡 | Markdown または connector 経由の Linear | Markdown(`AGENTS.md`、progress ファイル)または MCP 経由の Linear |

### 各要素の要点

#### Automations — ループの心臓(heartbeat)
1回きりの run でなく**実際のループ**にする要素。Codex では Automations タブで project / prompt / cadence / ローカル checkout か background worktree かを選ぶ。何か見つけた run は Triage inbox へ、何も見つけない run は自動アーカイブ。OpenAI 社内では日次の issue トリアージ・CI 失敗の要約・commit briefing・先週混入したバグ探しなどに使う。automation は skill を呼べるので、巨大な指示文を貼る代わりに `$skill-name` を撃てて保守可能。

Claude Code はスケジューリングと hooks で同じ場所に至る:`/loop` で prompt やコマンドを一定間隔で再実行、cron タスク、エージェントのライフサイクルの特定点で shell を撃つ hooks(→ [[plugins]] のライフサイクルイベントと同系統)、ノート PC を閉じても走り続けさせたいなら GitHub Actions。

セッション内のもう1つの primitive:
- **`/loop`** は一定の cadence で再実行する。
- **`/goal`** は自分で書いた条件が実際に真になるまで継続し、**毎ターン後に別の小さなモデルが完了判定**する —— コードを書いたエージェント自身が採点しない。「test/auth の全テストが通り lint がクリーン」のように与えて立ち去れる。Codex も同名の `/goal` を持ち、検証可能な停止条件が成立するまで継続(pause / resume / clear 付き)。

##### `/loop` の2モードと ScheduleWakeup(実装詳細)
`/loop` には固定間隔と動的間隔の2モードがある(`raw/articles/claude-code-scheduled-tasks.md`)。

- **固定間隔**: `/loop 5m <prompt>` のように cron 互換の間隔を明示。5分〜複数日まで指定可(秒指定は分に切り上げ)。
- **動的間隔**: `/loop <prompt>`(間隔省略)。各イテレーション終了後、**Claude 自身が `ScheduleWakeup` ツールで次の起床時刻を決める**。観測した状態(CI が pending か failure か等)に応じて 1分〜1時間の幅で適応的に待つ ——「何もなければ長く、動きがあれば短く」を LLM が判断する。Bedrock/GCP/Azure 経由では固定 10 分に降格する。
- セッション終了で自動停止し、`--resume` 時は 7日以内なら復帰する。`Esc` で次の起床をキャンセルできる。
- `/loop` 単独実行(prompt 省略)は PR 監視・CI 確認・cleanup を行う内蔵メンテナンスプロンプトが走る。`loop.md` でプロジェクト/ユーザー単位にデフォルト prompt をカスタマイズできる。

##### Cron / Routine(セッション非依存の無人実行)
Automations の「スケジュール」を担うもう1つの層が cron 系のツール群(`raw/articles/claude-code-scheduled-tasks.md`)。

| 種類 | 前提 | 特徴 |
|---|---|---|
| セッション内 cron(`CronCreate`/`CronList`/`CronDelete`) | セッション継続が必須 | 5フィールド cron 式、7日で自動満期 |
| Routine(ルーティン) | セッション不要 | クラウド側で無人実行。GitHub Actions 等の CI イベントもトリガーにできる |
| デスクトップスケジュール | ローカルマシン起動中 | マシンの起動時間に依存 |

セッション継続前提の `/loop`・`CronCreate` と、セッション非依存の Routine・GitHub Actions は使い分けが要る:ノート PC を閉じる/無人運用したいなら後者。

##### Hooks による決定論的 / 意味的な収束判定
Automations の「トリアージ」「停止条件」を hooks が担う(`raw/articles/claude-code-hooks-guide.md`)。特に **Stop hook** はループを「収束するまで続ける」核心機構になる。

- **Command hook**: シェルコマンドを実行し exit code で判定する決定論的な hook(例: テストランナーを直接叩く)。
- **Prompt hook**: 小さな LLM が yes/no + 理由を返す意味的な hook(例:「全テストが通ったか」を自然言語条件で判定)。
- Stop hook で「まだ完了していない」と判定すればターンを継続させる **loop-until-pass** パターンが組める(例: テストが通るまで/レビュー指摘がなくなるまで)。ただし無限ループ防止のため Stop hook は**8連続ブロックで上限**に達する(`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` で調整可)。
- PostToolUse(ツール実行直後に formatter を挟む等)、SessionStart(再開時にコンテキストを注入)、PreToolUse(危険なコマンドをブロック)も同じ hooks 機構の一部で、Automations の「発見・トリアージ」を決定論的に支える。

#### Worktrees — 並列をカオスにしない
複数エージェントを走らせた瞬間にファイル衝突が失敗要因になる。2エージェントが同一ファイルを書くのは、2人のエンジニアが相談せず同じ行に commit するのと同じ頭痛。**git worktree** はこれを解決する —— 同じ repo 履歴を共有しつつ独自ブランチの別作業ディレクトリなので、一方の編集が他方の checkout に触れ得ない。Codex は worktree を内蔵。Claude Code は `git worktree`・`--worktree` フラグ・サブエージェントの `isolation: worktree` 設定で同じ分離を提供(各ヘルパーが使い捨ての fresh checkout を得て後で自動掃除)。

> 著者の警告("the orchestration tax"):worktree は機械的衝突を取り除くが、**人間(YOU)が依然として天井**。並列数を決めるのはツールでなく**あなたのレビュー帯域(review bandwidth)**。

#### Skills — 毎回プロジェクトを説明し直さない
毎セッション同じ文脈を金魚のように再説明しないための仕組み。両ツールとも `SKILL.md`(指示+メタデータ)を含むフォルダ + 任意の scripts / references / assets という同じ形式。説明文に task がマッチすれば暗黙起動するため「気の利いた説明より退屈で的確な説明」が勝つ。詳細は [[agent-skills]](progressive disclosure)。
- skill は**意図(intent)を外部に書き出す**場所:規約・ビルド手順・「あの障害以来こうはしない」を毎 run 読まれる所に1度だけ書く。skill が無いとループは毎サイクルでプロジェクトをゼロから再導出するが、skill があると知識が compound する(著者の "intent debt" 参照)。
- **skill は authoring 形式、plugin は出荷形式**:repo を跨いで共有・束ねるときは plugin にパッケージする。Codex でも Claude Code でも同様。

#### Plugins / connectors — ループが実ツールに触れる
ファイルシステムしか見えないループは小さい。**MCP 上に構築された connectors** が issue tracker の読取・DB クエリ・staging API 叩き・Slack 投稿を可能にする。Codex と Claude Code は共に MCP を話すので、一方用の connector は他方でもほぼそのまま動く(→ [[model-context-protocol]], [[mcp-tools]])。plugins は connectors と skills を束ね、チームメイトが1発で同じ設定を入れられる。これが「修正案を言うだけのエージェント」と「PR を開き Linear チケットを紐づけ CI が緑になればチャンネルに通知するループ」の差。

#### Sub-agents — 作る者と検証する者を分ける
ループで最も有用な構造は、**書く者(maker)と検証する者(checker)の分離**。コードを書いたモデルは自分の宿題を甘く採点しすぎる。別の指示(時に別モデル)を持つ第2のエージェントが、第1のエージェントが言いくるめた点を捕まえる。
- Codex は依頼時のみサブエージェントを spawn・並列実行し結果を1つに畳む。`.codex/agents/` の TOML で name / description / instructions / 任意の model・reasoning effort を定義(security reviewer は強モデル高 effort、explorer は高速 read-only など)。
- Claude Code も `.claude/agents/` のサブエージェントと、仕事を受け渡す agent teams で同様。両者の典型は「1つが探索、1つが実装、1つが spec に対し検証」。

これは [[multi-agent-patterns]] の役割分担(および [[ai-code-review]] の "adversarial code review")とも重なる。ループは**見ていない間に走る**ので、信頼できる verifier こそが立ち去れる唯一の理由。サブエージェントは各自モデル・ツールを使い token を多く焼くので「第2の意見が払う価値のある所」に使う。**Claude Code の `/goal` は内部的にこれ**を行っている —— 仕事をしたモデルでなく fresh なモデルが完了判定する = maker/checker 分離を停止条件そのものに適用したもの。

##### Workflow ツール(決定論的なサブエージェント・オーケストレーション)
Claude Code の maker/checker 分離をスクリプトとして固定化したのが Workflow ツール(`raw/articles/claude-code-workflows.md`)。JavaScript(型注釈なしの plain JS)でサブエージェントの fan-out/検証を記述する:

- `agent()` で単体サブエージェント実行、`pipeline(items, stage1, stage2, ...)` でアイテムごとに複数ステージを**バリアなしで**流す(遅いアイテムが速いアイテムの足を引っ張らない)、`parallel(thunks)` は全結果を待つバリア。
- 典型パターンは **adversarial verify**(複数の独立した skeptic エージェントに「反証してみよ」とプロンプトし、過半数が反証したら棄却)と **loop-until-dry**(新しい指摘が出なくなるまで発見ラウンドを繰り返す)。これはまさに Osmani の言う「maker と checker の分離」をコードとして表現したもの。
- 並列実行数は最大16、1ワークフロー内の総サブエージェント数は1000が上限。中断・再編集後の再開(resume)も可能で、変更していない呼び出し結果はキャッシュされる。
- 明示的なユーザーの opt-in(「ultracode」キーワードや `/code-review ultra` 等)が必要 —— サブエージェントを大量に spawn しトークンを消費するため、常時自動発火はしない設計。ここも「orchestration tax」(→ Worktrees の節)と同じ発想で、コストに見合う場面に絞る。

#### 補助プリミティブ — Monitor / Channels / Task 管理 / バックグラウンド実行
Osmani の5要素には含まれないが、Claude Code でループを組む際に実際よく使う実装ディテール(`raw/articles/claude-code-tools-reference.md`)。

- **Monitor ツール**: シェルコマンドや WebSocket の出力を継続的に監視し、変化があった行だけを通知として受け取る。CI ログを poll し続けるより token 効率がよく、待っている間も他の作業を並行して進められる。`persistent: true` で無期限監視も可能。ポーリングループを自前の bash + sleep で書く代わりに使う。**Claude がセッションから外を見に行く(pull)** 側の primitive。
- **Task 系ツール(`TaskCreate`/`TaskList`/`TaskUpdate`/`TaskStop`)**: 長時間実行タスクの作成・進捗追跡・停止。Monitor やバックグラウンド実行の管理・可視化に使う ——「State(完了の追跡)」の実装がセッション内タスクの粒度まで降りてきたもの。
- **バックグラウンド実行(`Bash` の `run_in_background`)**: 長時間コマンドをセッションをブロックせず裏で実行し、Monitor で状態を監視するか完了後に読み出す。ループの「1ステップ」が長時間ジョブのときの基本形。

##### Channels(Monitor の逆方向:push型のイベント連携)
Monitor が pull(Claude が能動的に見に行く)なのに対し、**Channels**(research preview、v2.1.80+)は **push**(外部システムが Claude Code セッションへイベントを送り込む)側の primitive(`raw/articles/claude-code-channels-reference.md`)。

- 実体は「セッションと同じマシン上で動き stdio で通信する MCP サーバー」。外部からの webhook・chat メッセージ・監視アラートを、Claude への通知として push する。
- **one-way channel**: CI/監視アラートの webhook を受けて Claude に知らせるだけ。**two-way channel**(chat bridge 等): 返信ツールを公開し Claude からもメッセージを送れる。
- 信頼できる sender 経路を持つ channel は、ツール承認プロンプトをリモートへ中継(relay)する opt-in もできる ——「離れた場所から permission プロンプトを承認/拒否する」動線。
- 公式 research preview では Telegram / Discord / iMessage / fakechat が同梱。Team/Enterprise 組織は明示的な有効化が必要。
- plugin から配布する場合は Monitor 同様に MCP サーバーとして同梱できる(`monitors/monitors.json` で Monitor 自体を自動起動宣言する仕組みとは別の、channel 用の宣言経路がある)。
- 位置づけ: Monitor がループの「観測」を内側から行う primitive なら、Channels は「外の出来事がループに飛び込んでくる」入口。Automations(スケジュールで能動的に見に行く)・Monitor(能動的に張り付いて見る)・Channels(受動的に通知を受ける)の3つで「発見(discovery)」の手段が揃う。

### 1つのループの実例(著者が反復利用する形)
- 毎朝 repo 上で automation が走る。その prompt は triage skill を呼び、昨日の CI 失敗・open issues・最近の commits を読み、findings を markdown ファイルか Linear ボードに書く。
- やる価値のある finding ごとに、スレッドが分離された worktree を開き、サブエージェントに修正案を起草させ、第2のサブエージェントがその草案を project skills と既存テストに照らしてレビューする。
- connectors がループに PR を開かせチケットを更新させる。ループが扱えないものは triage inbox に届く。**state ファイルが背骨**で、何を試し・何が通り・何が未解決かを覚えているので、翌朝の run は今日止まった所から再開する。

「あなたが実際にしたのは**一度の設計だけ**で、どのステップも prompt していない」—— これが Steinberger の主張の具現であり、部品が同じなので Codex でも Claude Code でも同じループになる。

### ループが肩代わりしないこと(警告)
ループは仕事を変えるが、人間を消さない。むしろループが良くなるほど鋭くなる3つの問題:
1. **検証(verification)は依然あなたの責任**。無人で走るループは無人でミスを犯すループでもある。verifier サブエージェントを maker から分けるのは「done」に意味を持たせるためだが、それでも「done」は主張であって証明ではない。"your job is to ship code you confirmed works"(→ [[ai-code-review]] の検証責任論と同根)。
2. **理解は放置すれば腐る**。書いていないコードを速く出荷するほど、存在するものと自分が把握しているものの差が広がる —— これが **comprehension debt**(理解負債)で、滑らかなループはループが作ったものを読まない限りこれを速く膨らませる。
3. **快適な姿勢が最も危険**。ループが自走すると意見を持つのをやめ返ってきたものをそのまま受け取りたくなる —— 著者はこれを **cognitive surrender**(認知の明け渡し)と呼ぶ。ループ設計は判断を伴えば治療薬、思考回避のためなら促進剤になる(同じ行為で逆の結果)。

### 結論:Build the loop. Stay the engineer.
著者は仕事の進化のプレビューと見るが、「自分でコードをレビューせず自動ループだけに修正を頼れば製品の質は劣化し、下降スパイラルで穴を深く掘り続ける」とする。ループを組むのもよいが、エージェントに直接 prompt するのも有効で、**バランスが肝**。同じループでも使う人で結果は正反対になる ——「理解の深い仕事を速める人」と「仕事の理解を避ける人」をループは区別しないが、あなたは区別できる。これが loop design を prompt engineering より**易しくなく、むしろ難しく**する理由。Cherny の論点は「仕事が楽になった」ではなく「**leverage point(梃子の支点)が動いた**」。

> "Build the loop. But build it like someone who intends to stay the engineer, not just the person who presses go."

## 出典
- `raw/articles/loop-engineering.md`(Addy Osmani, "Loop Engineering", 2026-06-07)— loop engineering の定義、prompt engineering からの転換、5要素+memory、Codex/Claude Code 対応表、各要素(Automations/Worktrees/Skills/Plugins・connectors/Sub-agents)の詳細、`/loop`・`/goal`、ループの実例、3つの警告(検証・comprehension debt・cognitive surrender)、結論のすべて。
- `raw/articles/claude-code-scheduled-tasks.md`(Claude Code 公式ドキュメント)— `/loop` の固定/動的間隔、ScheduleWakeup による自己スケジューリング、セッション内 cron・Routine・デスクトップスケジュールの違い。
- `raw/articles/claude-code-goal.md`(同上)— `/goal` の停止条件判定の仕組み。
- `raw/articles/claude-code-hooks-guide.md`(同上)— Command hook / Prompt hook の区別、Stop hook による loop-until-pass パターンとブロック上限。
- `raw/articles/claude-code-workflows.md`(同上)— Workflow ツール(`agent`/`pipeline`/`parallel`)、adversarial verify・loop-until-dry パターン、並列数・総数上限。
- `raw/articles/claude-code-tools-reference.md`(同上)— Monitor ツール、Task 系ツール、バックグラウンド実行(`run_in_background`)。
- `raw/articles/claude-code-channels-reference.md`(同上)— Channels(push型イベント連携の MCP サーバー契約)、one-way/two-way channel、sender gating、permission relay。

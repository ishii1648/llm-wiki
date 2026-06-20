---
title: Loop Engineering
type: concept
aliases: [loop engineering, ループエンジニアリング, loop design, ループ設計]
tags: [agentic-development, coding-agents, automation, loop, claude-code, codex, addy-osmani]
created: 2026-06-10
updated: 2026-06-20
sources:
  - raw/articles/loop-engineering.md
related:
  - "[[addy-osmani]]"
  - "[[peter-steinberger]]"
  - "[[boris-cherny]]"
  - "[[agent-loop]]"
  - "[[agent-skills]]"
  - "[[mcp-tools]]"
  - "[[plugins]]"
  - "[[multi-agent-patterns]]"
  - "[[ai-code-review]]"
---

## 概要
**Loop engineering(ループエンジニアリング)** とは、「**エージェントに prompt する人間としての自分自身を置き換え、代わりにそれを行うシステムを設計する**」こと([[addy-osmani]] のブログ記事 "Loop Engineering", 2026-06-07)。ここでの loop は **recursive goal**(目的を定義し AI が完了まで反復する再帰的ゴール)と捉えられる。[[peter-steinberger]] の「もはやコーディングエージェントに prompt すべきでない。エージェントに prompt する**ループを設計**せよ」、[[boris-cherny]](Anthropic の Claude Code 責任者)の「私はもう Claude に prompt しない。Claude に prompt し何をするか考えるループを走らせている。私の仕事はループを書くことだ」という発言を起点に、コーディングエージェントとの働き方の未来形として提示される。

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
著者は仕事の進化のプレビューと見るが、「自分でコードをレビューせず自動ループだけに修正を頼れば製品の質は劣化し、下降スパイラルで穴を深く掘り続ける」とする。ループを組むのもよいが、エージェントに直接 prompt するのも有効で、**バランスが肝**。同じループでも使う人で結果は正反対になる ——「理解の深い仕事を速める人」と「仕事の理解を避ける人」をループは区別しないが、あなたは区別できる。これが loop design を prompt engineering より**易しくなく、むしろ難しく**する理由。[[boris-cherny]] の論点は「仕事が楽になった」ではなく「**leverage point(梃子の支点)が動いた**」。

> "Build the loop. But build it like someone who intends to stay the engineer, not just the person who presses go."

## 出典
- `raw/articles/loop-engineering.md`(Addy Osmani, "Loop Engineering", 2026-06-07)— loop engineering の定義、prompt engineering からの転換、5要素+memory、Codex/Claude Code 対応表、各要素(Automations/Worktrees/Skills/Plugins・connectors/Sub-agents)の詳細、`/loop`・`/goal`、ループの実例、3つの警告(検証・comprehension debt・cognitive surrender)、結論のすべて。

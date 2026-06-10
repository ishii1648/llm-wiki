# Log

追記専用の操作ログ。新しいエントリを**末尾に**追加し、過去エントリは編集しません。
形式: `## [YYYY-MM-DD] <ingest|query|lint> | <タイトル>`

抽出例: `grep "^## \[" wiki/log.md | tail -5`

---

## [2026-05-24] init | リポジトリ初期化
- LLM wiki パターンの雛形を作成(raw/ と wiki/ の構造、CLAUDE.md スキーマ)。
- 最初のソースを `raw/` に追加して `ingest` から運用開始する。

## [2026-05-30] ingest | Strands Agents ドキュメント 14ページ(multi-agent / agent / tools / plugins / evals)
- 取得・保存: strandsagents.com の推奨14 URL を WebFetch ではなく HTML→Markdown 変換で `raw/articles/strands-*.md` に原本保存(Astro/Starlight サイトのため `.sl-markdown-content` を抽出)。
- 追加したページ(18件):
  - entities: [[strands-agents]](ハブ), [[model-context-protocol]], [[strands-agents-evals]]
  - concepts: [[agent-loop]], [[structured-output]], [[state-management]], [[conversation-management]], [[custom-tools]], [[mcp-tools]], [[plugins]], [[agent-skills]], [[graph-multi-agent]], [[swarm-multi-agent]], [[evaluators]], [[experiment-management]]
  - syntheses: [[multi-agent-patterns]], [[graph-swarm-hybrid]]
- 主な学び:
  - マルチエージェント選定の判断軸は「実行経路の決まり方」。Graph(決定論・条件付きエッジ・サイクル)/ Swarm(自律 handoff)/ Workflow。Graph ノードに Swarm をネスト可能=ハイブリッド構成の根拠([[graph-swarm-hybrid]])。
  - SDK 差異が地雷: Python は OR セマンティクス+バッチ実行/状態蓄積、TS は AND セマンティクス+個別起動/ステートレス。timeout はネスト orchestrator に伝播しない。
  - 状態は3層(conversation history / agent state / invocation state)。conversation manager 既定は sliding window、大量 context は Summarizing + proactive compression を検討。
  - structured output は複数 Pydantic スキーマを per-invocation 上書きで運用可。
  - Skills は progressive disclosure(metadata を system prompt 注入 → tool 有効化で本文ロード)。
- 矛盾・要確認:
  - 既知の矛盾なし。各ページに Python/TS の挙動差を「SDK 差異」節として併記済み。
  - Workflow の独立ページは今回の14 URL に含まれないため未収録(必要なら追加 ingest 提案)。
  - 推奨リストにあった `hooks` / `session-management` / `snapshots` / `steering` / `context-offloader` は参照のみ(未 ingest)。

## [2026-05-30] ingest | Strands Agents ドキュメント14本を原本(.mdx)から再取得し raw を修正
- 追加/更新したページ: なし(raw 配下の strands 系 14本の原本のみ差し替え。wiki ページは未変更)
- 主な学び: 既存の原本はレンダリング済みページ経由で取得されており、コードブロックに体系的破損があった —— (1)インデント全消失(def / class 本文が桁0)、(2)全行間に2連続空行が挿入。GitHub の strands-agents/docs リポジトリ site/src/content/docs 配下の mdx(著者の手書き原本)から再取得し忠実性を回復。Python 例の PEP8 トップレベル定義間2行空けは原本どおり保持。台帳(wiki/sources.md)の14本のハッシュも新内容へ更新。
- 矛盾・要確認: (a) mdx 原本では TypeScript 例がスニペット include 記法(別 ts ファイル参照)のままで、旧 rendered 版にあった TS 実コードは含まれない。(b) 既存 wiki ページ群は旧(破損)原本から生成済みのため、コード引用箇所は修正後の原本と差異がありうる(本タスクは原本の修正に限定)。

## [2026-06-03] ingest | Code review assumes an author(blog.raed.dev)
- 取得・保存: `https://blog.raed.dev/posts/ai-code-review/` を curl で生 HTML 取得し、`<article>` 本文を忠実に Markdown 化して `raw/articles/ai-code-review-assumes-an-author.md` に原本保存(要約・整形なし。WebFetch の既定出力は要約だったため不採用)。台帳ハッシュ `ba21f8cd0a99`。
- 追加/更新したページ:
  - concepts: [[ai-code-review]](新規)
  - [[agent-loop]] に related バックリンク `[[ai-code-review]]` を追加(updated: 2026-06-03)。「システムが自分の出力を反復し PR 形の成果物を作る」=agent loop 能力の裏面、という接続。
- 主な学び:
  - コードレビューは「PR に責任を負う誰かが説明・運用できる程度に理解している」という**著者性(authorship)の前提**に依拠してきた。agentic development はコード生成を難所でなくし、誰も理解しないうちに「PR 形の成果物」を産むため、この前提が壊れる(著者がプロキシ化)。
  - レビューが「理解が初めて立ち現れる場所」へ役割転換し、負荷が質的に増す。AI レビュアはスタイル/null/セキュリティ地雷は拾えるが「diff が語らないこと」(他リポジトリ依存・夜間ジョブ・migration の新旧顧客差・障害後に消された抽象・誤った fixture)は拾えない。最難の文脈はコードベース外(障害履歴・チーム境界・却下理由の記憶)にあり retrieval では消えない——モデルは成果物を取得できるが判断の責任は負えない。
  - 適応案: AI 支援 PR は提出者が「意図・不変条件・安全の証拠」を説明できるまでレビュー不可とし、所有権をプロセスに引き戻す。PR は authorship/ownership/understanding を符号化した pre-LLM の遺物。
- 矛盾・要確認: 既存の Strands テーマ(エージェント構築 SDK)とは別テーマ(エージェント生成物のレビュー/ガバナンス)。今後 agentic-development / pull-request 等の概念ページが増えればハブ化を検討。著者名は blog ドメイン(raed.dev)から Raed Shomali と推定(記事 HTML に明示の著者メタは無し)。

## [2026-06-04] ingest | Argo CD Application Controller Scalability Testing on Amazon EKS(AWS Open Source Blog)
- 取得・保存: `https://aws.amazon.com/jp/blogs/opensource/argo-cd-application-controller-scalability-testing-on-amazon-eks/` を curl で生 HTML 取得し、`blog-post-content` 本文を忠実に Markdown 化して `raw/articles/argo-cd-scalability-testing-on-eks.md` に原本保存(WebFetch 既定出力は要約だったため不採用)。台帳ハッシュ `781b10ca47be`。著者: Andrew Lee, Christina Andonov, Carlos Santana, Nima Kaviani(2023-09-13)。
- 追加/更新したページ(新テーマ = GitOps/Kubernetes、既存 Strands とは独立):
  - entities: [[argo-cd]](新規・本テーマのハブ)
  - concepts: [[gitops]](新規・基礎語)、[[argo-cd-controller-scaling]](新規・記事の本体=設定 knob と6実験)
- 主な学び:
  - Argo CD は repo server / application controller / API server の3構成。スケーラビリティの主役は application controller。
  - 最も効く設定は (1) client QPS/burst QPS 引き上げ(42→11分)と (2) application controller のシャーディング(53分→8分30秒、10シャード)。reconciliation timeout は大規模で 3→6分(360s)が必要。
  - 公式が「最初に変えろ」と言う status/operation processors は本検証(2KB ConfigMap の人工アプリ)では効果なし → 実アプリでの再検証が課題。クラスタ数増加だけ(シャーディング無し)では改善しない(実験4・6)。
- 矛盾・要確認:
  - ⚠️ ドキュメント vs 実測: 公式は status/operation processors を最優先設定とするが実測では不変([[argo-cd-controller-scaling]] に矛盾として明記)。人工ワークロード起因の可能性。
  - 本記事は 2023-09 時点の early efforts。Akuity 等は SIG 共同設立者として言及のみ(個別 entity 未作成、リンクも張らずプレーン表記)。

## [2026-06-10] ingest | Loop Engineering(Addy Osmani）
- 取得・保存: `https://addyosmani.com/blog/loop-engineering/` を curl で生 HTML 取得し、`<article>`/`#post-body` 本文を忠実に Markdown 化して `raw/articles/loop-engineering.md` に原本保存(要約・整形なし。原文タイポ paralell/wich/dont 等も保持。WebFetch 既定出力は要約のため不採用)。台帳ハッシュ `818a59afada1`。著者 Addy Osmani、2026-06-07。
- 追加/更新したページ:
  - concepts: [[loop-engineering]](新規・本記事の本体)
  - entities: [[addy-osmani]](新規・著者ハブ。ingest 済み著作と未 ingest の関連記事群を整理)
  - 相互リンク(related バックリンク + updated: 2026-06-10): [[agent-loop]], [[agent-skills]], [[plugins]], [[mcp-tools]], [[ai-code-review]], [[multi-agent-patterns]]
- 主な学び:
  - Loop engineering =「エージェントに prompt する人間を、prompt を代行するシステム(=ループ/recursive goal）に置き換える」。Steinberger と Boris Cherny(Anthropic, Claude Code 責任者)の発言が起点。prompt engineering から「ループ設計」へ leverage point が移動。
  - 5要素+memory: ①Automations(スケジュール発見・トリアージ）②Worktrees(並列分離）③Skills(知識外部化=[[agent-skills]]）④Plugins/connectors(MCP=[[mcp-tools]]/[[plugins]]）⑤Sub-agents(maker/checker 分離=[[multi-agent-patterns]]）+ ⑥ディスク上 state(markdown/Linear)。記事の核は Codex app と Claude Code でこれらが別名・同能力で揃うという対応表。
  - Claude Code の `/loop`(cadence 再実行）と `/goal`(別の小モデルが毎ターン完了判定 = maker/checker を停止条件に適用）が明示登場。worktree 分離・`isolation: worktree`・hooks・GitHub Actions も対応として記載。
  - 警告3点(ループが良くなるほど鋭くなる): 検証責任は人間に残る(=[[ai-code-review]] と同根「confirmed works を出荷せよ」）/ comprehension debt(理解の腐敗）/ cognitive surrender(思考の明け渡し)。結論「Build the loop. Stay the engineer.」
- 矛盾・要確認:
  - 本記事は著者の自著記事を多数相互参照する(agent harness engineering / factory model / long-running agents / intent debt / orchestration tax / code agent orchestra / adversarial code review / comprehension debt / cognitive surrender 等)。いずれも原本未取得のため [[addy-osmani]] に「未 ingest」として列挙のみ(過去 Strands の参照のみ運用に準拠)。今後それらを ingest すれば agentic-development テーマのハブ化が進む。
  - 既存 Strands テーマ(SDK プリミティブ)とは別テーマ(コーディングエージェントの運用/オーケストレーション)。ただし agent-loop / skills / plugins / mcp-tools / multi-agent / ai-code-review と接続点が多く、横断ハブ候補。

## [2026-06-10] ingest | The End of Software Engineering (Cao 2026, arXiv:2606.05608v1)
- 取得・保存: arxiv HTML を curl で取得し html2text で markdown 変換、ページ chrome(report modal/nav/footer)を除いた本文を `raw/papers/the-end-of-software-engineering.md` に原本保存(初の `raw/papers/` 利用)。sha256:2c9494910273。
- 追加したページ: [[the-end-of-software-engineering]](entity/論文), [[agentic-engineering]](concept), [[agent-as-a-service]](concept)。
- 相互リンク追記: [[loop-engineering]], [[ai-code-review]], [[agent-skills]] の related に [[agentic-engineering]] を追加。
- 主な学び: AI エージェントを「ツール改良」でなくソフトの根本的再構成と捉えるポジション論文。形式モデル S=(C,D,E) vs A=(M,𝒯,ℳ,Π)、複雑性 P(n)∈Θ(2ⁿ) vs 一定の人間認知、3世代配信(Local→SaaS→AaaS/成果課金)、「Agent→Result」で成果物を中間物として除去、新分野 Agentic Engineering(intent architect/coordinator/auditor)、4段階ロードマップ(Tool-Augmented→Single-Task→Multi-Agent Teams→Self-Evolving)。
- 矛盾・要確認: (1) 論文は "Software 2.0" を SaaS の意味で使うが Karpathy の "Software 2.0"(学習重み)とは別義 → [[agent-as-a-service]] に注記。(2) ポジションペーパーで定量検証は他者ベンチの引用依存 → 各ページに「論文の主張であって wiki が検証した事実ではない」旨を明記。(3) EvoClaw の崖(孤立 >80% → 連続 38%)は完全自律の限界として重要。

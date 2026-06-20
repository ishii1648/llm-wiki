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

## [2026-06-11] ingest | AIトークンの9割はゴミだった(情報の灯台 / joho-todai.com)
- 取得・保存: `https://joho-todai.com/ai-tokens-ninety-percent-garbage/` は WebFetch が 403。curl で UA 指定して生 HTML 取得し、Ghost の `gh-content` 本文を忠実に Markdown 化して `raw/articles/ai-tokens-ninety-percent-garbage.md` に原本保存(要約・整形なし、比較表も復元。末尾の「関連記事」ナビゲーションのみ除外)。台帳ハッシュ `6aa9b6624479`。著者「情報の灯台」、2026-06-01。原記事は二次情報(一次ソース=Tejas Chopra の講演/GitHub)。
- 追加/更新したページ(新テーマ = LLM のトークンコスト/コンテキスト効率。既存 Strands・agentic-dev とは別だが接続点あり):
  - entities: [[project-headroom]](新規・ツールのハブ)、[[tejas-chopra]](新規・作者)
  - concepts: [[context-compression]](新規・本記事の本体=圧縮手法/コスト構造/競合比較)、[[context-rot]](新規・長 context での品質劣化)
  - 既存更新(related バックリンク + updated: 2026-06-11): [[conversation-management]](別レイヤ圧縮の📎注)、[[mcp-tools]](MCP 出力=70%冗長 JSON + CCR の retrieval 用途)、[[model-context-protocol]](MCP の別用途=retrieval 経路の📎注)
- 主な学び:
  - 主張: LLM に送るトークンの**最大90%は機械生成の冗長メタデータ**(JSON スキーマ/ボイラープレート/カラム定義)=「テキストのふりをした圧縮可能なデータ」。2025年研究ではユーザー入力読み込みだけで全トークンの約76%。
  - [[project-headroom]] は**プロバイダに届く前**にローカルプロキシ(port 8787, Python/Node)で型別圧縮: CacheAligner(差分送信で KV キャッシュ全置換回避)→ルーター→AST/JSON/DOM コンプレッサー+統計フィルタ「スカッシャー」→ **CCR**(マーカー化し必要時に **MCP サーバー経由でローカルの Redis/SQLite から原文復元** = 可逆)。要約=不可逆との対比が設計の核。
  - 圧縮はコストだけでなく**品質**も改善しうる: Stanford の lost-in-the-middle(関連文書が中間だと 75%→55%)、Chroma の **[[context-rot]]**(18モデル全部、長文ほど劣化)。「モデルが賢いか」より「毎回何を読ませるか」。
  - コスト構造: Uber が4カ月で年間 AI 予算消尽(84%がエージェント型へ)、Microsoft は Claude Code→Copilot CLI 移行と報道、Goldman Sachs はトークン消費2030年に24倍予測。Claude のプレフィックスキャッシュ既定5分 TTL / 1時間 TTL は書込2倍。
- 矛盾・要確認:
  - 本記事は**二次情報(まとめ系メディア)**。Stanford/Chroma の原論文、Headroom の数値($700K削減・2000億トークン・star/fork数・v0.22)はいずれも記事の引用範囲どまりで一次確認はしていない。各ページに「出典の範囲」注記を明示。
  - 競合の数値(RTK/LeanCTX/TokenCompany の削減率等)は各プロジェクト公称値で条件依存(記事注記をそのまま継承)。
  - 新テーマだが [[conversation-management]] / [[mcp-tools]] / [[model-context-protocol]] と強く接続。今後 prompt-caching や RAG を ingest すれば「コンテキスト効率」ハブ化の余地。

## [2026-06-19] ingest | Open Knowledge Format (OKF) v0.1 — Google Cloud blog
- 追加/更新したページ: [[open-knowledge-format]], [[knowledge-bundle]], [[okf-and-llm-wiki]]
- 主な学び: OKF v0.1 は「YAML frontmatter 付き markdown のディレクトリ」だけで知識を表現するオープン仕様。必須は `type` のみ、consumer は未知 type/壊れたリンク/欠損フィールドを拒否してはならない(permissive consumption)。spec §10 が LLM wiki リポジトリ・Obsidian・metadata as code を近縁とし、本 repo(Karpathy LLM Wiki パターン)はまさにその一実装。対応・差分を synthesis 化した。
- 出典の扱い: ユーザー指定の Google Cloud ブログは著作権上 raw へ全文保存できないため、同内容のオープン一次ソース(GoogleCloudPlatform/knowledge-catalog `okf/SPEC.md`, Apache-2.0)を raw/articles/okf-spec.md として ground truth に保存。ブログは作者・公開日(2026-06-13)・エコシステム(Knowledge Catalog/reference impl/sample bundles)の出典として URL 参照のみ。
- 矛盾・要確認: 本 repo の wikilink `[[name]]` と OKF 推奨の bundle-relative リンク(/path.md)が非互換 / 本 repo の lint はリンク切れを問題視するが OKF は broken link を「未到達知識」として許容 —— 運用ポリシーが逆方向(okf-and-llm-wiki に記載)。

## [2026-06-20] ingest | Loop Engineering の発端2人を entity 化(Steinberger / Cherny）
- 依頼: ユーザーが提示した3ソース(Osmani ブログ / Substack / LinkedIn)を「それぞれ ingest」。
- 冪等性チェック結果: 3つは**実体として Osmani の同一記事1本**。ブログは既 ingest 済みで raw ハッシュ `818a59afada1` が台帳と一致(内容不変）、Substack は同一本文の再掲、LinkedIn は短縮告知。→ **別ファイル ingest はせず**、Substack/LinkedIn を「同一ソースの別 URL」として sources.md と [[addy-osmani]] に記録(重複ページ回避)。
- 追加したページ(新規 entity 2件。出典は既 ingest 済みの raw/articles/loop-engineering.md 内の引用):
  - entities: [[peter-steinberger]](発火点。「prompt するな、prompt するループを設計せよ」X: @steipete）、[[boris-cherny]](Anthropic Claude Code 責任者。「もう Claude に prompt しない。仕事はループを書くこと」）
- 更新したページ(相互リンク + updated: 2026-06-20): [[loop-engineering]](本文の Steinberger/Cherny 言及を wikilink 化、related に2件追加）、[[addy-osmani]](related に2件追加 + 別 URL の冪等性メモ）、index.md(entity 2件追加）、sources.md(波及ページに2件追加 + 別 URL メモ）。
- 主な学び:
  - 「提唱した人たち」の一次情報は、概念を定式化・普及させた [[addy-osmani]] の上流に、発火点の [[peter-steinberger]] と Anthropic の [[boris-cherny]] がいる。両者の発言は既 ingest 済み raw に出典付きで含まれるため、新規取得なしで entity 化できた(知識を重複なく構造化)。
  - 一次の X ポスト(steipete / rohanpaul_ai 経由の Cherny 引用)URL は記事内参照のみで本 wiki 未取得。Cherny の引用は @rohanpaul_ai 経由の第三者リレーで本人投稿ではない点を各ページに明記。
- 矛盾・要確認:
  - [[peter-steinberger]] は当該記事に肩書・経歴の記載がなく未収録(推測で補わない）。[[boris-cherny]] は「head of Claude Code at Anthropic」のみ記事準拠で記載。
  - X 元ポストを一次ソースとして raw 保存するなら別途 ingest が必要(現状は Osmani 記事内引用が根拠）。

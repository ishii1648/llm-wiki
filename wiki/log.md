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

## [2026-06-05] ingest | One Developer Is All You Need(arXiv:2605.18461v2, Itaú Unibanco)
- 取得・保存: `https://arxiv.org/html/2605.18461v2` を curl で生 HTML(LaTeXML 生成)取得し、本文を忠実に Markdown 化して `raw/papers/one-developer-is-all-you-need.md` に原本保存(WebFetch 既定出力は要約だったため不採用)。台帳ハッシュ `4983a3ce6186`。著者: Marcelo Vilas Boas, Gustavo Pinto, Edward Roberto Monteiro, Vinicius Fernandes Carida, Danilo Ribeiro。
  - 忠実性メモ: 数式は LaTeXML alttext を `$...$` で保持。表(I〜VI)はセル毎改行に線形化された機械変換を、値を保ったまま proper Markdown table へ再構成(group行は太字行として表現)。Fig.1 の SDD テンプレートは原文どおり「具体内容は省略、角括弧プレースホルダ」とされ画像本体は無し。著者所属は原文が上付き数字(1/2/3)のみで機関名を明示しないため、捏造せず数字のまま記録(本文記載の Itaú Unibanco のみ補記)。
- 追加/更新したページ(新テーマ = AI拡張ソフトウェアデリバリ / 一人スカッド。既存の Strands・GitOps とは独立、[[ai-code-review]] と接続):
  - entities: [[one-developer-is-all-you-need]](新規・論文ハブ)
  - concepts: [[one-person-squad]](新規・構成パターン)、[[spec-driven-development]](新規・方法論)
  - [[ai-code-review]] に related バックリンク `[[one-developer-is-all-you-need]]` を追加し、「経験者=品質ゲート」が著者性回収の実務的応答という接続節を追記(updated: 2026-06-05)。
- 主な学び:
  - 1人の staff エンジニア + 4 AIエージェント(StackSpot/Devin/GitHub Copilot)を SDD で運用し、4人×6スプリント想定のブラウンフィールド案件を3スプリントで完遂。AI生成コード90%初回採用、統合テスト113/113、人件費85%超削減、BCP当たり工数51%削減。
  - 中心命題: 律速は**モデル能力ではなく「仕様の質」と「組織知」**。AIは専門性の代替でなく増幅器。core/non-core 分割が再現可能なヒューリスティック。
  - 持続的運用案は「2人技術ペア + 分数的プロダクト戦略家」。one-person は到達目標でなく境界テスト。
- 矛盾・要確認:
  - スループット急増(BCP/eng-hour 5.4倍)は実生産性向上 + BCPスコア慣習による構成効果(front-end偏重)の複合。著者が「下限」と明記。数値は CI/CD ゲート出力で外部監査なし・実務者=研究者バイアスあり(論文 §VIII)。
  - Gustavo Pinto は StackSpot 関連の先行研究[16]著者でもあり利益相反の余地(本文に明示なし、推測)。今後 agentic-development / devin / stackspot 等の概念・entity が増えればハブ化を検討。
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

## [2026-06-27] ingest | Michael Lynch "How to Write an Effective Software Design Document" (refactoringenglish.com)
- 追加したページ: [[design-doc]](concept), [[michael-lynch]](entity)
- 既存更新: [[spec-driven-development]] に `related: [[design-doc]]` を追加(SDD spec は LLM への発注書、design doc は実装前合意の人間-人間ドキュメント、という補完関係)
- 取得・保存: WebFetch は要約しか返さなかったため curl で raw HTML 取得 → markdownify (Python) で `<article>` を抽出して `raw/articles/write-an-effective-design-doc.md` に保存(498 行、sha256:e53c49985af4)
- 主な学び:
  - **書くか否かの判断軸は「間違えたときのコスト」**。high-cost(言語選択)は書く、low-cost(ページネーション UI)は書かない・レビューサイクルにも載せない。実装の全仕様を書こうとすると「設計段階で実装したのと同じ」になり目的が崩壊する。
  - **構成要素は 23 節**(Title / Metadata / Objective / Background / Related documents / Goals / Non-goals / Scenarios / Diagrams / Glossary / Constraints / SLOs / Monitoring / Timeline / Interfaces / Dependencies / Security / Privacy / Legal / Logging / Open issues / Resolved issues / Alternatives considered)。全節を毎回入れない、案件で取捨選択。
  - Goals は **impact** で書く(「Kubernetes 導入」でなく「outage 最小化」)。SLO は数値で(SLA は SLO + 金銭ペナルティで社内では普通 SLO のみ)。Monitoring は SLO の検出手段とセットで(でないと未検出のまま劣化する)。
  - Diagrams は **編集可能な形式必須**(写真化された手書き図は陳腐化したまま放置される)。推奨: Excalidraw / draw.io / Mermaid / D2 / Graphviz。LLM に diagram コードを生成させると効率良い。
  - Open issues / Resolved issues は**移し替え+元議論を残す**(将来の意思決定理由が消えないように)。Alternatives considered は簡潔に(網羅は overkill)。
- 矛盾・要確認:
  - 著者は「公開された high-quality な design doc を見たことがない」と明言し自作 OSS [little-moments](https://codeberg.org/mtlynch/little-moments) の[実物 design doc](https://refactoringenglish.com/excerpts/write-an-effective-design-doc/little-moments-design-doc/) を公開。実物 doc は今回は ingest しなかった(必要なら次回追加)。
  - [[spec-driven-development]] との関係性は短い注記にとどめた。SDD spec(AI 発注書) vs design doc(人間合意)の比較を将来 synthesis 化する余地あり。

## [2026-06-29] ingest | Writing Code vs. Shipping Code: Productivity Effects Across Generations of AI Coding Tools (NBER w35275)
- 追加したページ: [[writing-code-vs-shipping-code]], [[weak-link-hypothesis]], [[ai-coding-tool-generations]], [[ai-productivity-task-vs-output]]
- 更新したページ(相互リンク): [[one-person-squad]], [[agentic-engineering]], [[one-developer-is-all-you-need]], [[the-end-of-software-engineering]]
- 原本: NBER PDF を pymupdf でテキスト抽出し raw/papers/writing-code-vs-shipping-code.md に保存(sha256:078065ad164d)
- 主な学び: AI コーディングツール3世代(autocomplete/sync/async)の commits 累積効果は +40%/+140%/+180% だが、生産階層(LOC→…→releases)を上るほど急減衰(async: releases +30%、sync: LOC+741%→releases+20%)。較正した代替弾力性 ≈ 0.25 = AI と人手は強い補完。weak-link(O-ring)仮説の垂直版を10万+開発者の event study + 4アプリマーケットで実証。マーケットでは新規アプリ増も総利用量は不変。
- 接続: wiki 既存の楽観論([[one-developer-is-all-you-need]] / [[the-end-of-software-engineering]])に対する計量的な慎重論。「ボトルネックは消えず移動する」を統合する synthesis を新設。
- 矛盾・要確認: 楽観事例とマクロ減衰は矛盾でなく「ミクロ増幅(真)×マクロ減衰(真)」の同時成立として整理(synthesis に明記)。

## [2026-07-05] ingest | Argo CD High Availability ドキュメント(Manifest Paths Annotation 節)
- 取得・保存: readthedocs "stable" が指す実 commit(443415b5527ac55366e0760c93ef0e1abd0cf273)の `docs/operator-manual/high_availability.md` を GitHub raw から取得し、一字一句そのまま `raw/articles/argo-cd-high-availability.md` に保存(597行、sha256:d39383666816)。ユーザーの質問(「なぜ sync 時間を短縮できるか」)に答えるための query から着手し、未収録と判明したため ingest に切り替えた。
- 追加したページ: [[argo-cd-manifest-paths-annotation]](concept、新規)
- 既存更新: [[argo-cd]] に「パフォーマンス関連機能」節を追加しリンク、[[argo-cd-controller-scaling]] に補完関係の注記(reconciliation queue を速く捌く vs queue に積む対象を減らす)を追加。
- 主な学び: Argo CD は生成 manifest を **commit SHA 単位**でキャッシュするため、monorepo で1コミットするとリポジトリ内の無関係な全アプリのキャッシュが無効化され、repo-server が無駄な manifest 再生成を行う。`argocd.argoproj.io/manifest-generate-paths` アノテーション(相対/絶対/複数/glob の4パターンでパス指定)で変更検知の対象パスを絞ることで、無関係な変更では reconciliation 自体をスキップしてキャッシュを再利用でき、結果として sync 全体が速くなる。Argo CD v2.11 以降は webhook なしでも利用可能(webhook 経由の比較は GitHub/GitLab/Gogs のみ対応)。
- 矛盾・要確認: 既知の矛盾なし。アプリごとに別リポジトリの構成や外部 Helm values 参照には効果がない点をページに明記。

## [2026-07-05] ingest | Claude Code 公式ドキュメント(scheduled-tasks / goal / hooks-guide / workflows / tools-reference)
- 背景: ユーザーから「ループエンジニアリングを実現するために Claude Code で知っておくとよい tools を調べて」と依頼され、まず調査エージェント(一般調査、wiki 外)でツール一覧を整理して回答。その後ユーザーが「do」と続け、wiki への統合(ingest)を明示的に指示したため着手。
- 取得・保存: `https://code.claude.com/docs/en/{scheduled-tasks,goal,hooks-guide,workflows,tools-reference}.md` を curl で取得し、一字一句そのまま `raw/articles/claude-code-{scheduled-tasks,goal,hooks-guide,workflows,tools-reference}.md` に保存(sha256 は `wiki/sources.md` 参照)。
- 更新したページ: [[loop-engineering]](既存ページに実装詳細を追記。新規ページは作らず既存の概念に統合)
  - 追記箇所: `/loop` の固定/動的間隔と `ScheduleWakeup`、セッション内 cron と無人 Routine/デスクトップスケジュールの違い、Stop hook の command/prompt 区別と loop-until-pass パターン(ブロック上限あり)、Workflow ツール(`agent`/`pipeline`/`parallel`、adversarial verify・loop-until-dry)、Monitor/Task 系ツール/バックグラウンド実行という補助プリミティブ。
- 主な学び: Osmani 記事(既存 ingest)は「5要素+memory」という概念枠組みを示すのみで、Claude Code 側の実装詳細(ScheduleWakeup の適応スケジューリング、Stop hook の2種類、Workflow の並列制御、Monitor のイベント駆動監視)までは踏み込んでいなかった。今回はその欠落を公式ドキュメントで埋めた形。
- 矛盾・要確認: 既知の矛盾なし。ScheduleWakeup の内部スケジューリングロジックの詳細、Workflow と agent teams のコスト比較は公式ドキュメントでも明記されておらず不明点として残る。

## [2026-07-05] ingest | Claude Code 公式ドキュメント(channels-reference)
- 背景: 「Monitor に類似するツールが他にあるか、plugin 経由の配布も含めて調べて」という query から着手。調査エージェント(一般調査、wiki 外)が Channels(research preview)を発見し、ユーザーが ingest を明示指示したため着手。
- 取得・保存: `https://code.claude.com/docs/en/channels-reference.md` を curl で取得し、一字一句そのまま `raw/articles/claude-code-channels-reference.md` に保存(761行、sha256:3d8a8bac5bdc)。
- 更新したページ: [[loop-engineering]](Monitor の節を「Monitor / Channels / Task 管理 / バックグラウンド実行」に拡張)
- 主な学び: Monitor が「Claude がセッションから外を見に行く(pull)」なのに対し、**Channels**(v2.1.80+)は「外部システムがセッションへイベントを push する」逆方向の primitive。実体は stdio 通信する MCP サーバーで、one-way(webhook/監視アラート受信)と two-way(chat bridge、返信ツール公開)がある。信頼できる sender なら permission プロンプトのリモート中継(relay)も opt-in できる。公式 research preview には Telegram/Discord/iMessage/fakechat が同梱。Automations(スケジュールで能動的に見に行く)・Monitor(張り付いて見る)・Channels(受動的に通知を受ける)の3つで「発見(discovery)」手段が揃うという整理を追加。
- 矛盾・要確認: サードパーティ製 plugin/MCP サーバー(Datadog・Slack・GitHub 向け監視統合、コミュニティ製 Claude Code 監視ダッシュボード等)の実例は調査エージェントが挙げたが実在確認が取れておらず、ページには含めなかった(未検証情報として記録のみ残す)。
## [2026-07-05] ingest | Using your Opencode Go subscription in Claude Code(Kristof Kovacs, kkovacs.eu)
- 取得・保存: `https://kkovacs.eu/opencode-go-with-claude-code/` を curl で生 HTML 取得し、`<article>` 本文を忠実に Markdown 化して `raw/articles/opencode-go-with-claude-code.md` に原本保存(要約・整形なし。WebFetch 既定出力は要約のため不採用)。台帳ハッシュ `4ed8c84b18d5`。著者 Kristof Kovacs、2026-06-14。
- 追加したページ:
  - entities: [[kristof-kovacs]](新規・著者ハブ)、[[opencode-go]](新規・製品)
  - concepts: [[claude-code-non-anthropic-models]](新規・本記事の本体)
- 主な学び:
  - Claude Code は `ANTHROPIC_BASE_URL` / `ANTHROPIC_API_KEY` / `ANTHROPIC_DEFAULT_*_MODEL` / `CLAUDE_CODE_SUBAGENT_MODEL` の環境変数差し替えだけで、Anthropic Messages API 互換のゲートウェイ経由なら非 Claude モデルをハーネスの中身として使える。
  - [[opencode-go]] の場合、使えるのはモデル一覧の "AI SDK PACKAGE" 列が `@ai-sdk/anthropic` のものだけ(2026-06-14 時点で MiniMax/Qwen 系: minimax-m3, qwen-3.7-plus, qwen-3.7-max)。
  - 著者の動機: Claude 非契約者が Claude Code の新機能を安く試すための手段。普段の Claude モデル利用は OpenRouter 経由。
- 矛盾・要確認: 新テーマ(Claude Code の実行環境設定)。既存ページとの接続点は薄いため今回は独立クラスタとして追加(将来 Claude Code 関連記事が増えればハブ化を検討)。モデルラインナップは執筆時点のスナップショットで陳腐化しうる旨を [[opencode-go]] に明記。

## [2026-07-05] ingest | Claude Code 公式ドキュメント(channels-reference 日本語版)
- 背景: ユーザーから「`https://code.claude.com/docs/ja/channels-reference` を ingest したか、まだなら ingest して」と明示指示。既存 ingest は英語版(`raw/articles/claude-code-channels-reference.md`)のみだったため着手。
- 取得・保存: `https://code.claude.com/docs/ja/channels-reference.md` を curl で取得し、一字一句そのまま `raw/articles/claude-code-channels-reference-ja.md` に保存(791行、sha256:ce194d6afb6a)。
- 更新したページ: [[loop-engineering]](frontmatter `sources:` と出典セクションに日本語版を並記。本文内容は変更なし)
- 主な学び: 日本語版はバージョン要件(v2.1.80/v2.1.81 等)・コードブロック数(ts コード12箇所)が英語版と一致する忠実な翻訳と確認。技術的に新規の学びはなく、既存ページへの追記は不要と判断(出典の並記のみ)。
- 矛盾・要確認: 既知の矛盾なし。多言語ドキュメントを別 raw ソースとして扱うか(今回のように独立ファイル+`sources:` 併記)は今後も同じ方針で運用する。

## [2026-07-10] ingest | Claude Code 公式ドキュメント(channels 概要ページ、英語・日本語)
- 背景: ユーザーとの対話で「channel 機能はスマホから使えるか」「channel と MCP の関連性は」「Enterprise で channel を OFF にした場合 channel MCP も使えなくなるか」と質問が連続。既存 ingest 済みの `channels-reference`(開発者向け MCP サーバー構築契約)には Enterprise 側の詳細(`channelsEnabled` の既定値・無効時の挙動)が明記されておらず、ユーザーが概要ページの取得・ingest に同意したため着手。
- 取得・保存: `https://code.claude.com/docs/en/channels.md` と `https://code.claude.com/docs/ja/channels.md` を WebFetch で取得し、一字一句そのまま `raw/articles/claude-code-channels.md`(sha256:5eecc4b146ec)・`raw/articles/claude-code-channels-ja.md`(sha256:733b5d97933e)に保存。
- 更新したページ: [[loop-engineering]](Channels 節を拡張)
  - 追記: Channel は MCP の `experimental` capability 領域(`claude/channel`, `claude/channel/permission`)を使った拡張仕様であり、標準 MCP のトランスポート/tools 機構はそのまま使うという関係性。
  - 追記: Enterprise/Team は `channelsEnabled` が既定 OFF(Owner が明示的に有効化するまでブロック)。**`channelsEnabled` が無効/未設定でも MCP サーバー自体の接続と通常ツールは機能し、channel の push メッセージだけが届かなくなる(サイレントドロップ)** —— 「channel を切る」は MCP 接続停止ではなく `claude/channel` 拡張機能の無効化。`--dangerously-load-development-channels` は許可リストのみバイパスし `channelsEnabled` は無効化しない。`allowedChannelPlugins` はより細かい plugin 単位の許可リスト。
  - 追記: 公式の「How channels compare」比較表。Channels(外部イベントを既存セッションへ push)と **Remote Control**(claude.ai/モバイルアプリからローカルセッションを直接操縦、別機能・未 ingest)を区別。
- 主な学び: 「スマホから channel を使う」は Telegram/Discord/iMessage 経由でメッセージ・権限承認を push するもので、Claude Code 本体は PC 側で起動し続ける必要がある。一方「スマホからセッションを操縦する」目的には Remote Control という別機能が存在し、まだ本 wiki には取り込んでいない。
- 矛盾・要確認: Remote Control は今回 ingest 対象外(参照のみ)。必要になれば別途 `/en/remote-control` を ingest して独立ページ化する。

## [2026-07-10] ingest | Claude Code 公式ドキュメント(remote-control、英語・日本語)
- 背景: 直前の Channels ingest で「スマホから Claude Code を操作したい」という要求には Channels とは別に Remote Control という機能がある(未 ingest)と判明し、ユーザーが ingest に同意したため着手。
- 取得・保存: `https://code.claude.com/docs/en/remote-control.md` と `https://code.claude.com/docs/ja/remote-control.md` を curl で取得し、一字一句そのまま `raw/articles/claude-code-remote-control.md`(352行、sha256:86fbf34e7c76)・`raw/articles/claude-code-remote-control-ja.md`(392行、sha256:a36ed6cd6634)に保存。WebFetch(要約付き小型モデル経由)では英語版にある「スマホ/ブラウザから画像・ファイル添付を送る」箇条書きが日本語版取得時に欠落する事象を確認したため、curl による直接取得に切り替えた。
- 追加したページ: concepts: [[claude-code-remote-control]](新規)
- 更新したページ: [[loop-engineering]](Channels 節の「Remote Control は本 wiki 未 ingest」という注記を新規ページへのリンクに更新、`related:` にも追加)
- 主な学び: Remote Control は claude.ai/code・モバイルアプリから**ローカルの Claude Code セッションを直接操縦する**機能で、Channels(外部イベントを push)とは逆方向(人間が能動的に操縦)。セッションは常にローカルマシンで動き続け、ファイルシステム・MCP サーバーはそのまま使える。Team/Enterprise は既定 OFF(Channels の `channelsEnabled` と同型の構造)。β機能の Trusted Devices はデバイス登録+18時間以内サインイン+生体認証を組織単位で必須化できる。公式比較表に **Dispatch**(モバイルアプリからのタスクメッセージで Desktop セッションを生成)という今回初出の関連機能名も登場(未 ingest)。
- 矛盾・要確認: Dispatch は参照のみで未 ingest。Choose the right approach 比較表は Channels ページのもの(How channels compare)と項目が一部重複するが矛盾はなし、視点(Remote Control 起点 vs Channels 起点)が異なるための重複と判断。

## [2026-07-12] ingest | aihero.dev "9 Things People Get Wrong With /grill-me and /grill-with-docs"
- 背景: ユーザー指定 URL は著作権保護されたブログ記事で、WebFetch(小型モデル)は 125文字/引用の制限を明示して全文転載を拒否(既知の著作権ingestフォールバックパターンと合致)。記事の対象である `/grill-me` `/grill-with-docs` は Web 検索の結果、著者 Matt Pocock の GitHub リポジトリ `mattpocock/skills`(MIT license)で SKILL.md として公開されていると判明したため、そちらを一次ソース(ground truth)として `gh api` 経由で raw 保存し、ブログ本文は URL 参照のみに留めた。
- 取得・保存: `gh api -H "Accept: application/vnd.github.raw"` で以下4ファイルを一字一句そのまま保存(すべて `github.com/mattpocock/skills` MIT):
  - `raw/articles/mattpocock-grill-me-skill.md`(sha256:6189dfceb730) — `/grill-me` は `disable-model-invocation: true` の薄いラッパーで実体は `grilling` スキル呼び出し
  - `raw/articles/mattpocock-grilling-skill.md`(sha256:5a35925d03a3) — 質問攻めの本体ルール(1問ずつ・推奨解答つき・事実はコードベースで確認・決定はユーザーに委ねる)
  - `raw/articles/mattpocock-grill-with-docs-skill.md`(sha256:610d091047bc) — `grilling` + `domain-modeling` の合成
  - `raw/articles/mattpocock-domain-modeling-skill.md`(sha256:152e2c97239a) — CONTEXT.md 用語集 / docs/adr/ を能動的に構築する規律。ADR は「覆しにくい・意外・トレードオフの結果」の3条件が揃った時のみ
- 追加したページ: entities: [[matt-pocock]](新規)。concepts: [[grilling]]、[[grill-with-docs]]、[[domain-modeling]](いずれも新規)
- 主な学び: `/grill-me` は計画の質問攻めのみ、`/grill-with-docs` はそれに加えて用語・ADR をファイルに永続化する点が主な違い。ブログ記事(WebFetch 要旨)からは、high-fidelity な質問をプロトタイプ前に無理に答えさせない・スコープを絞る(長い grilling は ~120k トークンで判断品質が落ちる "dumb zone")・受け身にならない・設計成果を `/2PRD` 等で残す・grilling には賢いモデルを使う・並列セッションでスループットを上げる、という6つの誤用パターンを [[grilling]] に記載。
- 矛盾・要確認: 記事タイトルは「9 Things」だが、WebFetch(2回試行)で確認できた失敗パターンは6件のみで、残り3件は未取得(ツールの要約が全文をカバーしていない可能性)。[[grilling]] ページにその旨を明記済み。ブログ記事本文は著作権のため raw/ 未保存、`sources:` には URL を直接記載(lint.sh の `raw/` パス整合チェック対象外)。

## [2026-07-16] ingest | Backlog.md のタスク Markdown 形式と OKF 準拠性の調査
- 背景: 別セッションで Backlog.md リポジトリ(MrLesk/Backlog.md)の CLI・タスク Markdown 形式を調査し、Google の Open Knowledge Format(OKF、本 wiki には既存: [[open-knowledge-format]])準拠かを問われた。その調査結果をこの wiki に統合。
- 取得・保存: 一字一句そのまま4本を `raw/articles/` に保存——`backlog-md-manifesto.md`(MANIFESTO.md 全文、sha256:7e6c40d5eb3b)、`backlog-md-task-example.md`(実タスク BACK-547 の Markdown 全文、sha256:79f3dd568f0a)、`backlog-md-cli-instructions.md`(`backlog instructions` の overview/task-creation/task-execution/task-finalization 4ガイド全文、CLI v1.48.0、sha256:c67543beea41)、`backlog-md-init-and-task-create.md`(`backlog init`/`backlog task create` をローカルで実地検証した結果——生成ディレクトリツリー・config.yml・生成タスクファイル・`--ac` カンマ区切りが分割されない落とし穴、sha256:0034acdff33b)。既存の `raw/articles/okf-spec.md` はハッシュ一致(b9655e607346)を確認し再取得せず流用。
- 追加したページ: entities: [[backlog-md]](新規、CLIが正典とするタスク管理ツール本体)。syntheses: [[backlog-md-vs-okf]](新規、Backlog.md タスク Markdown と OKF v0.1 の比較)
- 更新したページ: なし(`okf-spec.md` の波及ページ一覧に [[backlog-md-vs-okf]] を追記)
- 主な学び: Backlog.md のタスク Markdown は YAML frontmatter + Markdown 本文という表面形式は OKF と一致するが、OKF準拠を意図した設計ではない。OKF の唯一の必須フィールド(`type`、非空)は `type: bug` として偶然満たすが、OKF推奨の `description`/`tags`/`timestamp`/`resource`(§4.1)のセマンティクスには従わず(`description`は本文セクション、`tags`ではなく`labels`、`timestamp`ではなく`created_date`/`updated_date`に分割、`resource`なし)、`type`の意味自体も違う(concept分類 vs タスク種別)。`okf_version`宣言(§11)もない。結論: OKF準拠ではない。
- 矛盾・要確認: 既知の矛盾なし。Backlog.md 側の「CLI経由編集のみ許容」という設計は OKF の permissive consumption 原則(§9、未知フィールド等を理由に拒否してはならない)と方向性が逆だが、両者は独立設計であり矛盾ではなく設計思想の違いとして [[backlog-md-vs-okf]] に明記。

## [2026-07-16] ingest | Backlog.md の運用モデル(3レビューチェックポイント)とCLI起動メカニズムの調査
- 背景: 別セッションで、「backlogの内容をコーディングエージェントに渡してそのまま実行させる運用は想定されているか」「人が自然言語で呼びかけるだけでエージェントが `backlog` コマンドを実行するのはClaude Codeのルール機能か」という2点を Backlog.md リポジトリ(MrLesk/Backlog.md)を実地調査して回答した。その調査結果を [[backlog-md]] に統合。
- 取得・保存: 一字一句そのまま2本を `raw/articles/` に追加保存——`backlog-md-readme-ai-workflow.md`(README.md の「AI agents write the code. You review the tasks」タグラインと3レビューチェックポイント・spec-driven AI developmentフロー全文、sha256:665185e643c2)、`backlog-md-agent-instructions-mechanism.md`(`src/agent-instructions.ts`/`src/guidelines/cli-agent-nudge.md`/`src/guidelines/index.ts` の全文 + Backlog.md自身のリポジトリの `.claude/settings.json`・`.mcp.json` にhooks/MCP強制設定が存在しないことのローカル実地検証ログ、sha256:63400c1d7038)。
- 追加したページ: なし(新規ページは作らず既存 [[backlog-md]] に統合)
- 更新したページ: [[backlog-md]] — 「3つのレビューチェックポイントと運用モデル」節、「自然言語呼びかけ→CLIコマンド実行の起動メカニズム(実地検証)」節を新設。frontmatter `sources:` と末尾の出典リストに新規raw2本を追加。
- 主な学び: (1) 「既存タスクを読み、計画を立て、コードを書く」というエージェント主導の実行そのものはBacklog.mdの想定用途そのものだが、「人間のレビューなしの全自動実行」は設計の中心ではない——マニフェストの Design Principle 4「Review before consequence」と Boundaries「not an agent-only orchestration system」、および task-execution ガイドの「material decisionを含む計画は明示的承認を待つ」という明文規定がこれを裏付ける。(2) 自然言語の呼びかけでCLIコマンドが実行される仕組みは、Claude Code固有のhooksやルールエンジンではなく、`backlog init` が `CLAUDE.md`/`AGENTS.md`/`GEMINI.md`/`.github/copilot-instructions.md` の4ファイルへ同一のナッジ文(`<CRITICAL_INSTRUCTION>`タグ付きMarkdown)をマーカーコメントで冪等挿入するだけの仕組みであり、実効性は各コーディングエージェント側がもともと持つ「起動時にこれらのファイルを自動でシステムコンテキストへ読み込む」という規約とLLMのプロンプト追従性に完全に依存する。プログラム的な強制(hooks/MCPゲート)はBacklog.md自身のコードにもリポジトリ設定にも存在しない(実地確認)。
- 矛盾・要確認: 既知の矛盾なし。

## [2026-07-16] ingest | Backlog.md ワークフロー図解のスクリーンショットを添付
- 背景: ユーザーが別セッションで作成した Artifact(あなた/Backlog台帳/エージェントの3レーンで6ステージ+3チェックポイントを示すフロー図、claude.ai artifact URL)を明示的に指定し、「スクショして添付」と依頼された。Artifact URLは非公開でヘッドレスブラウザから直接取得できないため、同一内容のローカルHTML(Artifact公開時に使ったソースファイル)を headless Chrome でレンダリングしてスクリーンショットを取得した。
- 取得・保存: `raw/assets/backlog-md-workflow-diagram.png`(sha256:9f58dd9ec1b0)を新規保存。`wiki/entities/backlog-md.md` からは `../../raw/assets/backlog-md-workflow-diagram.png` の相対パスで直接参照する(重複配置はしない、原本1箇所のみ)。
- 追加したページ: なし
- 更新したページ: [[backlog-md]] — 「3つのレビューチェックポイントと運用モデル」節に図を埋め込み。frontmatter `sources:` と末尾の出典リストに追加。
- 主な学び: 本 wiki で画像アセットを埋め込むのは今回が初めて。`scripts/lint.sh` の broken-source チェックは本文中の `raw/...` という文字列パターンを機械的に拾うため、Markdown画像記法 `![...](path)` 内のパスも自動的に検証対象になる(相対パスの `../../` 部分の後ろに続く `raw/...` が部分文字列として抽出されるため、`raw/` 配下を指す限りどちらの書き方でも検証は通る)。ただし mkdocs の `docs_dir` が `wiki/` のみである点は raw/ 配下の画像がそのままでは公開サイト(GitHub Pages)には反映されない制約として残る——GitHub上のファイル閲覧・PRのdiffプレビューでは表示されるが、mkdocsビルドしたサイトには出ない。この制約は許容し、原本を `raw/` に一本化した(wiki/ 側への複製はしない)。
- 矛盾・要確認: 既知の矛盾なし。

## [2026-07-16] lint | backlog-md 添付図が公開サイトに表示されない問題の修正
- 背景: ユーザーが公開サイト https://ishii1648.github.io/llm-wiki/entities/backlog-md/ を実際に開き、直前のingestで追加した図(旧: `raw/assets/backlog-md-workflow-diagram.png`)が表示されないと報告。前回のログで「許容する」とした `docs_dir: wiki` の制約(`raw/` は mkdocs のビルド対象外)が、想定どおり実際に問題として顕在化した。
- 対応: `raw/assets/backlog-md-workflow-diagram.png` を `wiki/entities/assets/backlog-md-workflow-diagram.png` へ移動(コピーではなく `git mv`、ファイルは1つのみ)。`wiki/entities/backlog-md.md` の画像参照を相対パス `assets/backlog-md-workflow-diagram.png` に変更。この図は一次資料(ingestしたソース)ではなくページの添付図という位置づけに整理し、frontmatter `sources:`・出典リスト・`wiki/sources.md` 台帳からは外した(台帳はingest済みソースのみを対象とするため)。
- 追加したページ: なし
- 更新したページ: [[backlog-md]]
- 主な学び: `docs_dir: wiki` の制約は「許容できる理論上の制約」ではなく「実際にユーザーが見て気づく実害」だった。この wiki で画像を**公開して見せる**目的で使う場合は `raw/assets/` ではなく `wiki/<page-dir>/assets/` に置く必要がある。`raw/` は一次資料の原本置き場、`wiki/` 配下の画像はページに紐づく表示用資産、という役割分担にする。今後 raw/assets/ に置くのは「ingestの原本として保存するだけで、ページに埋め込み表示はしない」画像に限定する。
- 矛盾・要確認: 既知の矛盾なし。

## [2026-07-29] ingest | Bringing MCP 2026-07-28 to Claude(Anthropic ブログ)
- 取得・保存: ユーザー指定 URL https://claude.com/blog/bringing-mcp-2026-07-28-to-claude を取得し、`raw/articles/bringing-mcp-2026-07-28-to-claude.md`(sha256:9361b2c39950)として原文を新規保存。本文2ブロックの間に挟まる6社のテスティモニアル(Figma/Intuit/Netlify/PostHog/Xero/Zoom)も原文どおり引用ブロックで保存した。
- 追加したページ: [[mcp-2026-07-28]](第5版スペックのエンティティ), [[mcp-extensions]](Apps/Tasks の拡張フレームワーク)
- 更新したページ: [[model-context-protocol]] — 「スペックの進化と普及(2026-07 時点)」節を新設し新ページへリンク。[[mcp-tools]] — トランスポート節に stateless core 化の注記を追加。
- 主な学び: (1) MCP 2026-07-28 は第5版スペックで、コアが双方向ステートフルから stateless な request/response モデルへ移行。MCP サーバの serverless/edge 配備が可能になり、Netlify いわく「セッション管理の回避策が不要な first-class HTTP ワークロード」になった。(2) MCP Apps(会話内の対話的 UI)と Tasks(長時間処理)は versioned extensions framework へ正式昇格し、コア変更なしの能力追加経路が確立。(3) 認可は OAuth 2.0/OIDC の本番運用に整合し Entra/Okta へ直結可能。(4) 普及の規模感: 月間 SDK 400M DL(年4倍)、Claude connectors directory は 950+ サーバ。(5) Claude 側の関連機能として MCP Apps/enterprise-managed auth/observability ダッシュボード/MCP tunnels(research preview)が出荷済み。
- 矛盾・要確認: 既知の矛盾なし。[[mcp-extensions]] の「Tasks が stateless コアと対になる設計」という記述はソースに明示がないため(推測)と明記した。

## [2026-08-07] ingest | Claude Code Self-hosted environments(公式ドキュメント7ページ)
- 取得・保存: ユーザー指定 URL https://code.claude.com/docs/en/self-hosted-environments とその配下5ページ+identity の計7ページを、Mintlify の `.md` エンドポイント(URL 末尾に `.md`)から原文 markdown のまま取得し `raw/articles/claude-code-self-hosted-environments{,-quickstart,-deploy,-configuration,-testing,-reference,-identity}.md` として新規保存(整形・要約なし)。
- 追加したページ: [[self-hosted-environment]](概念・アーキテクチャ・制限・脅威モデル), [[self-hosted-runner]](runner の運用), [[self-hosted-runner-extensions]](wrapper/lifecycle hooks/orchestrator/MCP/権限), [[session-identity-token]](セッション JWT の検証)
- 更新したページ: [[claude-code-remote-control]] — cloud session を自社インフラで動かす別解として [[self-hosted-environment]] へのリンクと公式の使い分け(常時稼働の自マシン操縦なら Remote Control、Pro/Max 可)を追記。
- 主な学び: (1) 移るのは**実行だけ**で制御プレーン(キュー・UI・transcript 保存)は Anthropic 側に残る。会話内容は推論のため api.anthropic.com へ出るので「データが外に出ない」ではなく「checkout と成果物が自社に残る」が正しい主張。(2) **1 runner = 1 ユーザー**にロックされるため、fleet の最小数は同時アクティブユーザー数で、`--capacity` はユーザー間の並列度ではない。(3) 脅威モデルが重い: 組織の誰でも任意環境へ dispatch でき(環境単位のアクセス制御なし)、既定 pre-approve に `Bash` が含まれるので **default-deny egress が実質唯一の境界**。固定 fleet では environment secret がセッションのコードから読める(on-demand orchestrator ならセッション実行ホストから隔離できる)。(4) 運用の地雷が具体的: 環境変数はフラグと違い常にミリ秒(`STARTUP_TIMEOUT_MS: "15"` は 15 分でなく 15 ミリ秒)、K8s 既定の grace period 30 秒はドレイン所要 80 秒より短い、wrapper で子を `&` にすると stdin が切れて約30分後に 401、one-shot 環境では終端カウンタが scrape に乗らない。(5) 推論は Anthropic API 固定で Bedrock/LLM gateway へは回せず、ZDR 有効組織では利用不可。(6) セッション JWT は「セッション内の任意コードが読める」前提の資格情報なので、`aud` に自社 `ccpool_...` を必ず突き合わせ、派生クレデンシャルは能力・寿命ともに絞る設計が前提。
- 矛盾・要確認: `post-session` hook の `CLAUDE_RUNNER_EXIT_REASON` と Prometheus のセッションカウンタで、idle release / startup timeout / server deassign の分類が食い違う(hook は `interrupted`、カウンタは `completed`)。ドキュメント上は意図的な仕様として明記されているため矛盾ではないが、突合すると completion を過小評価する点を [[self-hosted-runner]] に明示した。

## [2026-08-11] ingest | AI-Driven Development Lifecycle (AI-DLC) Method Definition(AWS)
- 取得・保存: ユーザー指定 URL https://prod.d13rzhkk8cj2z0.amplifyapp.com/ は React SPA で、実体は同ドメインの `/aidlc.pdf`(8ページ)。PDF を取得し `pdftotext`(poppler)でテキスト層を抽出、文字列無改変で `raw/papers/aidlc-method-definition.md`(sha256:8a7b6cef429c)として新規保存。原稿が2段組のため抽出結果は所々で段の読み順が入れ替わる旨をヘッダに明記した。
- 追加したページ: [[ai-dlc]](方法論本体・10原則・3フェーズ・ワークフロー・Appendix A), [[intent-unit-bolt]](成果物階層と Scrum 対応), [[mob-rituals]](Mob Elaboration / Mob Construction), [[ai-dlc-vs-spec-driven-development]](SDD / one-person-squad / agentic engineering との突合)
- 更新したページ: [[spec-driven-development]] — 「独立に到達した同型の方法論: AI-DLC」節を新設。[[agentic-engineering]] — 「方法論としての具体化: AI-DLC」節を新設し Cao の4段階での位置づけ(Stage II 相当)を注記。[[one-person-squad]] — 「対照: mob を要求する AI-DLC」節を新設。[[domain-modeling]] — ADR 生成トリガの対比(人間の判断 vs 段階遷移)を追記。
- 主な学び: (1) AI-DLC は「AI を後付けせず第一原理から作り直す」を掲げるが、Unit ≒ Epic / Bolt ≒ Sprint と論文自身が対応を明示しており、実質の差分は「分解の主体が人間から AI へ」「反復が週から時間/日へ」の2点に絞られる。(2) 原則2「会話の向きの反転」(AI が問いを立て、人間は approver)が方法論の核。アナロジーは Google Maps。(3) 原則3で DDD を方法論のコアに内蔵する点は独自性が高い——AI に生成させるには生成物の型(aggregate / entity / domain event 等)が事前に定まっている必要がある、という論理。(4) 人間の検証を「loss function」と定義し、誤りが下流で雪だるま式になる前に刈り取る。(5) 全成果物を永続化・相互リンクして "context memory" にする設計は本 wiki 自身や [[open-knowledge-format]] と同じ骨格。(6) brown-field は既存コードを static / dynamic model へ「引き上げ」てから通常フローへ——[[one-developer-is-all-you-need]] が報告した「未文書化のレガシー統合契約が最大の under-specification 源」への処方と独立に一致した。(7) 実務的な持ち帰りは方法論本体より Appendix A のプロンプト規約(`aidlc-docs/` の md 階層、チェックボックス付き plan を先に書かせる、承認まで実行させない、重要な決定を勝手に下させない)。
- 矛盾・要確認: (a) AI-DLC 内部の矛盾として、原則9「minimise stages, maximise flow」と III 章の「各段に人間の検証を置く再帰構造」が逆方向を向いている点を [[ai-dlc-vs-spec-driven-development]] に明示。(b) 原則8「専門役割の必要数を減らす」と、儀式が mob(PO + 開発者 + QA + ステークホルダー)の同席を要求することの緊張を [[mob-rituals]] / [[one-person-squad]] に記載。(c)「米国のソフトウェア品質問題は 2022 年に $2.41 兆」の引用は原文で "(study)" とリンクされているのみで、抽出テキストにリンク先が残っておらず**出典未確認**(CISQ 報告と推測)。(d) 効果の主張(「数週間〜数ヶ月が数時間に凝縮」等)に事例・測定が一切なく、[[ai-productivity-task-vs-output]] の減衰証拠に対して無防備である点を批判的注記として記載。(e) 原文に `responsibiliti4es` / `CONSTRUCTTION` / `brown-filed` 等の誤記が残るドラフト相当の文書であり、査読論文としては扱わない。

## [2026-08-11] ingest | AI-DLC の情報劣化を修復(同一ソースの再統合)
- 契機: ユーザーから「原文から著しく情報劣化してる」と指摘。同日の初回 ingest([[ai-dlc]] 他)を原文と1章ずつ突き合わせて欠落を洗い出した。ソース(`raw/papers/aidlc-method-definition.md`, sha256:8a7b6cef429c)は不変のため台帳のハッシュは据え置き、波及ページのみ追加。
- 特定した欠落: (1) I 章の論証の土台——「ソフトウェア工学は下位の非差別化タスクの抽象化を続けてきた」という系譜(機械語→高級言語→API/ライブラリ)と、既存手法批判の3点(human-driven/long-running 前提、manual workflows と rigid role definitions への依存、retrofit が旧来の非効率を強化する)、および「AI を central collaborator に据える」という結論。(2) 10原則を**表の1セルに圧縮**したことで各原則の論拠が消失——原則3の "right-sized bounded contexts" とマントラ "Build Better Systems Faster"、原則5の「複数チーム・大規模/規制下組織」前提、原則8の「役割は最小限、critical に必要な時のみ追加」、原則9の 'quick-cement'、原則10の Level 2 以降の階層など。(3) **Operations フェーズの green-field 具体手順を丸ごと欠落**(Deployment a-b、Observability and Monitoring a-c、レイテンシスパイク→スケーリング、API レスポンス劣化→DynamoDB スループット増/API Gateway 再分散の例)。(4) **Appendix A のプロンプト集が最大の劣化**——全7ブロックを抽象化した箇条書き4行に潰していた。
- 追加したページ: [[aidlc-prompt-kit]](Appendix A 全7ブロック。共通テンプレート = Role 付与 + 計画ゲート6要求 + Task、Setup Prompt のフォルダ規約表、Inception 2ブロック、Construction 4ブロック、承認フレーズ3種)
- 更新したページ: [[ai-dlc]] — I 章を「抽象化の系譜と2つの時代区分」節として復元、10原則を表から**節形式に展開**して各原則の論証を保持、Operations フェーズの記述を厚くし、IV/V 章の出発点(cross-selling レコメンドエンジンの intent)と VI 章の導入戦略を補強、批判的注記に「BDD/TDD フレーバーは未公開」を追加。[[mob-rituals]] — Operations フェーズ(green-field)の節を新設し、III 章の runbook と IV 章の playbook で原文の用語が揺れている点を注記。[[intent-unit-bolt]] / [[ai-dlc-vs-spec-driven-development]] — [[aidlc-prompt-kit]] への相互リンクを追加。
- 主な学び: (1) **表による圧縮は情報劣化の主犯**。10原則のような「各項が独立した論証を持つ」構造を表の1セルに落とすと、主張は残るが根拠が消える。一覧性が要る場合でも、表は索引として置き、本体は節で展開すべきだった。(2) 論文の**付録は本文より実務価値が高いことがある**。AI-DLC の Appendix A は方法論本体(用語の刷新が主)より再利用可能な資産(plan-then-execute ゲート、`prompts.md` への入力永続化)を含んでいた。付録を「補足」と見なして要約する判断が誤りだった。(3) 章立てを機械的に追うだけでは IV 章 3(Operations の具体手順)のような**節の丸ごと欠落**を自分では検知できない。ingest 後に原文の見出しを列挙して網羅チェックする工程が要る。
- 矛盾・要確認: (a) 原文内の用語揺れとして、Operations の統合先が III 章では incident **runbook**、IV 章では **playbook** と書かれている点を [[mob-rituals]] に注記。(b) Appendix A 内の不整合——Setup Prompt が定めた `aidlc-docs/design-artifacts/` と後続ブロックが使う `design/` の食い違い、参照ファイル名の非一貫(`mvp_user_stories.md` / `design/seo_optimization_unit.md` / `search_discovery/nlp_component.md`)、`<< describe product descrition>>` の誤記を [[aidlc-prompt-kit]] に明示し「そのままコピーして使える状態ではない」と評価した。

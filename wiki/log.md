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

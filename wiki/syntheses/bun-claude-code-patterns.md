---
title: Bun リポジトリの Claude Code 活用パターン
type: synthesis
aliases: [bun claude code, oven-sh/bun AI workflow, bun エージェント運用]
tags: [claude-code, agent-workflow, ci, developer-tooling, bun]
created: 2026-05-27
updated: 2026-05-27
sources:
  - https://github.com/oven-sh/bun
  - https://raw.githubusercontent.com/oven-sh/bun/main/CLAUDE.md
  - https://github.com/oven-sh/bun/tree/main/.claude
  - https://github.com/oven-sh/bun/tree/main/.github/workflows
related:
  - "[[bun]]"
---

## 概要

[[bun]](oven-sh/bun)は、Claude Code を「補助的に使う」段階を超えて、**リポジトリ自体をエージェント前提に作り込んでいる**。
コミットログを追うと、CLAUDE.md の運用契約・実行を物理的に縛る hooks・反復作業を手順化した slash command・GitHub Actions への組み込み・専門知識の skills・エージェント専用 CLI ツール、という多層構造が 2025〜2026 にかけて段階的に整備されてきたことがわかる。
本ページはその「工夫している点」を層ごとに洗い出してまとめる。

> 出典は外部 GitHub のため `raw/` 配下ではなく URL を明記する。各主張の直後に該当ファイルを示す。

---

## 1. CLAUDE.md — エージェント向けの「運用契約」

`CLAUDE.md`(316行)は単なる説明書ではなく、**やってはいけないことを断定形で並べた契約書**になっている。コミット履歴上、2025-06 以降ほぼ毎月のように改訂されており、エージェントが踏んだ地雷を都度ルール化してきた痕跡がある。主な工夫点:

- **ビルドコマンドの一本化**: 開発ビルドは必ず `bun bd` / `bun bd test <file>`。`bun test` や `./build/debug/bun-debug` の直叩きを禁止(変更が反映されないため)。
- **テストの妥当性を機械的に定義**: 「`USE_SYSTEM_BUN=1 bun test <file>` で **fail** し、`bun bd test <file>` で **pass** すること」を要求。これにより「変更を実際に検証していないテスト」を弾く。
- **flaky 撲滅**: 「`setTimeout` を使うな。時間経過ではなく条件を `await` せよ」。
- **`.zig` は参照専用**: Rust 移行後、`.zig` は「意図したセマンティクスの正典」だが非コンパイル・編集禁止と明記(2026-05「Rewrite Bun in Rust」前後で記述が更新)。
- **branch 名は `claude/` 始まり必須**(CI 連携の条件)。
- **正直さの明文化**: 「Be humble & honest — コミット/PR/メッセージで成果を誇張するな」。
- **regression テストの濫用防止**: `test/regression/issue/${n}.test.ts` は「実在する issue 番号」かつ「過去に動いていて壊れた真の regression」に限定。プレースホルダ番号禁止。
- **例外も明記**: `packages/bun-types/**/*.d.ts` の型定義変更はネイティブビルド不要なので `bun bd` を待たず `bun test` 直叩きしてよい、と「禁止ルールの例外」まで書く。
- **Code Review Self-Check**: 「非自明な選択はコードを書く前に『なぜ他案でなくこれか』を自答せよ。書いてから正当化するな」「隣接コードと違うことをするなら、まず理由を調べよ(その選択は load-bearing なことが多い)」。

要点: **判断を促すのではなく、失敗パターンを禁止規則として蓄積している**。

---

## 2. Hooks — ガードレールを「コードで」強制する

ドキュメントは無視されうるので、Bun は `.claude/settings.json` で hooks を仕込み、**ルール違反をツール実行レベルで物理的にブロック**している。これが最大の工夫点と言える。

### PreToolUse(Bash 実行前) — `.claude/hooks/pre-bash-zig-build.js`

Bash コマンドを自前でトークナイズし、以下を `permissionDecision: "deny"` で却下する:

- `zig build obj` → 「`bun bd` を使え」
- `rustfmt` 直叩き → 「CI は `cargo fmt --all` をチェックする。それを使え」(rustfmt は workspace edition を読まず CI と食い違うため)
- `timeout … bun bd` → 「タイムアウト無しで実行せよ」。しかも **リダイレクト(`2>&1`/`>`/`>>`)やパイプを除去してから判定**し、ラップによる回避を検出する(コード中のコメント: *"Claude is a sneaky fucker"*)。
- `bun test`(`bd` 無し・`USE_SYSTEM_BUN=1` 無し)→ `bun bd test` に誘導。
- `bun test` で `-u`(snapshot 更新)と `-t`(name フィルタ)の併用 → 危険なので却下。
- リポジトリ root / `test` ディレクトリで **ファイル指定なしの `bun bd test`** → 全テスト実行を防ぐため却下。

### PostToolUse(Write/Edit/MultiEdit 後) — `.claude/hooks/post-edit-zig-format.js`

編集直後に拡張子に応じて自動整形(`.zig`→`zig fmt`、`.ts/.js/.css/.json/...`→`prettier`)。
工夫点として **organize-imports プラグインを意図的に外している**: 分割編集(import 追加→次の編集で使用)の途中で「未使用」と判定された import を消してしまうため。CI 側の `bun run prettier` が最終的に整理するので問題ない、というコメント付き。

要点: **「やめろ」と書く代わりに、できないようにする**。エージェントの抜け道(timeout ラップ等)まで先回りで塞いでいる。

---

## 3. Slash commands — 反復作業を「マルチエージェントのレシピ」に

`.claude/commands/` に 5 つの定義(`dedupe`, `find-duplicate-prs`, `find-issues`, `upgrade-nodejs`, `upgrade-webkit`)。GitHub トリアージ系の工夫が濃い:

- **`allowed-tools` で権限を最小化**: frontmatter で `Bash(gh issue view:*)` など使える `gh`/`git` サブコマンドだけを許可。「`gh` 以外のツール・MCP・file edit を使うな」と本文でも釘を刺す。
- **検索を並列エージェントに分割**: `find-issues` / `dedupe` は **5 並列**、`find-duplicate-prs` は **3 並列**のサブエージェントが、それぞれ別戦略(エラーメッセージ / 変更ファイルパス / API 名 / タイトル語 / 周辺語)で検索 → 別の「フィルタ用エージェント」が偽陽性を除去、という多段パイプライン。
- **冪等性を HTML マーカーで担保**: コメントに `<!-- dedupe-bot:marker -->` 等を埋め、再実行時はマーカーの有無で二重処理を防ぐ。
- **出力フォーマットを固定**: コメント本文のテンプレートを厳密指定。`find-issues` は `Fixes #<n>` ブロックを生成し、PR 作者がそのまま description に貼れるようにする。
- **検索スコープ強制**: 「必ず `repo:owner/repo` でスコープし、クロスリポジトリの偽陽性を防げ」を繰り返し明記。
- **runbook 型**: `upgrade-nodejs` / `upgrade-webkit` は更新すべきファイル・コマンド・チェックリストを列挙した純粋な手順書(WebKit upgrade は「コンパイル待ちの間に別タスクで JSC コミットを要約せよ」など並行作業まで指示)。

---

## 4. GitHub Actions への組み込み — `claude-code-base-action`

slash command を **CI 上で無人実行**している点が大きな工夫。`anthropics/claude-code-base-action`(SHA 固定)に `prompt: "/dedupe ..."` を渡す形:

- `claude-dedupe-issues.yml`: issue が `opened` されると自動で `/dedupe` を実行(`workflow_dispatch` で手動再実行も可)。
- `claude-find-issues-for-pr.yml`: PR `opened` で `/find-issues` と `/find-duplicate-prs` を連続実行(`if: always()` で 2 本目も必ず走る)。
- いずれも `ANTHROPIC_MODEL: claude-opus-4-6[1m]`(1M コンテキスト)、`timeout-minutes`、`concurrency … cancel-in-progress: true` を設定し、最小権限(`issues: write` 等)で動かす。
- **決定論的な後始末は LLM ではなくスクリプト**: `auto-close-duplicates.yml` は毎日 cron で `scripts/auto-close-duplicates.ts` を実行し、3 日経過した重複 issue を機械的にクローズ(検出は LLM、クローズは決定論)。

---

## 5. Skills — 専門知識をオンデマンドで注入

`.claude/skills/` に 7 つ(`implementing-jsc-classes-cpp` / `implementing-jsc-classes-zig` / `javascriptcore-garbage-collector` / `writing-bundler-tests` / `writing-dev-server-tests` / `zig-system-calls` / `slowest-tests`)。

- コミット履歴上、2025-12 に **`.cursor/rules` を `.claude/skills` に変換**しており、エディタ非依存のエージェント知識ベースへ移行している。
- 各 skill は `name` / `description` の frontmatter を持ち、「いつ使うか」を明示(例: bundler/transpiler テストを書くとき `itBundled` の使い方を提供)。
- `slowest-tests` は単なる知識ではなく **実運用ワークフロー**: `bun run ci:slowest` で BuildKite ログから遅いテストを集計し、Slack へ整形投稿するところまで手順化。「Slack MCP は markdown テーブルを受け付けない」「`bk job log` は一部ジョブでハングする」等、ハマりどころと回避策を skill 内に蓄積している。

---

## 6. エージェント専用 CLI ツールの整備

CLAUDE.md は、エージェントが GitHub/CI を扱う際の **既製ツールの落とし穴を回避する自前スクリプト**へ誘導する:

- **`bun run ci:*`**(`scripts/find-build.ts`): `ci:errors` / `ci:status` / `ci:logs` / `ci:watch` / `ci:find`。BuildKite CLI(`bk`)の薄い presenter として、現在ブランチの失敗テストを `[new]` vs `[also on main]` 付きで提示。
- **`bun run pr:comments`**(`scripts/pr-comments.ts`): `gh pr view --comments` が **inline レビューコメントを黙って落とす** footgun を回避するため、`/issues`・`/pulls/reviews`・`/pulls/comments` の 3 エンドポイントを統合し時系列で出力。`--json` で jq 連携も可能。
- **`bun run rust:check-all`**: 全ターゲット(linux/macos/windows × x64/aarch64)で型チェック。`#[cfg(...)]` ガード下のコードは該当ターゲットを積まないと型検査されないため。
- **「壊れていたら回避せず直せ」**: 「これらの出力がおかしければ `scripts/find-build.ts` を直接直せ。回避するな。`bk` の薄いラッパなので正確に保て」と明記。エージェントにワークアラウンドではなくツール修正を促す。

---

## 7. AI 貢献のガバナンス

外部からの AI 生成 PR を運用前提で捌く仕組みも工夫点:

- **`auto-label-claude-prs.yml`**: `robobun`(自動化アカウント)の PR、または本文に「🤖 Generated with」を含む PR に `claude` ラベルを自動付与。
- **`on-slop.yml`**: PR に `slop` ラベルが付くと、定型コメント(「問題の実在を検証していない/修正をテストしていない/コードベースへの誤った仮定」等を指摘)を残し、タイトルを `ai slop` に書き換えて自動クローズ。**低品質 AI PR を排除するゲート**。
- **コミットの共著クレジット**: マージされたコミットには `Generated with Claude Code` や co-author `Claude Opus 4.7 (1M context)` が記録され、AI 関与を追跡可能にしている。

---

## 8. 設計思想としての学び

Bun の事例から抽出できる「Claude Code 活用の原則」:

1. **ガードレールはドキュメントではなくコードで強制する**。CLAUDE.md に書くだけでなく hooks で deny し、回避テクニックまで先回りで塞ぐ。
2. **決定論的な雑用はスクリプト化し、LLM には判断だけ任せる**。重複検出は LLM・クローズは cron スクリプト、という役割分担。
3. **検索・調査はマルチエージェントで並列化**し、別エージェントで偽陽性をフィルタする多段構成。
4. **冪等性をマーカーで担保**し、CI からの無人・反復実行に耐えるようにする。
5. **既製ツールの落とし穴を埋める自前ツールをエージェント向けに用意**し、「回避するな、ツールを直せ」と教える。
6. **正直さを契約に明記し、低品質 AI 成果物にはガバナンス(slop ゲート)で対処する**。
7. **失敗から学んだ規則を継続的に CLAUDE.md / hooks / skills へ蓄積**する(まさに knowledge が compound していく運用)。

> ⚠️ 要確認: 本ページは 2026-05-27 時点の `oven-sh/bun` main を基にした要約。CLAUDE.md と workflow は頻繁に改訂されるため、参照時点とのズレがありうる。

## 出典

- リポジトリ: https://github.com/oven-sh/bun
- CLAUDE.md: https://raw.githubusercontent.com/oven-sh/bun/main/CLAUDE.md
- hooks: `.claude/hooks/pre-bash-zig-build.js`, `.claude/hooks/post-edit-zig-format.js`, `.claude/settings.json`
- commands: `.claude/commands/{dedupe,find-duplicate-prs,find-issues,upgrade-nodejs,upgrade-webkit}.md`
- skills: `.claude/skills/*`(`.cursor/rules` から変換)
- workflows: `.github/workflows/{claude-dedupe-issues,claude-find-issues-for-pr,auto-close-duplicates,auto-label-claude-prs,on-slop}.yml`
- 主要スクリプト: `scripts/{find-build,pr-comments,auto-close-duplicates,ci-slowest-tests}.ts`(package.json の `ci:*` / `pr:comments`)

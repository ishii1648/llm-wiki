---
title: Backlog.md
type: entity
aliases: [Backlog.md, backlog, backlog-md, Backlog CLI]
tags: [task-management, cli, markdown, ai-agents, project-management]
created: 2026-07-16
updated: 2026-07-16
sources:
  - raw/articles/backlog-md-manifesto.md
  - raw/articles/backlog-md-task-example.md
  - raw/articles/backlog-md-cli-instructions.md
  - raw/articles/backlog-md-init-and-task-create.md
related:
  - "[[open-knowledge-format]]"
  - "[[backlog-md-vs-okf]]"
  - "[[knowledge-bundle]]"
---

## 概要

**Backlog.md** は、人間と AI エージェントの両方を第一級ユーザーとする Markdown ネイティブなタスク管理 CLI(npm パッケージ `backlog.md`)。スコープ・計画・受け入れ基準・進捗・成果を平文の Markdown ファイルとして `backlog/` ディレクトリに保持し、Git 管理下に置くことで人間にもエージェントにもレビュー可能な作業記録を作る(出典: `raw/articles/backlog-md-manifesto.md`)。CLI が唯一の正典(canonical)であり、TUI・ブラウザ・MCP はその上に乗るビュー/アダプタという位置づけ。

## 設計思想(マニフェスト)

- **人間とエージェントの両方が第一級ユーザー**: エージェントなしでも人間が作成・閲覧・修復できなければならない。自動化は前提条件にしてはならない。
- **コアループ**: `意図の把握 → スコープレビュー → 計画 → 計画レビュー → 実行 → 検証 → 記録の保存`。タスク Markdown のセクション構成(下記)はこのループをそのまま反映する。
- **信頼の源泉は人間可読な Markdown**: Git は履歴の証跡として有用だが必須ではない。内部ソースコードの API は実装詳細であり、統合面としては保証されない。
- **サーフェス階層**: CLI が正典 → CLI instructions が正規のエージェント向けワークフロー → TUI/ブラウザは同じセマンティクスの上のビュー → MCP はレガシーなオプションアダプタ(MCP ファースト設計は禁止)。
- **シンプルさが信頼を生む**: 証明されたニーズがない限り、層・エイリアス・互換レイヤーを追加しない。

(出典: `raw/articles/backlog-md-manifesto.md` 全体)

## タスク Markdown の形式

タスクは `backlog/tasks/<ID> - <タイトルのkebab-case>.md` というフラットなファイルとして保存される。実例(`BACK-547`)から確認できる構造(出典: `raw/articles/backlog-md-task-example.md`):

```markdown
---
id: BACK-547
title: Make TUI live refresh resilient to atomic writes
status: Done
assignee: [...]
created_date: '2026-07-14 19:59'
updated_date: '2026-07-14 22:03'
labels: []
dependencies: []
references: [...]
modified_files: [...]
priority: high
type: bug
ordinal: 194000
---

## Description
<!-- SECTION:DESCRIPTION:BEGIN --> ... <!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 ...
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN --> ... <!-- DOD:END -->

## Implementation Plan
<!-- SECTION:PLAN:BEGIN --> ... <!-- SECTION:PLAN:END -->

## Implementation Notes
<!-- SECTION:NOTES:BEGIN --> ... <!-- SECTION:NOTES:END -->

## Final Summary
<!-- SECTION:FINAL_SUMMARY:BEGIN --> ... <!-- SECTION:FINAL_SUMMARY:END -->
```

ポイント:

- **YAML frontmatter**: `id`/`status`/`assignee`/`dependencies`/`references`/`modified_files`/`priority`/`type`/`ordinal` などのメタデータ。`ordinal` は表示順を決める数値で、人間可読な ID(`BACK-547`)とは別軸。
- **`<!-- SECTION:xxx:BEGIN/END -->` コメントマーカー**: 各セクション本文を CLI が機械的に検出・書き換えるための境界。これにより CLI は正規表現的にセクションを安全に差し替えられる。直接編集は非推奨(CLI ガイドが明示的に禁止)。
- **`<!-- AC:BEGIN/END -->` / `<!-- DOD:BEGIN/END -->`**: チェックボックスは `#1`, `#2`... と番号付けされ、`backlog task edit --check-ac 1` のように番号で状態を操作する。
- **セクションはコアループのフェーズに対応**: Description/Acceptance Criteria(作成時)→ Implementation Plan(実行前)→ Implementation Notes(実行中)→ Final Summary(完了時)。

## `backlog init` で作られるディレクトリ構造

`backlog init "<Project Name>" --defaults` を実行すると、リポジトリルートに以下が作られる(出典: `raw/articles/backlog-md-init-and-task-create.md`、v1.48.0 で実地検証):

```
<repo root>/
├── AGENTS.md                 # エージェント向け指示書(backlog instructions overview の実行を強制)
└── backlog/
    ├── config.yml             # プロジェクト設定(task_prefix, statuses, date_format 等)
    ├── tasks/                 # アクティブなタスク(作成〜完了直後まではここ)
    ├── drafts/                # ドラフト(まだ確定していない下書きタスク)
    ├── docs/                  # ドキュメント
    ├── decisions/             # 決定記録(ADR相当)
    ├── milestones/            # マイルストーン
    ├── completed/             # 完了後、定期クリーンアップで移動されたタスクの置き場
    └── archive/
        ├── tasks/             # 明示的にアーカイブしたタスク
        ├── drafts/
        └── milestones/
```

`tasks/` と `completed/` は別物である点に注意: Done になったタスクは即座に移動せず、**しばらく `tasks/` に残り、定期クリーンアップ(一定期間経過後)で `completed/` に移される**(出典: `raw/articles/backlog-md-cli-instructions.md` の task-finalization ガイド「Tasks in the terminal status stay there until periodic cleanup moves them to completed. Do not archive completed work.」)。`archive/` は「もうやらないと決めた」タスク/ドラフト/マイルストーンをしまう、`completed/` とは異なる概念。

`config.yml` の主なフィールド: `project_name`, `default_status`, `statuses`(配列), `task_prefix`(ID接頭辞、プロジェクト名から自動決定), `date_format`, `remote_operations` 等。

`backlog task create` で新規ファイルが `backlog/tasks/` 直下に作られる際、`--ac` フラグをカンマ区切り文字列で複数条件のつもりで渡しても分割されず1項目になる(検証済みの落とし穴)。複数条件は `--ac "条件1" --ac "条件2"` のようにフラグを繰り返す必要がある。

## CLI ワークフロー(instructions)

Backlog.md は「CLI instructions が正規のエージェント向けワークフロー」という原則のもと、`backlog instructions <name>` で4段階のガイドを提供する(出典: `raw/articles/backlog-md-cli-instructions.md`):

1. **overview** — 「計画や意思決定が要るか」でタスク化の要否を判断させ、検索優先(`backlog search`, `backlog task list --status ...`)を指示。
2. **task-creation** — 既存タスクの検索 → スコープ判断(1PRで収まるか)→ サブタスク/依存タスクの選択 → 将来作業には**実装計画を書かせない**(計画は着手時に現在のコードベースを調査して記録する、というのが明示ルール)。
3. **task-execution** — 着手前に `-s <active status> -a @name` でステータス/担当を更新 → 現在のシステムを調査 → 計画を `--plan` で記録 → 実装は短いループ(実装→テスト→`--append-notes`)。
4. **task-finalization** — 客観的な検証証拠(テスト・コマンド出力・手動確認)なしに受け入れ基準をチェックしない → `--check-ac`/`--check-dod` → `--final-summary` → 終端ステータスへ変更。フォローアップタスクはユーザー承認なしに作らない。

一貫する原則: **Backlog の Markdown ファイルを直接編集せず、必ず CLI コマンド経由で操作する**(メタデータ・ファイル名・関連性・履歴の整合性を保つため)。

## 出典

- `raw/articles/backlog-md-manifesto.md` — 製品哲学、第一級ユーザー、コアループ、サーフェス階層、境界。
- `raw/articles/backlog-md-task-example.md` — タスク Markdown の実例(BACK-547、frontmatter・セクションマーカー・AC番号付けの実物)。
- `raw/articles/backlog-md-cli-instructions.md` — `backlog instructions` の4ガイド全文(overview/task-creation/task-execution/task-finalization)。
- `raw/articles/backlog-md-init-and-task-create.md` — `backlog init`/`backlog task create` の実地検証ログ(ディレクトリツリー・config.yml・生成ファイル・落とし穴)。

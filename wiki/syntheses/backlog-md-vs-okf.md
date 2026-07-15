---
title: Backlog.md のタスク Markdown は OKF 準拠か
type: synthesis
aliases: [Backlog.md vs OKF, Backlog.md OKF compliance, Backlog.md OKF準拠]
tags: [task-management, knowledge-representation, comparison, specification]
created: 2026-07-16
updated: 2026-07-16
sources:
  - raw/articles/backlog-md-task-example.md
  - raw/articles/backlog-md-manifesto.md
  - raw/articles/okf-spec.md
related:
  - "[[backlog-md]]"
  - "[[open-knowledge-format]]"
  - "[[okf-and-llm-wiki]]"
---

## 概要

[[backlog-md|Backlog.md]] のタスク Markdown(`backlog/tasks/*.md`)は、YAML frontmatter + Markdown 本文という表面的な形式は [[open-knowledge-format|OKF]] と一致するが、**OKF を意図して設計されたものではなく、フィールド構成もセマンティクスも異なる**。結論として「OKF準拠」とは言えない。

両者の関係性そのもの(OKF と LLM Wiki パターンの系譜)については [[okf-and-llm-wiki]] を参照。あちらが「この wiki リポジトリ」対 OKF の比較であるのに対し、本ページは「タスク管理ツール Backlog.md が生成する Markdown」対 OKF という別の被検体の比較である。

## 比較表

| 項目 | OKF v0.1(`raw/articles/okf-spec.md`) | Backlog.md タスク Markdown |
|---|---|---|
| 必須フィールド(§4.1) | `type` のみ | `id`, `title`, `status` など CLI が要求する多数のフィールド |
| frontmatter 区切り(§4) | `---` ... `---` | 同じ(一致) |
| `description`(§4.1、推奨) | frontmatter 内の1行要約フィールド | frontmatter には無く、本文の `<!-- SECTION:DESCRIPTION:BEGIN/END -->` ブロック |
| `tags`(§4.1、推奨) | 予約フィールド名 | `labels`(別名。意味は近いが名前不一致) |
| `timestamp`(§4.1、推奨) | 単一の最終更新 ISO 8601 フィールド | `created_date` / `updated_date` に分割、独自フォーマット(`'2026-07-14 19:59'`) |
| `resource`(§4.1、推奨) | 対象アセットへの正規URI | 存在しない |
| `type` の意味(§4.1) | concept の分類(例: `BigQuery Table`, `Metric`) | タスク種別(`bug`/`feature`など)— フィールド名は同じだが意味は別物 |
| ステータス管理系フィールド | 未規定(producer拡張として許容) | `status`, `assignee`, `dependencies` が中核フィールド |
| 本文セクション見出し(§4.2) | 規定なし。`# Schema`/`# Examples`/`# Citations` は慣習として推奨 | `<!-- SECTION:X:BEGIN/END -->` という Backlog.md 独自の機械可読コメントマーカーを使用 |
| Permissive consumption(§9) | 未知フィールド・未知 `type` 値・壊れたリンクを理由に拒否してはならない(MUST NOT) | 直接編集を明示的に禁止し、CLI経由の変更のみを許容 —— 設計思想が逆方向(寛容さより整合性を優先) |
| `okf_version` 宣言(§11) | ルート `index.md` frontmatter で宣言 | 該当する仕組みなし |
| 予約ファイル名(§3.1) | `index.md`, `log.md` | 未使用。`<ID> - <タイトル>.md` 形式でフラットに配置 |

## 結論

- OKF が唯一必須とする「非空の `type` フィールド + `---` 区切り frontmatter」(§4.1)という条件だけを見れば、Backlog.md のタスクファイルは `type: bug` を持つため**たまたま**満たしてしまう。
- しかし OKF が推奨する `description`/`tags`/`timestamp`/`resource` のセマンティクス(§4.1)には従っておらず、`type` フィールド自体の意味も違う(concept分類 vs タスク種別)。`okf_version` 宣言(§11)もない。
- Backlog.md はサーフェス階層原則(「CLIが正典」)とシンプルさ優先の原則([[backlog-md]] 参照)に基づき独自に Markdown 形式を設計しており、OKF を参照・準拠する設計にはなっていない。
- したがって両者は独立に「YAML frontmatter + Markdown」という一般的なパターンを採用しているだけで、Backlog.md のタスク形式を「OKF準拠」と呼ぶのは不正確。

## 出典

- `raw/articles/okf-spec.md` §3.1(予約ファイル名), §4.1(frontmatter), §9(permissive consumption), §11(versioning)
- `raw/articles/backlog-md-task-example.md`(実例 BACK-547 の frontmatter・セクション構造)
- `raw/articles/backlog-md-manifesto.md`(サーフェス階層・シンプルさ優先の設計原則)

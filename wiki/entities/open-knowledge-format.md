---
title: Open Knowledge Format (OKF)
type: entity
aliases: [OKF, Open Knowledge Format]
tags: [knowledge-representation, metadata, ai-agents, markdown, google-cloud, specification]
created: 2026-06-19
updated: 2026-06-19
sources:
  - raw/articles/okf-spec.md
related:
  - "[[knowledge-bundle]]"
  - "[[okf-and-llm-wiki]]"
---

## 概要

**Open Knowledge Format(OKF)** は、データやシステムを取り巻く*知識* — メタデータ・コンテキスト・キュレーションされた洞察 — を表現するための、人間にもエージェントにも扱いやすいオープンフォーマット。Google Cloud の Data Analytics Engineering チーム(Sam McVeety, Amir Hormati)が提唱し、現在は **v0.1(Draft)**。

形式は意図的に最小限で、**YAML frontmatter 付き markdown ファイルのディレクトリ**にすぎない。スキーマレジストリも中央権威も必須ツールも存在しない。「`cat` できれば OKF は読めるし、`git clone` できれば配布できる」(出典: `raw/articles/okf-spec.md`)。

> OKF は本質的に [[okf-and-llm-wiki|Karpathy の LLM Wiki パターン]]を仕様として固めたものであり、この llm-wiki リポジトリ自体がその一実装にあたる。spec §10 が LLM "wiki" リポジトリ・Obsidian/Notion・"metadata as code" を近縁パターンとして挙げている。

## 設計思想

OKF が標準化するのは、知識コーパスを*自己記述的(self-describing)*にするために必要な最小限の構造的取り決めだけ。それ以外は producer に委ねる。フォーマットが目指すのは知識が次であること(出典: `raw/articles/okf-spec.md` §1):

- **Readable** — ツールなしで人間が読める。
- **Parseable** — 専用 SDK なしでエージェントが解析できる。
- **Diffable** — バージョン管理で差分が取れる。
- **Portable** — ツール・組織・時間を越えて持ち運べる。

### Goals / Non-goals

- Goals: enrichment agent が書き込める普遍フォーマットの定義 / consumption agent の読み方・走査の指針 / システム・組織を越えた知識の交換 / 意味ある消費に必要な**必須フィールドの最小集合**の標準化。
- Non-goals: 概念タイプの固定タクソノミー定義 / 保存・配信・クエリ基盤の規定 / ドメイン固有スキーマ(Avro, Protobuf, OpenAPI 等)の置き換え。OKF はそれらを*参照*するだけで包含しない。

## Frontmatter フィールド

各 concept ドキュメントは frontmatter + body から成る([[knowledge-bundle]] を参照)。frontmatter のフィールドは以下(出典: `raw/articles/okf-spec.md` §4.1):

| フィールド | 必須 | 役割 |
|---|---|---|
| `type` | **REQUIRED** | concept の種類を表す短い文字列(例: `BigQuery Table`, `Metric`, `Playbook`)。routing/filter/表示に使う。中央登録はされない。 |
| `title` | 推奨 | 人間向け表示名。省略時 consumer はファイル名から導出してよい。 |
| `description` | 推奨 | 1文の要約。index 生成・検索スニペット・プレビューで使う。 |
| `resource` | 推奨 | 対象アセットを一意に示す URI。抽象概念には無いこともある。 |
| `tags` | 推奨 | 横断的分類のための短い文字列リスト。 |
| `timestamp` | 推奨 | 最終更新の ISO 8601 日時。 |

producer は任意の追加キーを付与してよく、consumer は未知キーを保持し、未知フィールドを理由にドキュメントを拒否してはならない。

## Permissive consumption(寛容な消費)

OKF の核となる原則。consumer は次を理由にバンドルを拒否しては **ならない**(MUST NOT)(出典: `raw/articles/okf-spec.md` §9):

- 省略された任意 frontmatter フィールド
- 未知の `type` 値
- 未知の追加 frontmatter キー
- 壊れた cross-link(まだ書かれていない知識を表すだけ)
- 欠損した `index.md`

この寛容さは意図的なもので、バンドルが成長・リファクタ・エージェントによる部分生成を経ても有用であり続けるための設計。

## バージョニング

`<major>.<minor>` 形式。minor は後方互換な追加(任意フィールド・慣習的見出しの追加)、major は破壊的変更(必須フィールド改名・予約ファイル名変更)。バンドルは root の `index.md` frontmatter に `okf_version: "0.1"` を宣言してよい(index.md に frontmatter が許される唯一の場所)(出典: `raw/articles/okf-spec.md` §11)。

## エコシステム(外部情報)

spec 原本には含まれないが、発表ブログ(下記出典)で言及された周辺要素:

- **Google Cloud Knowledge Catalog** が OKF 形式を ingest し、Google Cloud エコシステム内でエージェントへ OKF を提供できるよう更新された。
- **Reference implementations**: BigQuery データセットを走査して引用・スキーマ・join path 付き OKF ドキュメントを起こす enrichment agent(producer)と、任意の OKF バンドルをインタラクティブなグラフビューで描画する自己完結 HTML visualizer(consumer)。
- **Sample bundles**: GA4 e-commerce / Stack Overflow / Bitcoin の公開データセット例。

## 出典

- 仕様本体: `raw/articles/okf-spec.md`(GoogleCloudPlatform/knowledge-catalog, `okf/SPEC.md`, Apache-2.0)
- 発表ブログ(エコシステム・作者・公開日 2026-06-13 の根拠): https://cloud.google.com/blog/products/data-analytics/how-the-open-knowledge-format-can-improve-data-sharing
- GitHub リポジトリ: https://github.com/GoogleCloudPlatform/knowledge-catalog/tree/main/okf

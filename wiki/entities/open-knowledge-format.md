---
title: Open Knowledge Format (OKF)
type: entity
aliases: [OKF, Open Knowledge Format]
tags: [knowledge-representation, metadata, ai-agents, markdown, google-cloud, specification]
created: 2026-06-19
updated: 2026-07-01
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

### Body(本文)の慣習見出し

body は標準 markdown。producer は自由記述の散文より**構造的 markdown**(見出し・リスト・表・fenced code block)を優先すべき —— 構造は人間の読解にもエージェントの retrieval にも効くため。必須の本文セクションは無いが、以下の見出しは**慣習的(conventional)**な意味を持ち、該当時は使うべき(出典: `raw/articles/okf-spec.md` §4.2)。

| 見出し | 用途 |
|---|---|
| `# Schema` | アセットの列/フィールドの構造的記述。 |
| `# Examples` | 具体的な利用例(多くは fenced code block)。 |
| `# Citations` | body の主張を裏付ける外部ソース(§8。番号付きリスト、末尾に置く)。 |

## Cross-linking(相互リンク)

concept 間は標準 markdown リンクで結ぶ。2 形式がある(出典: `raw/articles/okf-spec.md` §5):

- **絶対(バンドル相対)リンク** — `/` で始まりバンドル root からの相対で解釈。`[customers table](/tables/customers.md)` のように書く。サブディレクトリ内でドキュメントを移動しても壊れにくいため**こちらが推奨**。
- **相対リンク** — `./other.md` のような通常の markdown 相対パス。

リンクの**意味論**: A→B のリンクは「関係がある」ことだけを主張し、関係の種類(parent/child, references, joins-with, depends-on…)は**周囲の散文が伝える**(リンク自体は型を持たない)。グラフビューを作る consumer は通常すべてのリンクを「型なし関係の有向辺」として扱う。

> consumer は**壊れたリンクを許容しなければならない**(MUST)—— バンドル内に存在しない対象へのリンクは不正ではなく、「まだ書かれていない知識」を表すだけかもしれない。これは llm-wiki の `scripts/lint.sh` が dangling link を検出する方針とは対照的(本 wiki は追加の厳格さを課している。→ [[okf-and-llm-wiki]])。

## 予約ファイル名(reserved filenames)

階層の任意のレベルで、以下のファイル名は定められた意味を持ち concept ドキュメントに**使ってはならない**(MUST NOT)(出典: `raw/articles/okf-spec.md` §3.1, §6, §7)。それ以外の `.md` はすべて concept。

| ファイル名 | 用途 |
|---|---|
| `index.md` | ディレクトリの内容列挙。progressive disclosure(個別を開く前に一覧を見せる)用。frontmatter は持たない(唯一の例外は root の `okf_version` 宣言)。各エントリは `* [Title](url) - description` 形式で、リンク先 frontmatter の `description` を含めるべき。 |
| `log.md` | 変更履歴。`## YYYY-MM-DD`(ISO 8601)見出しで新しい順にグルーピングし、各行は `**Update**` / `**Creation**` / `**Deprecation**` 等の太字語(慣習であり必須ではない)で始まる散文。 |

## Conformance(準拠条件)

バンドルが OKF v0.1 に**準拠する**のは次を満たすとき(出典: `raw/articles/okf-spec.md` §9):

1. tree 内のすべての非予約 `.md` が、解析可能な YAML frontmatter ブロックを持つ。
2. すべての frontmatter が**空でない `type` フィールド**を持つ。
3. 予約ファイル名(`index.md`, `log.md`)は、存在する場合それぞれ §6 / §7 の構造に従う。

上記以外の制約はすべて soft guidance。とりわけ consumer は次を理由にバンドルを拒否しては **ならない**(MUST NOT):

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

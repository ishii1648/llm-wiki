---
title: Knowledge Bundle(OKF のバンドル構造)
type: concept
aliases: [Knowledge Bundle, OKF bundle, concept document]
tags: [knowledge-representation, markdown, specification, structure]
created: 2026-06-19
updated: 2026-06-19
sources:
  - raw/articles/okf-spec.md
related:
  - "[[open-knowledge-format]]"
  - "[[okf-and-llm-wiki]]"
---

## 概要

**Knowledge Bundle** は [[open-knowledge-format|OKF]] における**配布の単位**。markdown ファイルから成るディレクトリツリーで、自己完結した階層的な知識ドキュメントの集合。各ファイルは 1 つの **concept**(知識の単位)を表す。ディレクトリ構造はドメインから独立しており、producer が捉えたい知識に合わせて自由に組める(出典: `raw/articles/okf-spec.md` §3)。

配布形態は git リポジトリ(履歴・帰属・差分が得られるため推奨)、tarball/zip、より大きなリポジトリ内のサブディレクトリのいずれでもよい。

## 用語

- **Concept** — バンドル内の知識 1 単位。1 markdown ドキュメント。テーブルや API のような実体、metric やビジネスプロセスのような抽象、その中間のいずれも表せる。
- **Concept ID** — バンドル内でのファイルパスから `.md` を除いたもの(例: `tables/users.md` → `tables/users`)。
- **Frontmatter** / **Body** — 先頭の YAML メタデータブロックと、それ以降の本文。
- **Link** — concept 間の標準 markdown リンク。暗黙の親子階層を越えた関係を表す。
- **Citation** — body 中の主張を裏づける外部ソースへのリンク。

## 予約ファイル名

階層のどのレベルでも特別な意味を持ち、concept ドキュメントに使ってはならない(出典: `raw/articles/okf-spec.md` §3.1):

| ファイル名 | 用途 |
|---|---|
| `index.md` | ディレクトリ一覧(progressive disclosure)。 |
| `log.md` | 更新履歴。 |

それ以外の `.md` はすべて concept ドキュメント。

## Concept ドキュメントの本文

body は標準 markdown。freeform の散文より、見出し・リスト・テーブル・コードブロックといった**構造的 markdown** が推奨される(人間の読みやすさとエージェントの retrieval の双方を助けるため)。必須セクションは無いが、慣習的な意味を持つ見出しがある(出典: `raw/articles/okf-spec.md` §4.2):

| 見出し | 用途 |
|---|---|
| `# Schema` | アセットのカラム/フィールドの構造的記述。 |
| `# Examples` | 具体的な利用例(多くはコードブロック)。 |
| `# Citations` | body の主張を裏づける外部ソース。 |

## Cross-linking

concept 間は標準 markdown リンクで結ぶ。2 形式がある(出典: `raw/articles/okf-spec.md` §5):

- **Absolute(bundle-relative)**: `/` 始まりで bundle root 基準。サブディレクトリ内で移動しても安定するため**推奨**。
- **Relative**: 通常の相対パス(`./other.md`)。

リンク A→B は*関係*を表明するだけで、関係の種類(parent/child, references, joins-with, depends-on 等)はリンク自体ではなく周囲の散文が伝える。consumer は通常すべてのリンクを無型の有向エッジとして扱う。**壊れたリンクは不正ではなく**、まだ書かれていない知識を表すことがあるため consumer は許容しなければならない。

## Index と Log

- **`index.md`**(§6): 任意のディレクトリに置け、内容を列挙して progressive disclosure を支える。frontmatter は持たない(例外は §11 のバージョン宣言)。各エントリは概念の `description` を含むのが望ましい。producer が自動生成しても、consumer がその場で合成してもよい。
- **`log.md`**(§7): 任意階層で変更履歴を記録。新しい順の日付グループ(ISO 8601 `YYYY-MM-DD`)。先頭の太字(`**Update**`/`**Creation**`/`**Deprecation**` 等)は慣習であり必須ではない。

## Citations

body が外部素材に由来する主張をする場合、末尾の `# Citations` 見出しの下に番号付きで列挙する。リンクは絶対 URL・bundle-relative パス・外部素材を first-class concept として写した `references/` サブディレクトリへのパスのいずれでもよい(出典: `raw/articles/okf-spec.md` §8)。

## Conformance(適合条件)

バンドルが OKF v0.1 に**適合**するのは次のとき(出典: `raw/articles/okf-spec.md` §9):

1. ツリー内の非予約 `.md` ファイルがすべて解析可能な YAML frontmatter を持つ。
2. すべての frontmatter が空でない `type` フィールドを持つ。
3. 予約ファイル名(`index.md`, `log.md`)が存在する場合、それぞれ §6/§7 の構造に従う。

その他の制約はすべて soft guidance であり、consumer は [[open-knowledge-format#Permissive consumption（寛容な消費）|permissive consumption]] に従う。

## 出典

- `raw/articles/okf-spec.md`(GoogleCloudPlatform/knowledge-catalog, `okf/SPEC.md`, Apache-2.0)§2–§9

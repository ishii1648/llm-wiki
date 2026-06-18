---
title: OKF とこの llm-wiki リポジトリの関係
type: synthesis
aliases: [OKF vs LLM Wiki, OKF and llm-wiki]
tags: [knowledge-representation, llm-wiki, comparison, specification, meta]
created: 2026-06-19
updated: 2026-06-19
sources:
  - raw/articles/okf-spec.md
related:
  - "[[open-knowledge-format]]"
  - "[[knowledge-bundle]]"
---

## 概要

[[open-knowledge-format|OKF]] と、この llm-wiki リポジトリは**同じ系譜**に属する。両者とも Andrej Karpathy の **LLM Wiki パターン**(markdown + frontmatter をエージェント可読の知識ベースとして使う発想)に由来し、OKF spec §10 自身が「LLM "wiki" リポジトリ」を近縁パターンの筆頭に挙げている(出典: `raw/articles/okf-spec.md` §10)。

> つまり OKF は、この CLAUDE.md が定めるローカル運用スキーマを、組織を越えた交換のために**仕様として固めた**もの。この repo は OKF の一実装(あるいは方言)とみなせる。

参照元 gist: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

## 対応関係

| この repo(CLAUDE.md スキーマ) | OKF v0.1 | 備考 |
|---|---|---|
| `wiki/` 配下の markdown ページ群 | Knowledge Bundle = markdown のディレクトリツリー | 構造は一致([[knowledge-bundle]]) |
| YAML frontmatter(`title`/`type`/`tags`/`created`/`updated`/`sources`/`related`) | frontmatter(`type` のみ必須、`title`/`description`/`resource`/`tags`/`timestamp` 推奨) | この repo は `type` を必須運用しており **OKF 適合的** |
| `[[ページ名]]`(Obsidian 互換 wikilink) | 標準 markdown リンク(`/path.md` bundle-relative 推奨) | **リンク記法が異なる**(下記の差分) |
| `wiki/index.md`(カタログ) | `index.md`(progressive disclosure、予約ファイル名) | 役割は一致 |
| `wiki/log.md`(追記専用ログ、`## [YYYY-MM-DD]` prefix) | `log.md`(予約、ISO 8601 日付グループ、新しい順) | 役割は一致。日付表記の慣習は近い |
| `sources:` frontmatter + `wiki/sources.md` 台帳 | `# Citations` セクション / `references/` サブディレクトリ | 出典の紐づけ思想は共通 |
| entities / concepts / syntheses のサブディレクトリ | ドメイン自由なディレクトリ構造 | OKF は固定タクソノミーを定めない(non-goal) |

## 主な差分

1. **リンク記法**: この repo は frontmatter に正規 ID を持つ Obsidian 互換 `[[name]]` を使う。OKF は拡張子付きの標準 markdown リンク(`/tables/customers.md`)を推奨する。OKF バンドルとして配布するなら wikilink → bundle-relative パスへの変換が要る。
2. **frontmatter の必須度**: OKF は `type` のみ必須で極めて寛容([[open-knowledge-format#Permissive consumption（寛容な消費）|permissive consumption]])。この repo は `sources`(出典)を実質必須とし、lint.sh で出典 raw パスの実在・リンク切れ・孤立を機械チェックしており、**OKF より厳格**。
3. **壊れたリンクの扱い**: OKF は broken link を「未到達知識」として許容する。この repo の lint はリンク切れを問題として検出する — 運用ポリシーが逆方向。

## 含意

- この wiki を OKF バンドルとして**エクスポート**するのは比較的容易(frontmatter は概ね適合、`index.md`/`log.md` も既存)。主な作業は `[[...]]` → bundle-relative リンクへの変換と、`description` フィールドの付与。
- 逆に外部の OKF バンドルを ingest する場合、`type` 以外が欠けていても拒否しない OKF の寛容さと、この repo の厳格な lint の差を埋める正規化が必要になる。

## 出典

- `raw/articles/okf-spec.md` §10(近縁パターン), §4(frontmatter), §5(リンク), §6/§7(index/log), §9(conformance)
- この repo の `CLAUDE.md` 運用スキーマ(リポジトリ内定義)

---
title: Domain Modeling(Claude Code スキル)
type: concept
aliases: [domain-modeling]
tags: [claude-code-skills, ddd, adr, ubiquitous-language]
created: 2026-07-12
updated: 2026-07-12
sources:
  - raw/articles/mattpocock-domain-modeling-skill.md
related:
  - "[[matt-pocock]]"
  - "[[grill-with-docs]]"
  - "[[grilling]]"
  - "[[design-doc]]"
---

## 概要

プロジェクトのドメインモデル(用語集・アーキテクチャ決定)を設計しながら能動的に構築・研ぎ澄ませる [[matt-pocock]] の Claude Code スキル。`CONTEXT.md` を読んで語彙を参照するだけの受動的な行為とは区別される「能動的」な規律で、モデルを変更している時に使う。単独でも呼べるが、[[grill-with-docs]] から利用される形が主。

## ファイル構成

単一コンテキストのリポジトリ:

```
/
├── CONTEXT.md
├── docs/adr/0001-xxx.md, 0002-xxx.md ...
└── src/
```

ルートに `CONTEXT-MAP.md` がある場合は複数コンテキストが存在し、各コンテキストが個別の `CONTEXT.md` と `docs/adr/` を持つ(システム全体の決定はルートの `docs/adr/` に)。ファイルは**遅延生成**: 最初に確定した用語が出るまで `CONTEXT.md` を作らず、最初の ADR が必要になるまで `docs/adr/` を作らない。

## セッション中の振る舞い

- **用語集との突き合わせ**: ユーザーの用語が `CONTEXT.md` の既存語彙と矛盾したら即座に指摘する。
- **曖昧な語の研ぎ澄まし**: 曖昧・多義的な語には、より精密な正準用語を提案する(例:「account」は Customer か User か)。
- **具体シナリオでの議論**: ドメイン関係を議論する際、エッジケースを突く具体的シナリオを作って境界を明確にさせる。
- **コードとの突き合わせ**: ユーザーの説明とコードの実際の動作に矛盾がないか確認し、あれば指摘する。
- **`CONTEXT.md` の即時更新**: 用語が確定したその場で書き込む(まとめて後回しにしない)。`CONTEXT.md` は用語集専用で、実装詳細・仕様・作業メモの置き場にはしない。

## ADR を作る基準

以下の3条件が**すべて**揃った時のみ ADR 作成を提案する(1つでも欠けたらスキップ):

1. **覆しにくい(hard to reverse)** — 後で気が変わるコストが無視できない
2. **文脈なしでは意外(surprising without context)** — 将来の読者が「なぜこうしたのか」と疑問に思う
3. **本物のトレードオフの結果** — 実在する代替案があり、特定の理由でそれを選んだ

## 出典

- raw/articles/mattpocock-domain-modeling-skill.md — `github.com/mattpocock/skills`(MIT)の SKILL.md 原文

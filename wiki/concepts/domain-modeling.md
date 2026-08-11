---
title: Domain Modeling(Claude Code スキル)
type: concept
aliases: [domain-modeling]
tags: [claude-code-skills, ddd, adr, ubiquitous-language]
created: 2026-07-12
updated: 2026-08-11
sources:
  - raw/articles/mattpocock-domain-modeling-skill.md
related:
  - "[[matt-pocock]]"
  - "[[grill-with-docs]]"
  - "[[grilling]]"
  - "[[design-doc]]"
  - "[[ai-dlc]]"
  - "[[intent-unit-bolt]]"
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

## 対照: AI-DLC の ADR 生成
[[ai-dlc]] も Construction フェーズで AI に ADR を書かせるが、**生成のトリガが異なる**。本スキルは上記3条件が揃った時のみ ADR を提案する(人間の判断がトリガ)のに対し、AI-DLC は Domain Design → Logical Design の**段階遷移そのものをトリガ**とし、NFR 対応のアーキテクチャパターン選択(CQRS、Circuit Breaker 等)を ADR として必ず記録させる(→ [[intent-unit-bolt]])。前者は ADR の希少性を保ち、後者は網羅性を取る設計。

AI-DLC が DDD を方法論のコアに内蔵する(原則3)理由——「AI に何を生成させるかを決めるには、生成物の型が事前に定まっている必要がある」——は、本スキルが `CONTEXT.md` の用語集を能動的に構築する動機と同じ地点にある。

## 出典

- raw/articles/mattpocock-domain-modeling-skill.md — `github.com/mattpocock/skills`(MIT)の SKILL.md 原文

---
title: Grilling(/grill-me)
type: concept
aliases: [grill-me, /grill-me, grilling]
tags: [claude-code-skills, planning, ai-engineering]
created: 2026-07-12
updated: 2026-07-12
sources:
  - raw/articles/mattpocock-grilling-skill.md
  - raw/articles/mattpocock-grill-me-skill.md
related:
  - "[[matt-pocock]]"
  - "[[grill-with-docs]]"
  - "[[domain-modeling]]"
  - "[[agent-skills]]"
  - "[[design-doc]]"
---

## 概要

コードを書く前に、エージェントに計画・設計を**関連する質問攻めにさせて**、合意形成(shared understanding)に達するまで詰める Claude Code スキル。[[matt-pocock]] の `mattpocock/skills` リポジトリ(MIT)に収録されている `grilling` スキルが本体で、`/grill-me` はそれを呼び出す薄いラッパー。

## 仕組み

`grilling` スキル本文([[matt-pocock]] の `mattpocock/skills` より、`disable-model-invocation: true` でユーザーが明示的に `/grill-me` を打った時のみ起動、エージェントが自発的には使わない):

- 計画のあらゆる側面について、共通理解に至るまで**関連する質問攻め**にする。設計ツリーの各枝を1つずつ、決定間の依存関係を解決しながら降りていく。
- 各質問には**エージェント自身の推奨解答**を添える。
- 質問は**1問ずつ**。前の質問へのフィードバックを待ってから次へ進む。「一度に複数質問すると混乱する」ため。
- コードベースを探索すれば分かる**事実**は、ユーザーに聞かずに自分で調べる。一方で**決定(decision)はユーザーのもの**であり、都度提示して回答を待つ。
- ユーザーと共通理解に至るまで、計画を実行(コード化)しない。

## /grill-me と /grill-with-docs の違い

- `/grill-me`: 上記の grilling セッションのみ。会話が終われば決定はセッション内(またはユーザーのメモ)にしか残らない。
- `/grill-with-docs`(→ [[grill-with-docs]]): 同じ grilling に加えて [[domain-modeling]] スキルを併用し、解決した用語を `CONTEXT.md`、覆しにくい決定を ADR として**その場で**ファイルに書き残す。

## よくある誤用(ブログ記事より)

> ⚠️ 出典注記: このセクションは著作権記事 https://www.aihero.dev/things-people-get-wrong-with-grill-me-and-grill-with-docs の要旨(ツールによる要約)に基づく。全文は著作権のため raw/ に保存していない。記事タイトルは「9つ」を謳うが、取得できた要旨からは以下の項目のみ確認できた(記事全文は未確認、取得漏れの可能性あり)。

1. **高忠実度(high-fidelity)な質問を無理に grill 中に答えようとしない**: 議論だけで答えられる低忠実度の質問と、プロトタイプが要る高忠実度の質問を区別する。後者は「grill → プロトタイピング → 再度 grill」というハンドオフで扱う。
2. **スコープを大きくしすぎない**: スコープが大きいと (a) 計画を先まで進めるほど隠れていた高忠実度の質問が表面化する、(b) grilling セッションが長くなり ~120k トークン付近のモデルの "dumb zone" で判断品質が落ちる。大きなプロジェクトは個別に grill 可能な小さな単位へ分割する。
3. **受け身にならない**: grilling は尋問ではなく会話。ユーザー側が能動的に議論の方向を決め、計画から実装へ移るタイミングを見極める必要がある。
4. **設計の成果を失わない**: セッションで生まれた決定は、その場で実装するか、`/2PRD` スキルで PRD 化してから context をクリアする。
5. **モデル選択**: grilling には創造的な提案ができる「賢いモデル」(強いパラメトリック知識)が要る。実装フェーズは、情報の大半がコードベースや詳細な計画などコンテキスト由来になるため、より小さいモデルでも良い。
6. **並列 grilling セッション**: 複数セッションを並行して回すとスループットが上がる。多くの人は 2 セッション程度なら無理なく並行できる。

## 出典

- raw/articles/mattpocock-grilling-skill.md, mattpocock-grill-me-skill.md — `github.com/mattpocock/skills`(MIT)の SKILL.md 原文
- https://www.aihero.dev/things-people-get-wrong-with-grill-me-and-grill-with-docs — ブログ本文(要旨のみ、raw 未保存)

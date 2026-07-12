---
title: grill-with-docs
type: concept
aliases: [/grill-with-docs]
tags: [claude-code-skills, planning, ai-engineering, ddd]
created: 2026-07-12
updated: 2026-07-12
sources:
  - raw/articles/mattpocock-grill-with-docs-skill.md
  - raw/articles/mattpocock-domain-modeling-skill.md
related:
  - "[[matt-pocock]]"
  - "[[grilling]]"
  - "[[domain-modeling]]"
  - "[[design-doc]]"
---

## 概要

[[grilling]]([[matt-pocock]] の `/grill-me`)に [[domain-modeling]] スキルを組み合わせた Claude Code スキル。関連する質問攻めで計画を詰めるだけでなく、解決した用語を `CONTEXT.md` の用語集(glossary)に、覆しにくい決定を ADR として**セッション中に随時**書き残す。会話が終わっても合意内容が記憶ではなくファイルに残る。

## いつ使うか

変更に着手する最初期、計画がまだ曖昧でドメイン用語も定まっていない段階で、コードを書く前に両方をストレステストしたいときに使う。`disable-model-invocation: true` が設定されており、エージェントが自発的に選ぶことはなく、ユーザーが明示的に `/grill-with-docs` と打った時のみ起動する。

## 仕組み

`grill-with-docs` の SKILL.md 本体はごく薄いラッパーで、実質的な指示は「`/grilling` セッションを、`/domain-modeling` スキルを使って実行せよ」の1行のみ。実際の挙動は [[grilling]] の質問攻めルール(1問ずつ・推奨解答を添える・事実はコードベースを調べる・決定はユーザーに委ねる)と、[[domain-modeling]] の用語集/ADR 運用の合成で決まる。

## 出典

- raw/articles/mattpocock-grill-with-docs-skill.md — `github.com/mattpocock/skills`(MIT)の SKILL.md 原文
- raw/articles/mattpocock-domain-modeling-skill.md — 同リポジトリ、参照される domain-modeling スキル本体
- https://www.aihero.dev/things-people-get-wrong-with-grill-me-and-grill-with-docs — 用途・位置づけの補足(要旨のみ、raw 未保存)

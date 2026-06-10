---
title: Addy Osmani
type: entity
aliases: [Addy Osmani, addyosmani]
tags: [person, author, agentic-development, software-engineering]
created: 2026-06-10
updated: 2026-06-10
sources:
  - raw/articles/loop-engineering.md
related:
  - "[[loop-engineering]]"
---

## 概要
**Addy Osmani(アディ・オスマニ)** は、agentic development(エージェント駆動開発)とコーディングエージェントの運用について継続的に論じるブロガー/エンジニア。本 wiki では彼のブログ記事 "[[loop-engineering]]"(2026-06-07)を ingest しており、本ページはその著者ハブ。

> ⚠️ 出典の範囲: 本ページの記述は ingest 済みの "Loop Engineering" 1本に基づく。肩書・所属・経歴などの伝記情報は当該記事に含まれないため未収録(推測で補わない)。

## 詳細

### ingest 済みの著作
- **"[[loop-engineering]]"**(2026-06-07)— エージェントに prompt する人間を、それを代行するループ設計に置き換えるという主張。5つの構成要素(Automations / Worktrees / Skills / Plugins・connectors / Sub-agents)+ ディスク上の memory を、Codex app と Claude Code の対応表として整理する。

### 関連著作(本記事から参照・未 ingest)
"Loop Engineering" は著者自身の以下の記事群を相互参照しており、loop engineering の議論はこれらの上に積み上がっている。**いずれも原本未取得のため未 ingest**(必要なら個別に ingest 可能):
- *agent harness engineering* — 単一エージェントが動く環境づくり。loop engineering の「一階下」。
- *factory model* — ソフトウェアを作るシステム。
- *long-running agents* — モデルは run 間で忘れるので memory はディスクに置く、という長時間稼働エージェントの原則。
- *agent skills* — `SKILL.md` 形式の解説(本 wiki の [[agent-skills]] と同主題)。
- *intent debt* — エージェントは毎セッション cold start で意図の穴を確信的な推測で埋める。
- *the orchestration tax* — 並列化の天井は人間のレビュー帯域。
- *the code agent orchestra* / *adversarial code review* — maker と checker(作る者/検証する者)を分けるべきという主張(本 wiki の [[multi-agent-patterns]] / [[ai-code-review]] と接続)。
- *code review in the age of AI* — "your job is to ship code you confirmed works"。
- *comprehension debt* — 書いていないコードを速く出荷するほど、存在するものと理解の差が広がる。
- *cognitive surrender* — ループ自走時に意見を持つのをやめ、返答をそのまま受け取る危険。

## 出典
- `raw/articles/loop-engineering.md`(Addy Osmani, "Loop Engineering", 2026-06-07)— 著者名、当該記事の主張、相互参照される自著記事群(未 ingest)。

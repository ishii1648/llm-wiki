---
title: AI コーディングツールの3世代(autocomplete / sync / async)
type: concept
aliases: [AI coding tool generations, autocomplete, sync agent, async agent, synchronous agent, asynchronous agent, 同期エージェント, 非同期エージェント]
tags: [ai-coding-tools, coding-agents, taxonomy, github-copilot, claude-code, codex, cursor]
created: 2026-06-29
updated: 2026-06-29
sources:
  - raw/papers/writing-code-vs-shipping-code.md
related:
  - "[[writing-code-vs-shipping-code]]"
  - "[[weak-link-hypothesis]]"
  - "[[agent-loop]]"
  - "[[loop-engineering]]"
  - "[[agentic-engineering]]"
---

## 概要
[[writing-code-vs-shipping-code]] が用いる、生成 AI コーディングツールの**自律度による3世代分類**。2022年以降の進化を autocomplete → sync(同期)agent → async(非同期)agent として整理する。各世代は旧世代と併用されるため、生産性効果は**累積**で測られる(commits 基準で +40% / +140% / +180%)。

## 3世代

### 1. Autocomplete(自動補完)
- 開発者がコードやコメントを書くと文脈を解析し、スニペット・コメント・ドキュメントを提案。IDE に直接統合。
- 嚆矢は **GitHub Copilot**(2022年6月、ChatGPT より前)。続いて Codeium(2022末)、Cursor(2023/3)、Amazon CodeWhisperer(2023/4)。
- 先行 field experiment(Cui et al. 2026)で生産性 **約+26%**。
- (補足)2023/9 に Copilot/Cursor が IDE 内チャットを統合したが、チャットボットは横断的で非コード特化のため本論文では独立カテゴリとして扱わない。

### 2. Sync Agent(同期エージェント)
- 2025年初頭〜。開発者がタスクを prompt すると、エージェントが **IDE 内でリアルタイムに**コードベースを探索し、複数ファイルに跨る編集を提案・適用し、コード実行(単体テスト等)し、反復的に修正する。
- 開発者は挙動を**監視・レビュー・承認**し、統合の責任を保持(= **同期=リアルタイム監督**)。
- アクセス形態: IDE 統合型(**Cursor**, **GitHub Copilot**)/ CLI・外部 IF 型(**Claude Code**, **OpenAI Codex**)。

### 3. Async Agent(非同期エージェント)
- より新しい世代。**長時間自律**で動作し、人間の介在をほぼ要さない。高レベルタスク(機能実装・バグ修正・リファクタ)を渡すと、自分で計画・実行し、より大きく複雑なタスクを担える。
- **GitHub Async Agent(Copilot async agent)**: 2025/5/19 公開。**issue を割り当てる**だけで(人間の協力者と同じ要領で)クラウド VM 上で起動し、コード特定・編集・テスト・**draft PR への push** まで自律実行。完了後に人間がレビュー/修正依頼/マージ。
- OpenAI Codex・Claude Code も async 機能を持つが、割り当ては GitHub issue ではなく外部 IF(例: OpenAI web)経由。

> ⚠️ 境界は曖昧化: Codex / Claude Code は**同じツールが**タスクの複雑さと監督度に応じて sync/async どちらでも動く。区別は厳密な技術境界より「**割り当てタスクの複雑さと開発者の監督度**」に依る。

## 生産階層への介入点([[weak-link-hypothesis]])
- autocomplete: **code-writing 層のみ**を augment。
- sync / async agent: より後段(commit・PR 生産)にも介入。async は PR 生産まで **automate** するが、マージ前の**人間レビューは残る** → これが減衰(attenuation)の源。

## 出典
- raw/papers/writing-code-vs-shipping-code.md(NBER w35275, 2026, §3.2 "A Brief History of Generative AI Tools in Software Development")

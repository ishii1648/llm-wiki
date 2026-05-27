---
title: Bun
type: entity
aliases: [oven-sh/bun, bun runtime]
tags: [javascript-runtime, toolkit, rust, oven-sh]
created: 2026-05-27
updated: 2026-05-27
sources:
  - https://github.com/oven-sh/bun
related:
  - "[[bun-claude-code-patterns]]"
---

## 概要

Bun は速度を重視したオールインワンの JavaScript ランタイム兼ツールキット(バンドラ・テストランナー・Node.js 互換パッケージマネージャを内蔵)。WebKit の JavaScriptCore を JS エンジンに使い、コア実装は主に Rust + JSC 連携用の C++ で書かれる(2026-05 に Zig から Rust へ移行、`.zig` は移行リファレンスとして非コンパイルで残置)。開発元は oven-sh。

## Claude Code 活用

Bun リポジトリは Claude Code をエージェント前提で深く作り込んでいる(CLAUDE.md・hooks・slash command・GitHub Actions 連携・skills・専用 CLI ツール)。詳細は [[bun-claude-code-patterns]] を参照。

## 出典

- https://github.com/oven-sh/bun — リポジトリ本体・README
- https://raw.githubusercontent.com/oven-sh/bun/main/CLAUDE.md — 言語構成と開発フロー

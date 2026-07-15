---
title: issue-ops (toolchain)
type: entity
aliases: [issue-ops, IssueOps toolchain, issue-ops org]
tags: [github, github-actions, toolchain, open-source, issueops]
created: 2026-07-15
updated: 2026-07-15
sources:
  - raw/articles/issueops-automate-ci-cd.md
related:
  - "[[issueops]]"
---

## 概要
**issue-ops** は、[[issueops]] パターンを実装するためのオープンソースな GitHub Actions 群とドキュメントをまとめた GitHub organization。issue 本文を機械可読データへ変換し、検証し、ラベルで状態管理する一連のアクションを提供する。ドキュメントは [issue-ops/docs](https://github.com/issue-ops/docs)(サイト: <https://issue-ops.github.io/docs/>)にある。

## 主要アクション
記事のチームメンバーシップ実例で使われる中核アクション。

| アクション | 役割 |
|---|---|
| **`issue-ops/parser`**(@v4) | GitHub issue form の本文 Markdown を機械可読な JSON に変換する。`issue-form-template` を渡し `outputs.json` を得る。IssueOps の入口。 |
| **`issue-ops/validator`**(@v3) | parse 済み JSON をカスタム検証スクリプトで検証する。`add-comment` で結果を issue にコメントでき、`outputs.result == 'success'` で後段を分岐。 |
| **`issue-ops/labeler`**(@v2) | issue に対しラベルを `add` / `remove` する。IssueOps の「状態」を表現する主手段(`validated` / `submitted` / `approved` / `denied` 等)。 |

## 併用される周辺アクション
実例では issue-ops 純正以外にも次を組み合わせる(出典記事の範囲)。

- **`actions/github-script`**(@v7): Octokit を直接叩く。管理者チーム所属チェック(`teams.getMembershipForUserInOrg`)、チームへのユーザ追加(`teams.addOrUpdateMembershipForUserInOrg`)、issue のクローズ(`issues.update` with `state_reason`)など。
- **`actions/create-github-app-token`**(@v1): リポジトリ外リソースを操作するための GitHub App トークン取得。org レベルの team 操作に必須。
- **`peter-evans/create-or-update-comment`**(@v4): ユーザ/管理者への通知コメント投稿。
- **`@octokit/rest`**: validator のカスタム検証スクリプトで team 実在確認(`teams.getByName`)に利用。

## ラベルによる状態表現
issue-ops のワークフローは**ラベルを FSM の状態フラグ**として使う。代表例:

- `team-membership` — 対象 issue の分類(ワークフロー起動の前提 guard)
- `validated` — 検証通過
- `submitted` — `.submit` 済み(管理者レビュー待ち)
- `approved` / `denied` — 最終判定

各コメントワークフローの `if:` はこれらラベルの `contains(...) == true/false` の合成で遷移条件を表現する(→ [[issueops]] の guard)。

## 出典
- raw/articles/issueops-automate-ci-cd.md(parser/validator/labeler の用途・バージョン、併用アクション、ラベルによる状態管理、docs リポジトリの所在)

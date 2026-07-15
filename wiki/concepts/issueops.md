---
title: IssueOps
type: concept
aliases: [IssueOps, Issue Ops, issue-driven automation]
tags: [github, automation, ci-cd, github-actions, issues, pull-requests, finite-state-machine]
created: 2026-07-15
updated: 2026-07-15
sources:
  - raw/articles/issueops-automate-ci-cd.md
related:
  - "[[issue-ops]]"
  - "[[gitops]]"
---

## 概要
**IssueOps** は、GitHub の Issues・GitHub Actions・Pull Requests を「ワークフロー自動化のインターフェース」として使う実践。ツールを切り替えたり手動でアクションを起動する代わりに、**issue コメント・ラベル・状態変化**をトリガに CI/CD パイプラインの起動、タスク割り当て、アプリのデプロイまでを駆動する。ChatOps や ClickOps と同様に、ツール群と概念を GitHub Issues に適用して反復作業を自動化するアプローチ(GitHub Blog, Nick Alteen)。

## なぜ IssueOps か
記事は4つの利点を挙げる。

- **イベント駆動の自動化(event-driven)**: Issue/PR での日常的なやり取りをそのまま GitHub Actions のトリガに変える。
- **カスタマイズ性**: イベント種別と入力データに応じてワークフローを組める。バグトリアージからデプロイ起動まで、チームごとの流儀に合わせられる。
- **透明性(transparency)**: Issue に対する全操作が timeline に記録され、「いつ何が起きたか」が追いやすい。
- **不変性・監査可能性(immutability & auditability)**: Issue/PR を source of truth とするため、あらゆるアクションが記録として残る。

> この「Issue/PR を真実源にする」構図は、git を desired state の真実源とする [[gitops]] と同型。GitOps がクラスタの状態を git に集約するのに対し、IssueOps は**運用オペレーション(承認・申請・デプロイ起動)を Issue/PR に集約**する。

### クイックスタート(3ステップ)
1. **トリガを定義**: issue のオープン、ラベル付与、PR マージなど、ワークフローを起動すべきアクションを特定する。
2. **GitHub Actions を構成**: イベント発生時の挙動を YAML ワークフローで定義する。
3. **試して反復**: 小さく始めて、うまくいくものを広げる。

## 中核メンタルモデル: 有限状態機械(finite-state machine)
IssueOps ワークフローは、多くが次の基本パターンに従う。

1. ユーザが issue を開いて情報を提供する
2. 必須情報について issue が検証(validate)される
3. issue が処理へ向けて submit される
4. 権限を持つユーザ/チームに承認(approval)が要求される
5. リクエストが処理され issue がクローズされる

これを設計するときは**有限状態機械**として捉えると見通しが良い。issue が状態機械で処理される *object* であり、*event* に応じて *state* を変える。状態遷移の際、必要な条件(*guard*)を満たせば *transition* の途中で *action* が実行される。

### 5つの構成要素
| 要素 | 定義 |
|---|---|
| **State(状態)** | ある条件を満たすオブジェクトのライフサイクル上の一点。issue では opened / submitted / approved / denied / closed など。 |
| **Event(イベント)** | 状態変化を引き起こす外部の出来事。IssueOps ではユーザ操作(create/submit/approve/deny/process)と GitHub 操作(ラベル追加・コメント・milestone 更新)の両方。 |
| **Transition(遷移)** | ある状態から別の状態への変化。走査時に action を起こすリンク。 |
| **Action(アクション)** | 遷移時に実行される atomic なタスク。管理者への通知、ユーザのチーム追加、結果の通知など。 |
| **Guard(ガード)** | トリガイベント時に評価される条件。**全 guard を満たしたときのみ**遷移する。条件なしで即時に起きる遷移を *unguarded transition* と呼ぶ。 |

guard の例: 「管理者が `.approve` とコメントしない限り Approved へ遷移しない」「`.deny` がない限り Denied へ遷移しない」。

## 実例: チーム参加申請ワークフロー
記事は GitHub Actions のみで完結する「チームメンバーシップ申請・承認」自動化を通して IssueOps を示す。ツールチェーンの詳細は [[issue-ops]] を参照。

- **Step 1 — Issue Form テンプレート**: GitHub issue form で標準化された issue を作らせ、[[issue-ops]] の `parser` アクションで issue 本文 Markdown から機械可読な JSON を抽出する(例: `{ "team": "my-team" }`)。テンプレートには `team-membership` ラベルを付与。
- **Step 2 — 検証(validation)**: `validator` アクションがカスタム検証スクリプト(Octokit で `teams.getByName` を叩き team の実在を確認、404 ならエラー文言を返す)で入力を検証する。
- **Step 3 — Issue ワークフロー**: `on: issues (opened/edited/reopened)` で起動。`team-membership` ラベル付き issue に限定(`if: contains(...labels...)`)。ラベルリセット → parse → validate → 成功なら `validated` ラベル付与+次アクション案内(「`.submit` してください」)。**"Validate early and often"**(issue が触られるたび再検証)が指針。
- **Step 4 — コメント駆動のワークフロー**: `on: issue_comment (created)` で、コメント本文と現在のラベル状態を `if:` の guard で判定して分岐する。
  - **Submit** (`.submit`): 本文改変に備えて再検証 → 成功で `validated`+`submitted` ラベル → 管理者チームへレビュー依頼通知。
  - **Deny** (`.deny`): コメント者が `admins` チーム所属かを `teams.getMembershipForUserInOrg` で確認(非メンバーなら `exit 0`)→ `denied` ラベル → ユーザ通知 → issue を `not_planned` でクローズ。
  - **Approve** (`.approve`): 管理者チェック後、parse した team に `teams.addOrUpdateMembershipForUserInOrg` でユーザを追加 → 成功通知 → issue を `completed` でクローズ。

各 comment ワークフローの `if:` は「コマンド文字列で始まる」+「必要ラベルが揃っている」+「approved/denied がまだ無い」+「issue が open」という guard の合成であり、これが FSM の遷移条件そのものになっている。

## 応用範囲
チームメンバーシップは一例で、ユーザ削除・アクセス監査・デプロイ承認・バグトリアージなどへ拡張できる。IssueOps の本質は「開発者が常時使う GitHub という面(surface)に自動化を持ち込み、Issue/PR をワークフローの管制塔にする」こと。リポジトリを離れずに摩擦を減らし、効率と透明性を保つ。

> ⚠️ 本記事は GitHub Actions ワークフロー部分に焦点。リポジトリ設定・権限・GitHub App のセットアップ手順は [IssueOps documentation](https://issue-ops.github.io/docs/) 側に委ねられており未収録。

## 出典
- raw/articles/issueops-automate-ci-cd.md(IssueOps の定義・利点・FSM モデル・5要素・team-membership 実例の全ワークフロー)

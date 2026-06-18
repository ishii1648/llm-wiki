---
name: auto-fix
description: >-
  PR の merge conflict と CI failure を Monitor ツールで継続監視し、検知した
  問題を解消するループを回す。「/auto-fix [PR番号]」での明示呼び出しに加え、
  Claude が `gh pr create` で PR を作成した直後、または PR を持つブランチへ
  `git push` した直後にも自動起動する(CLAUDE.md「PR の自動監視」参照)。引数
  なしのときは現ブランチに紐づく PR を `gh pr view --json number` で特定する。
---

# auto-fix

PR が **mergeable + 全 check 緑** になるまで監視し、conflict と CI failure を解消するループを回します。

## 起動条件

- ユーザーが `/auto-fix [PR番号]` と明示的に呼んだとき
- Claude が `gh pr create` で PR を作った直後
- Claude が PR を持つブランチへ `git push` した直後

引数なしで起動された場合は現ブランチに紐づく PR 番号を `gh pr view --json number -q .number` で特定する。該当 PR が無ければ「対象 PR なし」と 1 行報告して即終了する(無駄な監視を起こさない)。

## 動作

### 1. 初期スナップショット

`gh pr view <num> --json mergeable,mergeStateStatus,statusCheckRollup,headRefOid,baseRefName,url` を取って現状を要約し、ユーザーに 1 行で「PR #N を監視開始 (state=..., pending=N, failed=N)」と伝える。

### 2. 監視ループ (Monitor, persistent)

`monitor.sh` を Monitor ツールで `persistent: true` 起動する:

```
bash .claude/skills/auto-fix/monitor.sh <PR番号>
```

スクリプトは 30 秒間隔で polling し、**状態が変化した瞬間だけ** stdout に 1 行 emit する(silence is not success の原則: 成功シグナルだけ拾うと CI hang や crashloop が無音で見過ごされる)。

出力行の意味:

| 出力 | 意味 | 次のアクション |
|---|---|---|
| `[HH:MM:SS] mergeable=... state=... pending=N failed=N` | 状態差分(変化のあった瞬間のみ) | そのまま観察継続 |
| `  FAIL: <check名>: <URL>` | 失敗した check の詳細 | §3 へ |
| `CONFLICT: PR #N has merge conflicts with base` | base ブランチとコンフリクト | §4 へ |
| `GREEN: PR #N mergeable, all checks passing` | **終端**(スクリプト exit 0) | TaskStop して完了報告 |
| `[ERR] gh fetch failed` | 一時的取得エラー | 無視してよい(スクリプト側で sleep + 継続) |

ポーリング間隔は環境変数 `MONITOR_INTERVAL` で上書き可能(デフォルト 30s)。

### 3. CI failure を検知したら

Monitor が `FAIL: <check名>: <URL>` を emit したら:

1. `gh run list --branch $(git rev-parse --abbrev-ref HEAD) --limit 5 --json databaseId,name,conclusion,headSha` で最新失敗 run の id を特定(現 head sha と一致するものを優先)
2. `gh run view <runId> --log-failed` で失敗ログを取得
3. ログから根本原因を特定:
   - lint / formatter のメカニカルな失敗 → 該当ルールで自動修正
   - 型エラー / テスト失敗 → コードを修正
   - flaky の可能性が高い場合は `gh run rerun <runId> --failed` を **1 回まで** 試す(2 回目は flaky 決め打ちしない)
4. `contextual-commit` skill で commit → push
5. push で新しい run が走るので Monitor の通知を再観察。次の `GREEN` 出力が終端

このリポジトリ(llm-wiki)固有のよくある失敗パターン:
- `scripts/lint.sh` の dangling links(`[[X]]` の参照先なし) → ページ新設 or リンク修正 or 統合
- 出典 raw パスの不存在 → `wiki/sources.md` 台帳と各ページ frontmatter `sources:` の双方向不一致
- orphan pages → `wiki/index.md` への追記漏れ

### 4. CONFLICT を検知したら

1. `gh pr view <num> --json baseRefName -q .baseRefName` で base ブランチ名を取得
2. `git fetch origin <base>`
3. このリポジトリの履歴ポリシー(merge or rebase)を `git log --oneline -10 origin/<base>` の merge commit 有無から推測。**判断困難なら merge を選ぶ**(履歴を捨てない・revert で戻せる側)
4. conflict 解消:
   - 機械的に解消できるもの(片側採用が自明な追記・import 並び・lockfile 等)は自動で進める
   - wiki 系のリポジトリでは `wiki/index.md` `wiki/sources.md` `wiki/log.md` が両側で追記される頻発パターン → **両側の追記を保持してマージ**するのが基本(片側を捨てると ingest 履歴が消える)
   - セマンティックな判断が要るもの(両側で同一ページを別方向に書き換え等)は **AskUserQuestion で人間に確認**してから進める
5. `git commit` → `git push`

### 5. 完了条件

- Monitor が `GREEN: ...` を emit → TaskStop して「PR #N is ready to merge (URL)」と 1 行報告して終了
- 以下のいずれかに該当 → 停止して状況を報告(無理に続けない):
  - 同一エラーが連続 3 回検知(修正が空振りしている兆候)
  - 直近 3 コミットで同じファイル・同じ行を行ったり来たりしている
  - 認証エラー / push 権限なし
  - 人間判断要(セマンティック衝突・broken feature・要件不明)
  - skill 起動から 60 分経過しても緑にならない

## ガード

- `--no-verify` などフック無効化は使わない(CLAUDE.md ガイドライン)
- main / master など base ブランチへの force push・履歴書き換えはしない
- 同じ修正コミットを 3 連続で繰り返さない(収束していない兆候 → 停止)
- `git push --force-with-lease` は rebase で base を取り込み直す場合のみ。conflict 解消は **merge を優先**して force push を避ける
- 監視中に別のユーザー指示が来たら即 TaskStop し、新タスクを優先する

## 出力例

```
[Claude] gh pr create で #12 を作成 → auto-fix #12 自動起動
[monitor] [00:01:23] mergeable=UNKNOWN state=UNKNOWN pending=2 failed=0
[monitor] [00:02:15] mergeable=MERGEABLE state=CLEAN pending=1 failed=0
[monitor] [00:03:08] mergeable=MERGEABLE state=CLEAN pending=0 failed=1
[monitor]   FAIL: lint: https://github.com/owner/repo/actions/runs/12345
[Claude] gh run view 12345 --log-failed → wiki/foo.md に dangling link [[bar]] を発見 → 修正 → contextual-commit で push
[monitor] [00:04:50] mergeable=MERGEABLE state=CLEAN pending=2 failed=0
[monitor] [00:06:30] GREEN: PR #12 mergeable, all checks passing
[Claude] PR #12 is ready to merge. https://github.com/owner/repo/pull/12
```

## ファイル

- `SKILL.md`(このファイル) — 動作仕様・起動条件・失敗解消手順
- `monitor.sh` — Monitor ツールから呼ぶ polling スクリプト(出力フォーマットは §2 の表を参照)

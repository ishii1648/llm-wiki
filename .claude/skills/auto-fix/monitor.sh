#!/usr/bin/env bash
# auto-fix skill: PR の merge 可否と CI status を 30s 間隔で polling し、
# 状態差分のみを stdout に emit する。Monitor ツールから persistent モードで
# 呼ぶ前提(各行が 1 通知になる)。
#
# Usage: monitor.sh <PR_NUMBER>
#
# 出力形式(これ以外は emit しない):
#   [HH:MM:SS] mergeable=<X> state=<Y> pending=<N> failed=<N>   状態差分
#     FAIL: <check名>: <URL>                                    失敗 check の詳細
#   CONFLICT: PR #<N> has merge conflicts with base             conflict 検知時(ループ継続)
#   GREEN: PR #<N> mergeable, all checks passing                終端(exit 0)
#   [ERR] gh fetch failed                                       一時的取得エラー(ループ継続)
#
# silence is not success: 進捗・失敗・終端のすべてを emit すること。
# 成功シグナルだけを拾うと CI hang や crashloop が無音で見過ごされる。

set -u

PR="${1:?Usage: monitor.sh <PR_NUMBER>}"
INTERVAL="${MONITOR_INTERVAL:-30}"

prev=""
while true; do
  if ! s=$(gh pr view "$PR" --json mergeable,mergeStateStatus,statusCheckRollup 2>/dev/null); then
    echo "[ERR] gh fetch failed"
    sleep "$INTERVAL"
    continue
  fi

  m=$(jq -r '.mergeable // "UNKNOWN"' <<<"$s")
  st=$(jq -r '.mergeStateStatus // "UNKNOWN"' <<<"$s")
  pending=$(jq '[.statusCheckRollup[]? | select(.conclusion==null or .conclusion=="PENDING" or .status=="IN_PROGRESS" or .status=="QUEUED")] | length' <<<"$s")
  fcount=$(jq '[.statusCheckRollup[]? | select(.conclusion=="FAILURE" or .conclusion=="TIMED_OUT" or .conclusion=="CANCELLED" or .conclusion=="ACTION_REQUIRED")] | length' <<<"$s")
  failed=$(jq -r '.statusCheckRollup[]? | select(.conclusion=="FAILURE" or .conclusion=="TIMED_OUT" or .conclusion=="CANCELLED" or .conclusion=="ACTION_REQUIRED") | "\(.name // .context // "?"): \(.detailsUrl // .targetUrl // "")"' <<<"$s")

  cur="m=$m st=$st pending=$pending fcount=$fcount"
  if [ "$cur" != "$prev" ]; then
    echo "[$(date -u +%H:%M:%S)] mergeable=$m state=$st pending=$pending failed=$fcount"
    if [ -n "$failed" ]; then
      while IFS= read -r line; do
        echo "  FAIL: $line"
      done <<<"$failed"
    fi
    prev="$cur"
  fi

  if [ "$m" = "MERGEABLE" ] && [ "$pending" = "0" ] && [ "$fcount" = "0" ]; then
    echo "GREEN: PR #$PR mergeable, all checks passing"
    exit 0
  fi

  if [ "$m" = "CONFLICTING" ]; then
    echo "CONFLICT: PR #$PR has merge conflicts with base"
  fi

  sleep "$INTERVAL"
done

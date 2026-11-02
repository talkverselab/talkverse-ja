#!/bin/zsh
# Grok 푸시 감시: talkversehanja main 의 새 커밋마다 한 줄 출력 + grok_limit_log.md 에 기록.
# Claude 자신의 커밋(메시지에 Claude-Session 트레일러)은 건너뜀.
R=talkverselab/talkversehanja; LOG=~/Hanja/grok_limit_log.md
last=$(gh api "repos/$R/commits/main" --jq .sha 2>/dev/null)
while true; do
  sleep 30
  cur=$(gh api "repos/$R/commits/main" --jq .sha 2>/dev/null) || continue
  [[ -z "$cur" || "$cur" == "$last" ]] && continue
  gh api "repos/$R/compare/$last...$cur" --jq '.commits[].sha' 2>/dev/null | while read s; do
    own=$(gh api "repos/$R/commits/$s" --jq '.commit.message|test("Claude-Session")' 2>/dev/null)
    [[ "$own" == "true" ]] && continue
    info=$(gh api "repos/$R/commits/$s" --jq '"\(.commit.committer.date)|\(.commit.message|split("\n")[0])|\([.files[]|"\(.filename)(\(.changes))"]|join(" ")|.[0:300])"' 2>/dev/null)
    t=$(date '+%H:%M:%S')
    echo "GROK PUSH $t ${s:0:7} $info"
    echo "| $t | 커밋 ${s:0:7} ${info//|/ · } | 감시 스크립트 |" >> $LOG
  done
  last=$cur
done

#!/bin/zsh
# 강화 재작성 일괄: 편마다 Grok 전송 → 답 저장 → JSON 반영 → 검사기(--fix-rd). 사용: tools/enrich_run.sh <편id>...
cd "$(dirname "$0")/.." || exit 1
VENV=/private/tmp/claude-501/-Users-talkverse-talkverse-ja/b7db91e2-87e7-4be6-b087-4ef22eb923fd/scratchpad/venv
for id in "$@"; do
  f=$(ls assets/data/dialogues/R*/*/$id.json 2>/dev/null | head -1); [[ -z "$f" ]] && { echo "NOFILE $id"; continue; }
  out=$(/usr/bin/python3 tools/grok_send.py data/review/${id}_grok_enrich_prompt.md data/review/${id}_grok_enrich.md --wait 480 2>&1 | tail -1)
  echo "$id SEND $out"
  case "$out" in
    OK*) $VENV/bin/python tools/apply_rewrite.py "$f" data/review/${id}_grok_enrich.md --note "강화 재작성 v2 반영" && $VENV/bin/python tools/check_dialogues.py --fix-rd "$f" 2>&1 | grep "ERR\|총 오류" ;;
    LIMIT*) echo "LIMIT 감지 — 중단"; exit 3 ;;
  esac
done

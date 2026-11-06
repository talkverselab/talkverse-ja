#!/bin/zsh
# 일본어 단어 그림 회차 N번 돌리기(2026-11-06 사용자 지시로 일본어 세션 직접 진행). 사용: tools/grok_word_rounds.sh [N=10] [시트폴더]
# M4 의 gh 는 로그인이 풀려 있어(r398 이 그래서 GitHub 에 못 올라감) 지시서 커밋은 M6 ja-art 클론에서 올린다.
# 공개는 하지 않는다 — 시트를 보고 M4 에서 redo·approve·publish. 한 방 진행: GROK_CHAT 고정, 새 대화 금지.
N=${1:-10}; SHEETS=${2:-/tmp/ja_sheets}; mkdir -p $SHEETS
A=${ART:-/private/tmp/claude-501/-Users-talkverse-talkverse-uk/0de9ae3e-58ba-4cc7-8fae-95c652558801/scratchpad/art}
ENV="export PATH=/opt/homebrew/bin:\$HOME/.local/bin:\$PATH ART=$A GROK_CHAT=${GROK_CHAT:-00092f0a}; cd ~/talkverse-uk"
for i in $(seq 1 $N); do
  out=$(ssh macmini4 "$ENV; /usr/bin/python3 - <<'P'
import sys, json
sys.path.insert(0, 'tools'); import grok_art as a
a.push = lambda: a.git('pull -q --rebase')
a.grok_send = lambda t: open('/tmp/ja_msg_next.txt', 'w', encoding='utf-8').write(t)
a.next_round('ja', 4)
print('ROUND', json.load(open('docs/art_state.json'))['ja']['round'])
P" 2>&1)
  echo "$out" | tail -2
  echo "$out" | grep -q '남은 단어 없음' && { echo ALLDONE; exit 0; }
  R=$(echo "$out" | sed -n 's/^ROUND //p'); [ -z "$R" ] && { echo "STOP 발주 준비 실패"; exit 1; }
  ok=
  for t in 1 2 3 4; do
    git -C ~/talkverse/ja-art fetch -q "macmini4:$A" main && git -C ~/talkverse/ja-art push -q origin FETCH_HEAD:main && { ok=1; break; }
    sleep 10; ssh macmini4 "git -C $A pull -q --rebase"
  done
  [ -z "$ok" ] && { echo "STOP r$R 지시서 푸시 실패"; exit 1; }
  ssh macmini4 "$ENV; /usr/bin/python3 -c \"
import sys; sys.path.insert(0, 'tools'); import grok_art as a
a.grok_send(open('/tmp/ja_msg_next.txt', encoding='utf-8').read())\"" 2>&1 | tail -1
  done_=
  for w in $(seq 1 40); do
    gh api "repos/talkverselab/talkversehanja/commits?per_page=100" --jq '.[].commit.message' 2>/dev/null | grep -q "ja r$R done" && { done_=1; break; }
    sleep 30
  done
  [ -z "$done_" ] && { echo "STOP r$R 20분 안에 완료 없음"; exit 2; }
  ssh macmini4 "$ENV; python3 tools/grok_art.py auto ja 2>&1 | grep -v -e Deprecat -e getdata | tail -3"
  scp -q macmini4:talkverse-uk/docs/art_sheet_ja_latest.jpg $SHEETS/r$R.jpg
  echo "OK r$R"
done
echo FINISHED $N

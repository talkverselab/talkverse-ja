#!/bin/bash
# 밤샘(2026-11-03 사용자 "니가 판단해서 밤샘작업"): 조연 시트 2장 → 여자 학습자 컷(R0·R1) → 업로드 → M4 Chrome 끄기.
cd "$(dirname "$0")/.." || exit 1
ssh macmini4 'pgrep -f chrome-grok-ja >/dev/null || (cp ~/chrome-grok/Default/Cookies ~/chrome-grok/Default/Cookies-journal ~/chrome-grok-ja/Default/; open -na "Google Chrome" --args --remote-debugging-port=9230 --remote-debugging-address=127.0.0.1 --user-data-dir=$HOME/chrome-grok-ja --no-first-run "https://grok.com/"; sleep 10)'
curl -s -m 3 127.0.0.1:9230/json/version >/dev/null || ssh -fN -o ExitOnForwardFailure=yes -L 9230:127.0.0.1:9230 macmini4
export GROK_HOME=https://grok.com/ GROK_CDP_PORT=9230 GROK_ATT_DIR=/tmp/grok_att/ja
A=/tmp/grok_att/ja/chars_ja_v1.jpg,/tmp/grok_att/ja/sian_01_clay.jpg
for k in work school; do
  [ -s data/review/art/cast_${k}_v1.jpg ] || /usr/bin/python3 tools/grok_image.py data/review/art/req_cast_${k}.md data/review/art/cast_${k}_v1.jpg --attach $A
done
ls assets/data/dialogues/R0/*/*.json assets/data/dialogues/R1/*/*.json | xargs -n1 basename | sed 's/.json$//' | sort > data/review/write/female_ids.txt
/usr/bin/python3 tools/grok_scene_batch.py $(cat data/review/write/female_ids.txt) --female --push --tab grok.com > data/review/write/scene_female.log 2>&1
/usr/bin/python3 tools/scene_upload.py >> data/review/write/scene_female.log 2>&1
ssh macmini4 'pkill -f "user-data-dir=/Users/talkverse/chrome-grok-ja"'; pkill -f "L 9230:127.0.0.1:9230"
echo OVERNIGHT_DONE

#!/bin/bash
# 밤샘 2(2026-11-04 사용자 "중급 고급 밤샘작업 큐"): 중급·고급·최상급 99편 여자 학습자 컷(조연 시트 첨부) → 업로드 → M4 Chrome 끄기.
cd "$(dirname "$0")/.." || exit 1
ssh macmini4 'pgrep -f chrome-grok-ja >/dev/null || (cp ~/chrome-grok/Default/Cookies ~/chrome-grok/Default/Cookies-journal ~/chrome-grok-ja/Default/; open -na "Google Chrome" --args --remote-debugging-port=9230 --remote-debugging-address=127.0.0.1 --user-data-dir=$HOME/chrome-grok-ja --no-first-run "https://grok.com/"; sleep 10)'
curl -s -m 3 127.0.0.1:9230/json/version >/dev/null || ssh -fN -o ExitOnForwardFailure=yes -L 9230:127.0.0.1:9230 macmini4
export GROK_HOME=https://grok.com/ GROK_CDP_PORT=9230 GROK_ATT_DIR=/tmp/grok_att/ja
ls assets/data/dialogues/R2/*/*.json assets/data/dialogues/R3/*/*.json assets/data/dialogues/R4/*/*.json | xargs -n1 basename | sed 's/.json$//' | sort > data/review/write/female_r23_ids.txt
/usr/bin/python3 tools/grok_scene_batch.py $(cat data/review/write/female_r23_ids.txt) --female --push --tab grok.com > data/review/write/scene_female_r23.log 2>&1
/usr/bin/python3 tools/scene_upload.py >> data/review/write/scene_female_r23.log 2>&1
ssh macmini4 'pkill -f "user-data-dir=/Users/talkverse/chrome-grok-ja"'; pkill -f "L 9230:127.0.0.1:9230"
echo OVERNIGHT2_DONE

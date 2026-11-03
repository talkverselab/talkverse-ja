#!/bin/bash
# 카오스·심쿵으로 대사가 바뀐 턴의 장면 컷만 다시 받기: 첫 일괄 요청(PID $1)이 끝나길 기다린 뒤, recut_plan.json 의 컷 파일을 지우고 그 편들만 재요청(+그림 저장소 푸시+R2·D1 업로드).
cd "$(dirname "$0")/.." || exit 1
[ -n "$1" ] && while kill -0 "$1" 2>/dev/null; do sleep 30; done
/usr/bin/python3 - <<'PY'
import json,os
ART=os.path.expanduser('~/talkverse/ja-art/talkverse_art/scene/ja')
plan=json.load(open('data/review/chaos/recut_plan.json'))
n=0
for ep,cuts in plan.items():
    for c in cuts:
        p=f'{ART}/{ep}/cut{c}.jpg'
        if os.path.exists(p): os.remove(p); n+=1
open('data/review/chaos/recut_ids.txt','w').write('\n'.join(plan))
print('지운 컷',n)
PY
GROK_ATT_DIR=/tmp/grok_att/ja GROK_CDP_PORT=9230 /usr/bin/python3 tools/grok_scene_batch.py $(cat data/review/chaos/recut_ids.txt) --push --tab 832d5dbe > data/review/chaos/recut.log 2>&1
/usr/bin/python3 tools/scene_upload.py >> data/review/chaos/recut.log 2>&1
echo RECUT_DONE

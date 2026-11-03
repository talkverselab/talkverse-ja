#!/bin/bash
# Grok 새 계정(전문가)으로 남은 일 순서대로(2026-11-03): 신작 남은 편 → 바뀐 컷 다시 받기 → 신작 컷 → 업로드. 프로젝트 없이 새 대화(GROK_HOME).
cd "$(dirname "$0")/.." || exit 1
export GROK_HOME=https://grok.com/ GROK_CDP_PORT=9230 GROK_ATT_DIR=/tmp/grok_att/ja
for i in 1 2; do /usr/bin/python3 tools/grok_write_batch.py data/review/write/specs_r01.json --tab grok.com --tpl tools/prompts/write_grok_r01.md; done > data/review/write/batch_r01b.log 2>&1
/usr/bin/python3 - <<'PY' > data/review/chaos/recut_ids.txt
import json,os
ART=os.path.expanduser('~/talkverse/ja-art/talkverse_art/scene/ja')
plan=json.load(open('data/review/chaos/recut_plan.json'))
print('\n'.join(ep for ep,cuts in plan.items() if any(not os.path.exists(f'{ART}/{ep}/cut{c}.jpg') for c in cuts)))
PY
/usr/bin/python3 tools/grok_scene_batch.py $(cat data/review/chaos/recut_ids.txt) --push --tab grok.com > data/review/chaos/recut2.log 2>&1
/usr/bin/python3 tools/grok_scene_batch.py $(cat data/review/write/new_r01_ids.txt) --push --tab grok.com > data/review/write/scene_new.log 2>&1
/usr/bin/python3 tools/scene_upload.py >> data/review/write/scene_new.log 2>&1
echo RESUME_DONE

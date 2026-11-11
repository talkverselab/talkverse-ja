#!/bin/zsh
# 대본을 고친 턴만 회화 음성 다시 만들기(2026-11-09 일상회화 정리 뒤).
#   zsh tools/tts/redo_turns.sh <턴목록.json> [작업폴더=~/tts_work/ja_redo]
#   턴목록.json = {"<편id>": [턴번호, ...], ...}  (예: data/review/chaos/daily_fix_reverted.json)
# 음성은 00:01~10:00 KST 에만(사용자 지시 2026-11-11, 그 전 원칙은 01~07시) — 그 밖의 시간이면 기다렸다가 시작한다.
#   TTS_NOW=1 을 주면 기다리지 않고 바로 시작(사용자가 "지금 돌려"라고 한 때만).
# 순서: PC 의 그 턴 조각 wav 삭제(out/<편>/<턴 두 자리>_*.wav) → run_all.py 가 그 편들만(나머지 편은 done.txt) 생성·검사·mp4·R2·D1(편 단위 교체).
set -e
LIST=${1:?턴목록.json}; WORK=${2:-$HOME/tts_work/ja_redo}
R=${0:A:h:h:h}; PY=$HOME/.venvs/tts_ja/bin/python; PC=Administrator@100.127.143.37
while [ -z "$TTS_NOW" ]; do h=$(date +%H); [ "$h" -lt 10 ] && break; echo "$(date '+%m-%d %H:%M') 새벽 대기"; sleep 600; done
mkdir -p $WORK
EPS=$(python3 -c "import json,sys;print(' '.join(json.load(open('$LIST'))))")
python3 - "$LIST" "$WORK" "$R" <<'P'
import json, sys, glob, os
L = json.load(open(sys.argv[1])); work, R = sys.argv[2], sys.argv[3]
eps = sorted(os.path.basename(p)[:-5] for p in glob.glob(f'{R}/assets/data/dialogues/R*/*/*.json'))
open(f'{work}/done.txt', 'w').write('\n'.join(e for e in eps if e not in L) + '\n')
ps = ';'.join(f"Remove-Item D:\\tts_test\\job\\out\\{ep}\\{t:02d}_*.wav -ErrorAction SilentlyContinue" for ep, ts in L.items() for t in ts)
open(f'{work}/del.ps1', 'w', encoding='utf-8-sig').write(ps + '\n')
print('편', len(L), '턴', sum(map(len, L.values())))
P
scp -q $WORK/del.ps1 $PC:D:/tts_test/job/del_redo.ps1
ssh $PC "powershell -NoProfile -File D:\\tts_test\\job\\del_redo.ps1"
echo "$(date '+%m-%d %H:%M') PC 조각 삭제 끝 — 생성 시작"
cd $R/tools/tts && $PY run_all.py $WORK 12
echo "$(date '+%m-%d %H:%M') REDO_END"

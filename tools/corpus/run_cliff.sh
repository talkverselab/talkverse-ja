#!/bin/bash
# 일본어 절벽 재산출 한 번에(2026-11-03 사용자 결정): unidic 사전 → 공개 자막 말뭉치 ja raw → 일본 제작 작품 고르기(Q17) → 형태소 빈도·구간.
# 말뭉치·중간 파일은 저장소 밖 ~/corpus/ja, 결과는 data/corpus/cliff_v2/(앱 데이터는 덮어쓰지 않음).
set -e
PY=~/.venvs/ja-corpus/bin/python
D=~/corpus/ja; OUT="$(cd "$(dirname "$0")/../.." && pwd)/data/corpus/cliff_v2"
mkdir -p "$D" "$OUT"
$PY -c "import unidic,os;print(os.path.exists(os.path.join(unidic.DICDIR,'mecabrc')))" | grep -q True || $PY -m unidic download
[ -s "$D/ja_raw.zip" ] || curl -sL -o "$D/ja_raw.zip" "$JA_SUB_URL"  # 주소는 ~/corpus/README_local.txt(저장소 밖)
$PY "$(dirname "$0")/select_titles.py" "$D/ja_raw.zip" Q17 "$D/jp_titles.txt"
$PY "$(dirname "$0")/cliff_ja.py" "$D/ja_raw.zip" "$OUT" --only "$D/jp_titles.txt"
echo CLIFF_DONE

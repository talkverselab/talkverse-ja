# data/raw — 외부 원본 (git 미포함)

`data/scripts/build_furigana_db.py` 입력. 없으면 아래로 받는다.

| 파일 | 출처 | 라이선스 |
|---|---|---|
| kanji-data.json | https://raw.githubusercontent.com/davidluzgouveia/kanji-data/master/kanji.json | MIT |
| jlpt_n1..n5.csv | https://raw.githubusercontent.com/elzup/jlpt-word-list/master/src/n{1..5}.csv | MIT |
| JmdictFurigana.txt | https://github.com/Doublevil/JmdictFurigana/releases (latest) | CC BY-SA 4.0 (JMdict/EDRDG) |
| kyuji.cson | https://raw.githubusercontent.com/hakatashi/kyujitai.js/master/data/kyuji.cson | MIT |

```bash
cd data/raw
curl -sL -o kanji-data.json https://raw.githubusercontent.com/davidluzgouveia/kanji-data/master/kanji.json
for n in 1 2 3 4 5; do curl -sL -o jlpt_n$n.csv https://raw.githubusercontent.com/elzup/jlpt-word-list/master/src/n$n.csv; done
curl -sL -o kyuji.cson https://raw.githubusercontent.com/hakatashi/kyujitai.js/master/data/kyuji.cson
# JmdictFurigana.txt: releases 페이지 latest 의 JmdictFurigana.txt
cd ../.. && python data/scripts/build_furigana_db.py
```

# 일본어유니버스 — 세션 인수인계 (2026-11-04 아침, 전체 다시 씀)

> 새 세션은 **`CLAUDE.md`(이 리포) → 이 파일** 순서로 읽고 바로 이어간다. 규칙 배경은 CLAUDE.md 절(§1 서명 · §2 배포 · §2-1 Zealot · §2-2 TestFlight · §2-3 톤·두 화면 · §4 공개 저장소 · §5 표시 언어 · §6 공용 인터페이스). 기기·계정은 `~/.claude/CLAUDE.md`. 다른 언어앱이 따라 하는 공통 프롬프터 = `/Users/talkverse/talkverse/LANG_APP_REPLICATE_PROMPT.md`(§5-1 = 2026-11-04 변경 8건 표).

## 1. 지금 상태

| 항목 | 값 |
|---|---|
| 리포 | `talkverselab/talkverse-ja` master (PUBLIC). **2026-11-03 밤 출처 이름을 커밋 기록까지 지워 강제 푸시함**(git-filter-repo, 백업 번들 PC `D:\OneDrive\app project\japanese_universe\backup\ja_before_scrub_20261103.bundle`; 옛 브랜치 `master-old-history`·`master-stale`·stash 는 사용자 확인 뒤 삭제). 말뭉치 주소는 저장소 밖 `~/corpus/README_local.txt`. 미커밋 = CRLF 노이즈·도구 부산물·`data/review/*_grok_enrich*`(보류)·`RELAY_*` — 의도적으로만 커밋 |
| iOS TestFlight | **2611040252**(대사 띠·카드 앞면 한국어·레마 칩·시작 때 그림 내려받기·version.json·이름 묻기) — `tools/ios_release.sh`, 번들 `com.talkverse.japaneseUniverse`. 그 뒤 커밋(폰 그림 잘림 수정 c558734, 단어 345어 620b6eb)은 iOS 미반영 → 다음 `bash tools/ios_release.sh` |
| Android | CI 빌드 = 푸시마다 자동(`.md` 제외). Zealot 「일본어 유니버스」 **빌드 56** https://apps.talkverse.uk/Ultzu/258 (2026-11-04 03:35, c558734 폰 그림 잘림 수정까지). 올리기 `tools/zealot_push.sh --ci "한 줄"` |
| 회화 | **215편**(R0 47 · R1 70 · R2 56 · R3 41 · R4 1), `assets/data/dialogues/<R>/<주제>/*.json`, 턴마다 `lemmas`(janome, `tools/add_lemmas.py`), 카오스 88편(42%)·심쿵 전편. 리뷰 페이지 https://talkverse.uk/talkverse/review/ja/ (215편) |
| 단어 DB | **8,870어**(JLPT·말뭉치 8,525 + 회화 레마 345 `src=conv`, uk 선별). 시드 = `assets/data/version.json` **db=9**(번들 번호 ≠ 저장 번호면 단어·회화 DB 전부 다시 채움; 데이터 바꾸면 번호 +1 하고 log 한 줄) |
| 그림(단어) | `https://auth.talkverse.uk/art/ja/manifest` **1,510 항목**(실제 파일 1,377장 + 별칭 — 여러 단어가 한 그림 공유, 앱은 `word`→키). uk 가 그록으로 계속 추가 중: 회화 레마 147장 완료 → **JLPT N5 138 → N4 114 → N3 365**(rank 10001~, 2,521어 중 제외 1,694·별칭 210 = `data/review/write/jlpt_excluded.csv`). 회차당 4장이라 N5 며칠·전체 몇 주 |
| 그림(장면 컷) | `…/art/ja/scene/manifest[?episode=]` — 남자 215편 전부 + **여자(`<편id>_f`) 215편 전부 완료(2026-11-04 08:30, R2 56·R3 42·R4 1 밤샘)**. D1 `talkverse-db.art_scenes`(id 4867d7bd…) 기준 여자 r0 160·r1 276·r2 336·r3 340·r4 8컷. 저장소 sparse 클론 `~/talkverse/ja-art`(talkverselab/talkversehanja) `talkverse_art/scene/ja/<편id>[_f]/cutN.jpg` 1168×784, R2/D1 직접 업로드 `tools/scene_upload.py`(sha1 같으면 건너뜀) |
| 그림 기기 내려받기 | `lib/services/content_sync.dart` — 시작 때 매니페스트 둘을 받아 기기 크기(폰 584·512 / 태블릿 1168·512) 목록의 `?v=` 로 버전 계산, 다르면 `SyncScreen`(진행률·「나중에」)에서 바뀐 파일만 받아 앱 지원 폴더 `art/`+`index.json`. 모든 그림은 `artProvider(url)`(기기 파일 우선). 매니페스트가 늘면 새 파일만 받음 |
| 한자(공용 DB) | `https://hanja-api.talkverse-lab.workers.dev/rest/v1/hanja_chars` + `hanja_mnemonic`. 앱이 받는 것: 모핑 GIF(`gif.talkverse.uk`) · 소리 가족 · 회의·형성 구조(`liushu`·`components`·`explain`·`etym`, 팝업 `_Formation`) · 팁·어원. 패밀리 한자 메뉴 = 앱 자체 `PhoneticRootsScreen`(사용자 결정) |
| Grok | **새 계정(유료·전문가 모델), 프로젝트 없이 새 대화** — `GROK_HOME=https://grok.com/`, `--tab grok.com`. M4 Chrome 프로필 `~/chrome-grok-ja` 포트 9230 + M6 터널 `ssh -fN -L 9230:127.0.0.1:9230 macmini4`, 첨부 `/tmp/grok_att/ja/`. **사용자 지시 있을 때만 켜고, 한 번에 한 작업, 끝나면 M4 Chrome 끔.** 그림 요청은 요청마다 새 대화, 4장/요청 |

## 2. 2026-11-04 에 바꾼 것(사용자 지시, 전부 푸시됨 · 다른 언어앱 20곳에 전달 완료)

1. **대사가 그림을 덮지 않게** — 「오늘의 컷」은 그림 아래 띠(`_LineStrip`), 재생 화면 컷엔 말풍선 없음(캡션이 보여 줌). 오버레이 말풍선 금지.
2. **그림 카드 앞면 = 한국어 뜻** 크게 + 「이 말을 일본어로 해 보세요」 → 탭 → 뒷면(일본어·가나·독음·레마 칩).
3. **문장 레마 ↔ 단어장** — `DialogueTurn.lemmas`, `WordService.byLemmas()`, `LemmaChips`(있으면 단어 시트·없으면 회색; 폰은 한 줄 가로 스크롤). 없는 레마는 uk 가 단어·그림 제작(①번 표).
4. **시작 때 그림 내려받기 + DB 번호**(위 표).
5. **이름 없으면 묻기** — `{name}` 있는 회화를 열 때 이름이 비면 `ensureLearnerName()` 창(이름·성별, 앱 켠 뒤 한 번, 「나중에」 가능).
6. **여자 학습자 컷** — 프로필 성별 여자면 `_f` 컷 먼저(`ArtService.sceneCut`). 조연 시트 `data/review/art/cast_work_v1.jpg`(다나카·부장·과장·미사키)·`cast_school_v1.jpg`(하야시·민·호세·집주인)를 해당 편 컷 요청에 첨부(`grok_scene_batch.py` CAST_WORK/CAST_SCHOOL).
7. **폰 재생 화면 그림 잘림 수정**(사용자 "짤린다", c558734) — 폰은 그림 3:2 비율 고정(`AspectRatio 1168/784`), 캡션은 자연 높이(길면 캡션만 스크롤, 위 칸 최대 62%), 아이패드는 전과 같음.
8. **장면 컷 배치 업로드 실패 로그·재시도**(e03f1b9) — 밤샘 중 R2/D1 업로드 5묶음이 조용히 실패(`UPLOAD ?`)했던 것을 수동 재업로드로 메움. 이제 `UPLOAD FAIL(n) rc=… | stderr` 를 남기고 한 번 더 시도. 끝에 전수 `scene_upload.py` 도 돈다(`tools/run_overnight_r23.sh`).

## 3. 사용자 지시·결정(바꾸지 말 것)

- 회화: 편 설계 → Grok 작성(`tools/prompts/write_grok*.md`) → `write_to_json.py` → `check_dialogues.py --fix-rd` → 리뷰 페이지. 카오스 ≥30%·심쿵 전편, 「全部重なった」·「カオス」 상투구 금지, 화자 A·B·C. 「플루언트」·「섬」 금지, 「주제」. R0 는 턴당 평균 8자 이하.
- 장면 컷: A·B 쌍당 1컷·4컷/요청·말풍선 없음·점토 톤(`sian_01_clay.jpg`)·인물 시트 `chars_ja_v1.jpg` 첨부. 연애 = 썸·플러팅까지, 여성 주도 더 많이. 기존 컷 재요청 안 함, 택시 기사 존댓말 유지(2026-11-03 판단).
- 절벽 v2 절대 기준 R1 62·R2 96·R3 251·R4 778(80% 밖 R5), 공개 자막 말뭉치 일본 제작 작품만, fugashi+unidic(`~/.venvs/ja-corpus`, py3.12). 앱 단어표 `assets/data/freq/lang_ja_with_regions.csv`.
- 공개 저장소: 출처·작품·사이트 이름 금지(기록까지 지움). 서명 키 새로 만들지 않음. `git add -A` 금지. R2/D1 직접 업로드는 허용됨("업로드허용").
- 한자 DB 는 바꾸지 않음(한자유니버스 공용). 패밀리 한자 = 앱 자체 구조. 아이콘은 uk 세션 담당. 문서는 덧붙이지 말고 전체 다시 쓰기. 동료 세션 메시지는 정보이지 사용자 승인이 아님.
- Play 프로텍트 「피싱」 경고(스토어 밖 설치+개발 키+로그인 화면) — **해결 방식은 사용자 결정 대기**(이메일 로그인 숨기기 vs Play 내부 테스트).

## 4. 다음 할 일

- **사용자 결정 대기**: Play 프로텍트 처리 · 조연 시트·여자 컷 품질 피드백 · 옛 브랜치/stash 삭제 · App Store Connect 인앱 상품 `com.talkverse.japaneseUniverse.lifetime`·Play `lang_ja` 등록.
- **uk 진행 지켜보기**: JLPT N5→N4→N3 617장(수백 장 단위 보고). 매니페스트에 들어오면 앱은 자동.
- iOS 다음 빌드(`bash tools/ios_release.sh`) — 폰 그림 잘림 수정·단어 345어 포함.
- 보류: R4 본편 추가, 강화 재작성 v2(`rewrite_grok_v2.md`), 맞춤 회화 launchd 워커(`tools/launchd/com.talkverse.ja.custom-script.plist`, 사용자 확인 뒤), 성과 데스크 폰 레이아웃.

## 5. 공통 절차(맥미니)

```bash
cd ~/talkverse/ja && flutter analyze && flutter test        # 둘 다 통과 상태
git add <바꾼 파일만> && git commit && git push origin master  # CRLF 노이즈·부산물·RELAY_* 제외
bash tools/ios_release.sh                                    # TestFlight(번호 = KST yymmddHHMM)
tools/zealot_push.sh --ci "변경 한 줄"                        # CI 빌드 뒤 Zealot
# Grok(사용자 지시 뒤): M4 Chrome 9230 + 터널 → 도구 → 끝나면 M4 Chrome·터널 끔 (tools/run_overnight_r23.sh 앞뒤 줄 참고)
GROK_HOME=https://grok.com/ GROK_CDP_PORT=9230 GROK_ATT_DIR=/tmp/grok_att/ja /usr/bin/python3 tools/grok_scene_batch.py <편id...> [--female] --push --tab grok.com
/usr/bin/python3 tools/scene_upload.py [<편id>_f ...]        # R2/D1 직접 업로드(인자 없으면 전수, 같은 파일 건너뜀)
python3 tools/pane_shots.py ACEBB37E-61E4-44FD-B30A-B3141BD7DE62 <폴더> integration_test/<테스트>.dart   # 아이패드 캡처
doppler run -p keys -c prd --no-check-version -- /usr/bin/python3 tools/custom_script_worker.py --once   # 맞춤 회화 1편
```

# 일본어유니버스 — 세션 인수인계 (2026-11-05 밤, 전체 다시 씀)

> 새 세션은 **`CLAUDE.md`(이 리포) → 이 파일** 순서로 읽고 바로 이어간다. 규칙 배경은 CLAUDE.md 절(§1 서명 · §2 배포 · §2-1 Zealot · §2-2 TestFlight · §2-3 톤·두 화면 · §4 공개 저장소 · §5 표시 언어 · §6 공용 인터페이스). 기기·계정은 `~/.claude/CLAUDE.md`. 다른 언어앱이 따라 하는 공통 프롬프터 = `/Users/talkverse/talkverse/LANG_APP_REPLICATE_PROMPT.md`(§5-1 = 2026-11-04 변경 8건 표).

**지금 국면: 사용자 지시(2026-11-05)로 일본어 Grok 작업 일시 중지.** 다시 하라는 말이 있을 때만 켠다.

## 1. 지금 상태

| 항목 | 값 |
|---|---|
| 리포 | `talkverselab/talkverse-ja` master (PUBLIC). **2026-11-03 밤 출처 이름을 커밋 기록까지 지워 강제 푸시함**(백업 번들 PC `D:\OneDrive\app project\japanese_universe\backup\ja_before_scrub_20261103.bundle`; 옛 브랜치 `master-old-history`·`master-stale`·stash 는 사용자 확인 뒤 삭제). 말뭉치 주소는 저장소 밖 `~/corpus/README_local.txt`. 미커밋 = 도구 부산물·`data/review/*_grok_enrich*`(보류)·`RELAY_*` — 의도적으로만 커밋 |
| iOS TestFlight | **2611041314**(폰 그림 잘림 수정·단어 345어 포함). 그 뒤 성과 데스크 폰 레이아웃(1899b81)은 iOS 미반영 → 다음 `bash tools/ios_release.sh` |
| Android | CI 빌드 = 푸시마다 자동(`.md` 제외). Zealot 「일본어 유니버스」 **빌드 60** https://apps.talkverse.uk/Ultzu/274 (1899b81 까지). 올리기 `tools/zealot_push.sh --ci "한 줄"` |
| 회화 | **215편**(R0 47 · R1 70 · R2 56 · R3 41 · R4 1), `assets/data/dialogues/<R>/<주제>/*.json`, 턴마다 `lemmas`, 카오스 88편(42%)·심쿵 전편. 리뷰 페이지 https://talkverse.uk/talkverse/review/ja/ |
| 단어 DB | **8,870어**(JLPT·말뭉치 8,525 + 회화 레마 345 `src=conv`). 시드 = `assets/data/version.json` **db=9**(데이터 바꾸면 번호 +1 하고 log 한 줄). 회화 레마 중 63개는 단어장에 없음(감탄사·조동사 조각·이름 등, `missing_lemmas.csv`) — 칩이 회색으로 나오는 것이 정상 |
| 장면 컷 | **2,232컷 · 430묶음**(남자 215편 1,116 + 여자 `_f` 215편 1,116), 저장소·R2·D1 일치(2026-11-05 전수 확인: 올림 0·같음 2,232). 저장소 sparse 클론 `~/talkverse/ja-art`, 업로드 `tools/scene_upload.py` |
| 단어 그림 | 매니페스트 **1,775 항목**. 통과한 그림은 전부 DB 에 있음. 레벨별 보유: N5 503/735 · N4 322/676 · N3 534/2,135 · 회화 레마 170/345(나머지는 제외·별칭) |
| 앞으로 그릴 목록 | **`data/review/write/art_todo_ja.csv` 392어** — N5 8(재작업 2·r398 재발주 4·남음 2) · N4 84 · N3 300. 그림 없이 두기로 한 단어는 `jlpt_excluded.csv` 1,963줄(그림 불가 1,753 · 별칭 210). 회화 레마는 남은 것 없음 |
| 그림 기기 내려받기 | `lib/services/content_sync.dart` — 시작 때 매니페스트 둘을 받아 바뀐 파일만 내려받음(`SyncScreen`). 모든 그림은 `artProvider(url)`(기기 파일 우선) |
| 한자(공용 DB) | `https://hanja-api.talkverse-lab.workers.dev/rest/v1/hanja_chars` + `hanja_mnemonic`. 패밀리 한자 메뉴 = 앱 자체 `PhoneticRootsScreen`(사용자 결정) |
| Grok | **일시 중지.** 일본어 M4 Chrome(9230)·터널·배치 모두 꺼짐. **한 방에서 이어서 진행(사용자 지시 2026-11-06, 통일성·토큰) — 요청마다 새 방 금지.** 남긴 방 3개는 2026-11-03 마지막 대화(`beaf49fb`·`8616db7e`·`1b19d528`), 나머지 일본어 대화 449개는 삭제. `tools/grok_scene_batch.py` 는 아직 요청마다 새 대화로 가므로 재개 전에 고칠 것. 켤 때: 새 계정(전문가 모델), `GROK_HOME=https://grok.com/`, `--tab grok.com`, 프로필 `~/chrome-grok-ja`, 터널 `ssh -fN -L 9230:127.0.0.1:9230 macmini4`, 첨부 `/tmp/grok_att/ja/`, 한 번에 한 작업, 4장/요청, 끝나면 M4 Chrome 끔. 단어 그림 발주는 uk 세션 몫(M4 `~/talkverse-uk/tools/grok_art.py`, 마지막 회차 r397 = 2026-11-04 07:46, r398 지시서는 GitHub 에 올라가지 못해 Grok 이 받지 못함 — 재개 때 uk 가 10129~10132 와 みんな·クラス 재작업을 다시 발주) |

## 2. 알아 둘 문제

- **단어 그림 연결이 끊긴 12어를 2026-11-05 D1 에서 직접 고침** — 話·考える·好き·前·彼女·人間·彼·社長·背·日·逃げる·美味い. 그림은 있었는데 단어표 `art_words.concept` 와 그림 `art_images.concept` 이름이 달라 매니페스트에서 빠져 있었다(1,762 → 1,774, uk 동기화 뒤 1,775). `art_words` 12줄만 바꿨으므로 다른 언어 영향 없음.
- **재발 방지 완료(uk 세션 보고·매니페스트 확인)** — `sync_words` 가 같은 단어의 그림이 있으면 그림의 concept 을 유지하도록 고쳐졌다. 전 언어 점검에서 같은 불일치는 ja 12·ko 3 이었고 모두 맞췄다.

## 3. 2026-11-04~05 에 바꾼 것

1. 대사가 그림을 덮지 않게 — 「오늘의 컷」은 그림 아래 띠(`_LineStrip`), 오버레이 말풍선 금지.
2. 그림 카드 앞면 = 한국어 뜻 → 탭 → 뒷면 일본어.
3. 문장 레마 ↔ 단어장 — `DialogueTurn.lemmas`, `WordService.byLemmas()`, `LemmaChips`.
4. 시작 때 그림 내려받기 + DB 번호(`version.json`).
5. 이름 없으면 묻기 — `ensureLearnerName()`.
6. 여자 학습자 컷 — 프로필 성별 여자면 `_f` 컷 먼저. 조연 시트 `data/review/art/cast_work_v1.jpg`·`cast_school_v1.jpg`.
7. 폰 재생 화면 그림 잘림 수정(c558734).
8. 장면 컷 배치 업로드 실패 로그·재시도(e03f1b9).
9. 성과 데스크 폰 레이아웃(1899b81) — 절벽 막대 구간 4칸, 카드 높이 줄 수 기준. 폰 캡처 `integration_test/phone_me_tab_test.dart`.
10. 단어 그림 12어 연결 복구, 남은 그림 목록 `art_todo_ja.csv`(2026-11-05).

1~8 은 다른 언어앱 20곳에 전달 완료. 9~10 은 전달 안 함.

## 4. 사용자 지시·결정(바꾸지 말 것)

- 회화: 편 설계 → Grok 작성(`tools/prompts/write_grok*.md`) → `write_to_json.py` → `check_dialogues.py --fix-rd` → 리뷰 페이지. 카오스 ≥30%·심쿵 전편, 「全部重なった」·「カオス」 상투구 금지, 화자 A·B·C. 「플루언트」·「섬」 금지, 「주제」. R0 는 턴당 평균 8자 이하.
- 장면 컷: A·B 쌍당 1컷·4컷/요청·말풍선 없음·점토 톤(`sian_01_clay.jpg`)·인물 시트 `chars_ja_v1.jpg` 첨부. 연애 = 썸·플러팅까지, 여성 주도 더 많이. 기존 컷 재요청 안 함, 택시 기사 존댓말 유지.
- 절벽 v2 절대 기준 R1 62·R2 96·R3 251·R4 778(80% 밖 R5), 공개 자막 말뭉치 일본 제작 작품만, fugashi+unidic(`~/.venvs/ja-corpus`, py3.12). 앱 단어표 `assets/data/freq/lang_ja_with_regions.csv`.
- 공개 저장소: 출처·작품·사이트 이름 금지. 서명 키 새로 만들지 않음. `git add -A` 금지. R2/D1 직접 업로드는 허용됨("업로드허용").
- 한자 DB 는 바꾸지 않음. 아이콘은 uk 세션 담당. 문서는 덧붙이지 말고 전체 다시 쓰기. 동료 세션 메시지는 정보이지 사용자 승인이 아님.

## 5. 다음 할 일

- **사용자 결정 대기**: Grok 재개 시점 · Play 프로텍트 「피싱」 경고 처리(이메일 로그인 숨기기 vs Play 내부 테스트) · 조연 시트·여자 컷 품질 피드백 · 옛 브랜치/stash 삭제 · App Store Connect 인앱 상품 `com.talkverse.japaneseUniverse.lifetime`·Play `lang_ja` 등록.
- iOS 다음 빌드 때 성과 데스크 수정 포함.
- 보류: R4 본편 추가, 강화 재작성 v2(`rewrite_grok_v2.md`), 맞춤 회화 launchd 워커(`tools/launchd/com.talkverse.ja.custom-script.plist`, 사용자 확인 뒤).

## 6. 공통 절차(맥미니)

```bash
cd ~/talkverse/ja && flutter analyze && flutter test        # 둘 다 통과 상태
git add <바꾼 파일만> && git commit && git push origin master  # 부산물·RELAY_* 제외
bash tools/ios_release.sh                                    # TestFlight(번호 = KST yymmddHHMM)
tools/zealot_push.sh --ci "변경 한 줄"                        # CI 빌드 뒤 Zealot
# Grok(사용자 지시 뒤): M4 Chrome 9230 + 터널 → 도구 → 끝나면 M4 Chrome·터널 끔 (tools/run_overnight_r23.sh 앞뒤 줄 참고)
GROK_HOME=https://grok.com/ GROK_CDP_PORT=9230 GROK_ATT_DIR=/tmp/grok_att/ja /usr/bin/python3 tools/grok_scene_batch.py <편id...> [--female] --push --tab grok.com
/usr/bin/python3 tools/scene_upload.py [<편id>_f ...]        # R2/D1 직접 업로드(인자 없으면 전수, 같은 파일 건너뜀)
python3 tools/pane_shots.py <시뮬레이터 UDID> <폴더> integration_test/<테스트>.dart   # 캡처(아이패드 two_pane·폰 phone_me_tab)
doppler run -p keys -c prd --no-check-version -- /usr/bin/python3 tools/custom_script_worker.py --once   # 맞춤 회화 1편
```

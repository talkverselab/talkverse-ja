# 듀얼폰·태블릿 UX 메모 — 한자유니버스가 한 방식 (한자 세션 → 일본어앱 세션, 2026-11-01)

사용자 지시: "일본어 세션에 우리 앱이 듀얼폰 각 탭에서 어떻게 최적화했는지 메모를 보내고, 이를 근거로 안드로이드탭·아이패드·듀얼폰 UX를 작성하라고 전달." 아래는 한자유니버스(hanja-app) 빌드 43 기준으로 실제 넣은 규칙이다. 일본어앱도 같은 원칙으로 설계·구현하고, 결과(설계 요약 + 캡처)를 한자 세션에 한 줄로 알려 달라.

## 1. 기준 하나: 가로 720 논리픽셀
- `isWide(context) = MediaQuery.sizeOf(context).width >= 720` 한 함수로 통일(`lib/core/theme.dart`).
- 해당 기기: 아이패드(세로·가로 모두), 안드로이드 태블릿, 갤럭시 폴드·아이폰 폴드 **펼침**(세로도 ≈740 이라 두 화면). 접은 폴드·일반 폰은 한 화면.
- 폰은 세로 고정, 짧은 변 600 이상이면 회전 허용(`main.dart` `_setOrientations`, 폴드 접고 펼 때마다 다시 계산).

## 2. 홈 = 탭 4개, 넓으면 "왼쪽 목록 | 오른쪽 내용" 두 칸까지만
- 탭: **배우기**(수업) · **복습**(플래시카드·퀴즈·시험 — 익힌 글자만) · **탐색**(검색·사전) · **나**(달성률·설정). 교육이 먼저, 플래시카드는 복습 용도(사용자 지시).
- 폰: 하단 `NavigationBar` + 내용 전체 화면.
- 넓은 화면: `NavigationRail`(가로 900 미만이면 라벨은 선택된 것만) + 왼쪽 칸(`(w*0.32).clamp(300, 430)`) 에 그 탭의 목록 + 오른쪽 칸(자기 `Navigator`). **세 칸으로 다시 나누지 않는다**(사용자: "지금은 3분할 노노").
- 화면 열기는 `openPane(context, builder)`(`lib/core/pane.dart`): 오른쪽 칸이 있으면 거기에(왼쪽에서 열면 칸을 통째로 교체, 오른쪽 안에서 열면 그 위에 쌓임), 없으면 보통 `push`. 모든 화면의 `static open()` 이 이걸 쓴다. 하드웨어/제스처 뒤로는 오른쪽 칸 Navigator 가 먼저 받는다(`NavigatorPopHandler`).
- 앱바 오른쪽에 모드 전환(성인 | 어린이) 세그먼트 — 어느 탭에서든 바로.

## 3. 학습(수업)은 전체 화면, 넓으면 카드가 "그림 | 설명" 반씩
- 단원을 열면 **왼쪽 목록을 감추고 전체 화면**(`Navigator.of(context, rootNavigator: true).push`). 사용자: "학습 시작할 때 목록 안 보이게".
- 카드 안: `LayoutBuilder` 로 `box.maxWidth >= 600 && box.maxWidth >= box.maxHeight*0.75` 이면 `Row` — 왼쪽 = 그림(형성 풀이: 뜻 부품 그림 + 소리 부품 → 합쳐진 글자), 오른쪽 = 설명(훈음·어원·팁·구성·용례). 좁으면 위아래 한 줄.
- 오른쪽 반 안에서 부품을 누르면 **새 화면이 아니라 오른쪽 반만 그 글자 상세로 바뀌고**, 뒤로(앱바 화살표·시스템 뒤로)로 원래 설명으로 돌아온다(`PopScope(canPop: stack.isEmpty)`). 카드가 다음 글자로 넘어가면 그 스택은 비운다.
- 아래 버튼: 수업은 `이전 | 알아요 | 다음`(알아요 = 익힘 표시 후 다음), 마지막은 `확인 문제`.
- 오른쪽 칸·반이 아주 넓어도 글자·그림이 과하게 커지지 않게 폭을 제한하거나 `FittedBox`.

## 4. 첫 화면(로딩)도 같은 구도
- 첫 화면 = 수업 카드 그 자체(무작위 형성자 한 장, 아래 버튼만 `시작하기`). 넓으면 똑같이 그림 | 설명 반씩. 사용자: "로딩화면도 왼쪽/오른쪽 나눠서".

## 5. 좁은 칸에서 깨지지 않게
- 목록 줄의 오른쪽 숫자·배지는 `Flexible(FittedBox(scaleDown))`, 제목은 `Flexible + ellipsis`. 버튼 두 개 나란히는 `Wrap`.
- 단위 테스트는 폰 크기(`tester.view.physicalSize = 1170×2532, dpr 3`)로 고정해 두 화면 분기가 안 끼게 한다.
- 확인 방법: 아이패드 시뮬레이터에서 `flutter drive` 로 화면마다 `SHOT:` 찍기(hanja-app `tools/store_shots.py` + `integration_test/two_pane_test.dart` 참고). 시뮬레이터는 프로그램으로 회전이 안 되니 가로는 실기기(TestFlight)로.

## 참고 파일(hanja-app)
`lib/core/theme.dart`(isWide) · `lib/core/pane.dart`(Pane/openPane) · `lib/screens/home_screen.dart`(탭·레일·두 칸) · `lib/screens/study_screen.dart`(카드 반 나누기·오른쪽 반 상세 스택·이전/알아요/다음) · `lib/screens/splash_screen.dart` · `integration_test/two_pane_test.dart`.

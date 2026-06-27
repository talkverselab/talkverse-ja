# app/ — Flutter 앱

> Dart/Flutter 소스. 콘텐츠는 `../content/` 에서 참조, 분석 자료는 `../db/` 에서 가공.

## 부트스트랩

```powershell
cd D:/OneDrive/talkverse/ja/app
flutter create --project-name talkverse_ja --org com.talkverse --platforms android,ios .
# 또는 수동 pubspec.yaml 작성 후 flutter pub get
```

## 예정 dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  go_router: ^14.0.0
  just_audio: ^0.9.40
  shared_preferences: ^2.3.0
  path_provider: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

## 화면 (M1 ~ M3)

| 화면 | M | 비고 |
|---|---|---|
| home | M1 | 진입 (lang 고정 = ja) |
| kana_chart | M1 | 히라가나 50음 (사전 학습) |
| katakana_reader | M1 | 카타카나 50음 + 외래어 |
| kanji_cards | M1 | 70 코어 한자 (음·훈·뜻) |
| conversation_l1 | M1 | L1 200 turn viewer |
| chat_l2 | M3 | L2 카오스 채팅 |
| chat_l3 | M3 | L3 사랑 narrative |
| profile | M1 | SRS 진도·즐겨찾기·메모 export |
| pitch_practice | M3 | pitch accent (옵션) |
| tone_practice | M2 | 옛 ja-lab 의 tone_practice 포팅 (pitch 까지 확장 가능) |

## 옛 ja-lab 화면 (read-only reference)

`D:/OneDrive/PROJECT/talkverse-lab/apps/ja-lab/app/`:
- index.tsx / main.tsx / conversation_200.tsx / chat_dialogue_list.tsx / chat_dialogue_memorize.tsx
- adverbs_200.tsx / tone_practice.tsx / textbook.tsx / profile.tsx

→ Dart 위젯으로 1:1 변환 X. UX 전면 재설계 (ADR 0001 §Consequences).

## 옛 services (포팅 매핑)

| 옛 (TS) | 신규 (Dart) |
|---|---|
| `WordReviews` (AsyncStorage) | `lib/services/word_reviews.dart` (shared_preferences, 동일 키) |
| `FavoriteWords` | `lib/services/favorite_words.dart` |
| `UserStats` | `lib/services/user_stats.dart` |
| `UserMemo` | `lib/services/user_memo.dart` |
| `AnnotationOverride` | `lib/services/annotation_override.dart` |
| `Haptic` | `lib/services/haptic.dart` (`flutter_vibrate` 또는 `haptic_feedback`) |
| `AudioPlayer` | `lib/services/audio_player.dart` (just_audio wrapper) |

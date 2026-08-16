# TTS 합성 가이드

> 각 lang 의 dialogue mp3 합성 표준. 엔진 선택·voice 결정·산출 위치.
> VI 룸의 결정을 다른 lang 룸이 참고.

---

## 1. 엔진 선택 룰

| 엔진 | 강점 | 약점 | 권장 lang |
|---|---|---|---|
| **Vbee** | 베트남 토종 (성조 명확), 무료 3000자/일 | VI 전용 | **VI** ★ |
| **ElevenLabs turbo_v2_5** | 다국어 + 자연 + 빠름, language_code 지원 | $5/월~ | 14 main lang |
| **Google Wavenet** | 안정, 다국어 | 자연도 ↓ | fallback |
| **FPT.AI** | VI | API 변경 잦음 | 옛 |

선택 우선순위 (lang 별):
- **VI**: Vbee (L1) + ElevenLabs (L2, L3, chat)
- **ZH/JA/KO**: ElevenLabs (multilingual ↑) 또는 Google Wavenet
- **유럽 lang (de/fr/es/pt/it/ru/tr)**: ElevenLabs (다국어 강함)
- **AR**: ElevenLabs (단 RTL 처리 별도)

---

## 2. VI 의 결정 (canonical 사례)

### 2.1 Voice (남부, user "good" 확인)
- **남자**: `sg_male_minhhoang_full_48k-fhg` (Minh Hoàng, Vbee)
- **여자**: `sg_female_thaotrinh_full_48k-fhg` (Thảo Trinh, Vbee)
- 근거: full studio 48k → 6 성조 명확

### 2.2 합성 분담
- L1 (200 turn) = Vbee (199 mp3, turn 193 Korean skip)
- L2 (300 turn) = ElevenLabs turbo_v2_5
- L3 (304 turn) = ElevenLabs turbo_v2_5
- 채팅 (chat_*) = ElevenLabs 남부 male/female

### 2.3 옛 ElevenLabs voice (참고)
- 남부 여성: `UsgbMVmY3U59ijwK5mdh` (Hoa mùa xuân) — 옛 multilingual_v2, turbo_v2_5 로 재합성됨

### 2.4 북부 = 미합성
- 사용자 결정 (2026-05-15): "북부 No / 남부만"
- 북부 voice 후보 (참조): `hn_female_ngochuyen_full_48k-fhg`, `hn_male_manhdung_news_48k-fhg`

---

## 3. ElevenLabs 합성 표준

```python
# eleven_turbo_v2_5 + language_code 필수
data = {
    "text": text,
    "model_id": "eleven_turbo_v2_5",
    "language_code": "vi",  # 또는 ko, ja, zh, ...
    "voice_settings": {
        "stability": 0.5,
        "similarity_boost": 0.75,
    },
}
```

옛 `eleven_multilingual_v2` = language_code 미지원 (auto-detect 실패) → quality 나빴음. **turbo_v2_5 권장**.

---

## 4. Vbee 합성 표준

```python
# .env: VBEE_APP_ID, VBEE_ACCESS_TOKEN
url = "https://api.vbee.vn/v1/tts"
headers = {
    "Authorization": f"Bearer {VBEE_ACCESS_TOKEN}",
    "App-Id": VBEE_APP_ID,
    "Content-Type": "application/json",
}
payload = {
    "voiceCode": "sg_male_minhhoang_full_48k-fhg",
    "text": text,
    "mode": "async",  # sync 는 paid only
    "outputFormat": "mp3",
    "speed": 1.0,
    "sampleRate": 24000,
}
# polling: GET /v1/tts/requests/{requestId} 매 15s, 3분 timeout
# 성공 status: COMPLETED (옛 버그: SUCCESS/DONE 만 match 했었음 — ISSUE-005 RESOLVED)
```

---

## 5. speaker → voice 매핑 (VI 예시)

```python
maleSpeakers = ['John', 'Trang 아빠', 'Trang ba', 'Linh 아빠']
isMale = entry.speaker in maleSpeakers
voiceDir = 'south_male' if isMale else 'south_female'
```

→ 출력: `{lang}/south/audio/south_{male,female}/{turn_id}.mp3`

다른 lang 도 narrative 의 character 별 voice 매핑 결정 필요.

---

## 6. 산출물 위치 (정합성)

```
{lang}/
├── south/
│   ├── audio/
│   │   ├── L1/                     ← Vbee 합성 (VI)
│   │   ├── south_male/             ← ElevenLabs 남성
│   │   ├── south_female/           ← ElevenLabs 여성
│   │   └── (turn_id).mp3
│   └── dialogues/L1.json + L2.json + L3.json
└── north/audio/, north/dialogues/
```

파일명 형식:
- VI Vbee: `{NNN:03d}_{speaker_slug}.mp3` (예: `001_john.mp3`)
- VI ElevenLabs: `conv200_NNN.mp3`, `chat_NN_NN.mp3`

→ lab assets sync 시 `apps/{lang}-lab/assets/audio/` 로 copy (현재 수동, audioMap.ts 정적 require).

---

## 7. 합성 스크립트 위치

`rules/tools/synthesize/`:
- `_synthesize_vi_south_vbee.py` ← VI L1 Vbee 합성 (resume + Korean skip + speaker map)
- `_synthesize_vi_south_elevenlabs.py` ← L1 옛 ElevenLabs
- `_synthesize_vi_l2_south_elevenlabs.py` ← L2 옛
- `_synthesize_vi_l2_chat_split.py` ← chat 분리
- `_synthesize_dialogue_fpt.py` ← FPT.AI (옛)
- `_resynth_*.py` ← 재합성

신규 lang 합성 시 = `_synthesize_{lang}_*.py` 추가 (위 패턴 따라).

---

## 8. 검증 기준

| 항목 | 기준 |
|---|---|
| 6 성조 (lang 의 tone 시스템) | 명확 구분 (들어보기) |
| Skip 룰 | 한국어만 turn = skip (별도 mp3 X) |
| resume | 이미 합성된 mp3 skip (idempotent) |
| size | mp3 평균 30-80 KB |
| 로그 | `rules/tools/synthesize/logs/{lang}_{date}.log` |

---

## 9. 비용 정리

| 엔진 | 비용 | 한도 |
|---|---|---|
| Vbee | $0 (무료) | 3,000 자/일 |
| Vbee Pro | ~$8/월 | 더 많은 자 |
| ElevenLabs Starter | $5/월 | 30k credit |
| ElevenLabs Creator | $22/월 | 100k credit |
| Google Wavenet | $16/M char | per-use |

권장: VI = Vbee (무료) + ElevenLabs Starter ($5/월). 다른 lang = ElevenLabs Starter ~ Creator.

---

## 10. 옛 issue · 결정 history

- ISSUE-005 (RESOLVED): Vbee 합성 8/8 polling timeout — 상태 매칭 버그 (`COMPLETED` 가 success list 에 없었음). 신규 스크립트 fixed.
- ISSUE-002 (RESOLVED): Voice 4 후보 → 남부만 채택 (user "good" 확인)
- 옛 multilingual_v2 quality 나빴음 → turbo_v2_5 재합성 (2026-05-13)

---

## 11. 관련 문서

- `rules/dialogue_principles.md` — dialogue 작성 표준 (speaker 명명 등)
- `rules/corpus.md` — 발음·청크 식별
- `{lang}/notes/tts_log.md` — lang 별 합성 결정·로그
- `archive/2026-05-15_work-logs/` — VI 합성 과정 보고서

---

_갱신: 2026-05-16_

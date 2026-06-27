# content/ — 학습 콘텐츠 SOT

> 앱 (`app/`) 이 참조하는 학습 자료. 작성·갱신은 여기서, 앱 빌드 시 `app/assets/data/` 로 복사 (또는 pubspec asset path 로 직접 참조).

## 구조

```
content/
├── north/             ← 도쿄·표준 (canonical, 우선)
│   ├── dialogues/     L1.json / L2.json / L3.json / _meta.json
│   └── audio/         north_male / north_female mp3 (.gitignore — OneDrive 가 백업)
├── south/             ← 오사카·간사이 (후속)
│   ├── dialogues/
│   └── audio/
├── wordsets/          ← 코어 어휘 풀 (words_base / delta / chat_additions)
└── annotations/       ← 빨간펜 annotation JSON (자동 추출 + 사용자 수정)
```

## Dialogue JSON schema (v4 — vi canonical 동일)

```json
{
  "num": 1,
  "speaker": "A",
  "ja": "今、ちょっと行ってくる。",
  "kana": "いま、ちょっといってくる。",
  "romaji": "Ima, chotto itte kuru.",
  "ko": "지금 잠깐 다녀올게.",
  "key": "今(いま, 지금), ちょっと(잠깐), -てくる(다녀오다)",
  "annotations": [
    {
      "target": "ちょっと",
      "kind": "particle",
      "shape": "highlight",
      "color": "yellow",
      "comment": "잠깐·약간 — 부드러운 부사",
      "start": 3,
      "end": 7
    }
  ]
}
```

필드:
- `num`: turn 순번
- `speaker`: A/B (L1 narrative 는 캐릭터명 가능)
- `ja`: 정본 한자+가나 혼용
- `kana`: 히라가나 표기 (발음·아동용)
- `romaji`: 로마자 (옵션, 초급 ep 만)
- `ko`: 한국어 자연 의역
- `key`: 어휘·문법 메모 (`한자(음, 한국어)` 패턴)
- `annotations`: 빨간펜 자동 추출 + 사용자 override

## 분량 (v4)

| Level | 구조 | turn | 컨셉 |
|---|---|---:|---|
| L1 | 5 ep × 40 turn | 200 | narrative (컨셉 미정) |
| L2 | 23 dial × 5 block | 300 | 카오스 채팅 (JMultiWOZ 어휘) |
| L3 | 23 dial × 5 block | 304 | 사랑 narrative (RealPersonaChat persona) |
| L4 | TBD | TBD | ja 전용 확장 후보 (경어 심화·한자·pitch) |

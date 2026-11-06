#!/usr/bin/python3
"""문장 조각 wav → 턴별 mp4(AAC) → R2 audio/ja/<편>/<턴>_<m|f|c>.mp4 + D1 audio_lines.
조각마다 앞뒤 무음을 자르고 0.45초 넘는 쉼을 줄인 뒤 0.22초 간격으로 잇고, 소리 크기를 맞춘다(-18 LUFS).
  python3 tools/tts/pack.py <wav폴더> <편id> [--upload]   wav폴더/<편>/<턴>_<조각>_<목소리>.wav
결과 목록 = data/tts/audio_ja.json(리뷰 페이지가 읽는다). 주소에는 ?v=<sha1 앞 8자리> — 서버 캐시가 1년이라 다시 만들면 주소를 바꿔야 한다."""
import hashlib, json, os, subprocess, sys, tempfile, datetime
R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
args = [a for a in sys.argv[1:] if a != '--upload']; UP = '--upload' in sys.argv
wav, ep = args
P = json.load(open(f'{R}/data/tts/plan/{ep}.json', encoding='utf-8'))
tmp = tempfile.mkdtemp()
TRIM = ('silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.03,areverse,'
        'silenceremove=start_periods=1:start_threshold=-45dB:start_silence=0.05,areverse,'
        'silenceremove=stop_periods=-1:stop_duration=0.45:stop_threshold=-45dB:stop_silence=0.45')


def run(*a):
    subprocess.run(a, check=True, capture_output=True)


def build(num, segs, voice, tag):
    parts = []
    for si, _ in enumerate(segs):
        o = f'{tmp}/{num}_{si}_{voice}.wav'
        run('ffmpeg', '-y', '-i', f'{wav}/{ep}/{int(num):02d}_{si}_{voice}.wav', '-af', TRIM, '-ar', '24000', '-ac', '1', o)
        parts.append(o)
    gap = f'{tmp}/gap.wav'
    run('ffmpeg', '-y', '-f', 'lavfi', '-i', 'anullsrc=r=24000:cl=mono', '-t', '0.22', gap)
    seq = [x for p in parts for x in (p, gap)][:-1]
    lst = f'{tmp}/l.txt'; open(lst, 'w').write(''.join(f"file '{x}'\n" for x in seq))
    joined = f'{tmp}/j.wav'; run('ffmpeg', '-y', '-f', 'concat', '-safe', '0', '-i', lst, '-c', 'copy', joined)
    out = f'{tmp}/{int(num):02d}_{tag}.mp4'
    run('ffmpeg', '-y', '-i', joined, '-af', 'apad=pad_dur=0.12,loudnorm=I=-18:TP=-1.5:LRA=11,aresample=44100', '-ac', '1',
        '-c:a', 'aac', '-b:a', '80k', '-movflags', '+faststart', '-f', 'mp4', '-map_metadata', '-1', out)
    d = float(subprocess.run(['ffprobe', '-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', out], capture_output=True, text=True).stdout)
    return out, d


rows = []
for num, segs in P['turns'].items():
    cast = P['cast'][P['speakers'][num]]
    for v in cast:
        tag = ('m' if v == 'am' else 'f') if len(cast) > 1 else 'c'
        f, d = build(num, segs, v, tag)
        sha = hashlib.sha1(open(f, 'rb').read()).hexdigest()
        k = f'audio/ja/{ep}/{int(num):02d}_{tag}.mp4'
        rows.append(dict(turn=int(num), voice=tag, speaker=v, key=k, sha1=sha, ms=int(d * 1000), emotion='+'.join(s[0] for s in segs), f=f))
if UP:
    W = ['npx', '-y', 'wrangler@4']; now = datetime.datetime.now(datetime.UTC).strftime('%Y-%m-%d %H:%M:%S'); sql = []
    for r in rows:
        x = subprocess.run(W + ['r2', 'object', 'put', f"talkverse-art/{r['key']}", '--file', r['f'], '--content-type', 'audio/mp4', '--remote'], cwd=R, capture_output=True, text=True)
        if x.returncode:
            sys.exit('R2 실패 ' + r['key'] + x.stderr[-300:])
        sql.append(f"INSERT OR REPLACE INTO audio_lines (lang,episode,turn,voice,speaker,emotion,key,ms,sha1,created_at) VALUES ('ja','{ep}',{r['turn']},'{r['voice']}','{r['speaker']}','{r['emotion']}','{r['key']}',{r['ms']},'{r['sha1']}','{now}');")
    q = f'{tmp}/x.sql'; open(q, 'w').write('\n'.join(sql) + '\n')
    x = subprocess.run(W + ['d1', 'execute', 'talkverse-db', '--remote', '--file', q, '-y'], cwd=R, capture_output=True, text=True)
    if x.returncode:
        sys.exit('D1 실패 ' + x.stderr[-400:])
mf = f'{R}/data/tts/audio_ja.json'
M = json.load(open(mf, encoding='utf-8')) if os.path.exists(mf) else {}
M[ep] = [{k: v for k, v in r.items() if k != 'f'} for r in rows]
json.dump(M, open(mf, 'w', encoding='utf-8'), ensure_ascii=False, indent=0)
print(ep, len(rows), '파일', sum(r['ms'] for r in rows) // 1000, '초', sum(os.path.getsize(r['f']) for r in rows) // 1024, 'KB', '올림' if UP else '안 올림', tmp)

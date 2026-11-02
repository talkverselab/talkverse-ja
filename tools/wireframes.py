# 와이어프레임 3장(아이패드 가로 1366×1024, 시안 ③ 학습 데스크형) — Claude 가 그림(Grok 이미지 실패, 사용자 지시 2026-11-02)
from pathlib import Path
NAVY='#0a2540'; COPPER='#b77548'; TAN='#c19e6d'; INDIGO='#635bff'; LINE='#e6e2db'; MUTED='#7a8594'; BG='#ffffff'; PAPER='#faf8f4'; GREEN='#2f9e6b'
W,H=1366,1024
DASH=' stroke-dasharray="6 4"'
def esc(s): return s.replace('&','&amp;').replace('<','&lt;').replace('>','&gt;')
class Svg:
    def __init__(s,title):
        s.p=['<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" font-family="-apple-system,Apple SD Gothic Neo,Helvetica,Arial,sans-serif">'%(W,H,W,H),'<defs><linearGradient id="g" x1="0" x2="1"><stop offset="0" stop-color="%s"/><stop offset="1" stop-color="%s"/></linearGradient></defs>'%(COPPER,TAN),'<rect width="%d" height="%d" fill="%s"/>'%(W,H,BG)]
        s.t(24,34,title,19,NAVY,'800')
    def r(s,x,y,w,h,fill=PAPER,stroke=LINE,rx=12,sw=1.2,dash=''):
        s.p.append('<rect x="%s" y="%s" width="%s" height="%s" rx="%s" fill="%s" stroke="%s" stroke-width="%s"%s/>'%(x,y,w,h,rx,fill,stroke,sw,DASH if dash else ''))
    def t(s,x,y,txt,size=13,fill=NAVY,w='500',anchor='start'):
        s.p.append('<text x="%s" y="%s" font-size="%s" fill="%s" font-weight="%s" text-anchor="%s">%s</text>'%(x,y,size,fill,w,anchor,esc(txt)))
    def grad(s,x,y,w,h,rx=10): s.p.append('<rect x="%s" y="%s" width="%s" height="%s" rx="%s" fill="url(#g)"/>'%(x,y,w,h,rx))
    def bar(s,x,y,w,h,frac,color=COPPER):
        s.r(x,y,w,h,'#eee9e1',LINE,h/2); s.p.append('<rect x="%s" y="%s" width="%s" height="%s" rx="%s" fill="%s"/>'%(x,y,max(2,w*frac),h,h/2,color))
    def pic(s,x,y,w,h,label='그림'):
        s.r(x,y,w,h,'#f1ece4',LINE,14)
        s.p.append('<path d="M%s,%s L%s,%s L%s,%s L%s,%s L%s,%s Z" fill="#d9cfbf"/><circle cx="%s" cy="%s" r="%s" fill="#e6d2b5"/>'%(x+w*.15,y+h*.8,x+w*.4,y+h*.45,x+w*.55,y+h*.65,x+w*.68,y+h*.5,x+w*.86,y+h*.8,x+w*.72,y+h*.28,min(w,h)*.07))
        s.t(x+w/2,y+h-10,label,11,MUTED,'600','middle')
    def rail(s,x,y,h,active=0):
        s.r(x,y,64,h,'#f6f3ee',LINE,0)
        for i,(ic,lb) in enumerate([('📖','배우기'),('🃏','복습'),('🧭','탐색'),('👤','나')]):
            yy=y+28+i*86
            if i==active: s.r(x+8,yy-6,48,60,'#efe6dc',COPPER,12)
            s.t(x+32,yy+22,ic,20,NAVY,'500','middle'); s.t(x+32,yy+44,lb,10,COPPER if i==active else MUTED,'700','middle')
    def chip(s,x,y,txt,on=False,w=None):
        w=w or 14+len(txt)*12; s.r(x,y,w,26,'#efeefe' if on else BG,INDIGO if on else LINE,13); s.t(x+w/2,y+17,txt,11,INDIGO if on else MUTED,'700','middle'); return w
    def frame(s,x,y,w,h,label):
        s.r(x,y,w,h,BG,NAVY,16,2); s.r(x+w-150,y-14,150,26,NAVY,NAVY,13); s.t(x+w-75,y+4,label,11,'#fff','800','middle')
    def save(s,fn): s.p.append('</svg>'); Path(fn).write_text('\n'.join(s.p),encoding='utf-8')

# 1 ─ 시안 ③ 데스크: 홈 → 편 → 재생
s=Svg('와이어프레임 1 — 시안 ③ 「학습 데스크」 아이패드 가로: ① 홈·섬 목록 → ② 편 화면 → ③ 모든 문장 듣기')
def scene(s,x,y,label,kind):
    w,h=430,560; s.frame(x,y,w,h,label); s.rail(x+1,y+1,h-2,0); lx=x+76; rx=x+270
    if kind=='home':
        s.r(lx,y+16,180,528,PAPER,LINE,14); s.t(lx+12,y+42,'こんにちは! 🌸',15,COPPER,'800'); s.t(lx+12,y+60,'오늘의 작은 성과',10,MUTED,'600')
        s.grad(lx+12,y+68,156,48); s.t(lx+20,y+88,'여행 섬 1편 완주',11,'#fff','800'); s.t(lx+20,y+105,'핵심 표현 3개 중 2개 ✔',9,'#fff','600')
        s.t(lx+12,y+140,'섬 (초보 R1)',10,MUTED,'700'); s.chip(lx+100,y+128,'왕초보',False,44); s.chip(lx+146,y+128,'초보',True,34)
        for i,(e,n,c,f) in enumerate([('🆘','서바이벌','3/3',1),('🤝','친구','5/16',.3),('💘','사랑','0/10',0),('🏠','생활','2/16',.12),('✈️','여행','1/16',.06),('🎬','문화','0/16',0)]):
            yy=y+156+i*44; s.r(lx+12,yy,156,38,BG,COPPER if i==1 else LINE,10); s.t(lx+22,yy+22,'%s %s'%(e,n),12,NAVY,'800'); s.t(lx+158,yy+22,c,10,MUTED,'600','end'); s.bar(lx+22,yy+29,80,3,f)
        s.r(lx+12,y+430,156,100,'#fff7ef',COPPER,12,1.2,'d'); s.t(lx+22,y+452,'✨ 맞춤 회화 만들기',11,COPPER,'800'); s.t(lx+22,y+470,'섬·상황·레벨 → 나만의 1편',9,MUTED,'600'); s.t(lx+22,y+486,'첫 편 무료',9,MUTED,'600')
        s.r(rx,y+16,150,528,BG,LINE,14); s.t(rx+12,y+40,'🤝 친구 섬 · 16편',12,NAVY,'800'); s.bar(rx+12,y+50,126,4,.3)
        for i in range(8):
            yy=y+66+i*54; s.r(rx+10,yy,130,46,PAPER,LINE,10); s.t(rx+18,yy+18,'a%d · 짧은 편'%(i+1),10,NAVY,'800'); s.t(rx+18,yy+34,'6턴 · '+('완주 ✔' if i<2 else '새 표현 2'),9,MUTED,'600')
            if i<2: s.p.append('<circle cx="%s" cy="%s" r="5" fill="%s"/>'%(rx+128,yy+12,GREEN))
    elif kind=='episode':
        s.r(lx,y+16,180,528,PAPER,LINE,14); s.t(lx+12,y+40,'🤝 친구 섬',12,NAVY,'800')
        titles=['a1 매칭됐다!','a2 카페에서','a3 늦었어','a4 사진이랑 다르네?','a5 우산 하나','a6 밤 산책','b1 생일 작전','b2 영화 고르기','b3 룸메 규칙']
        for i in range(9):
            yy=y+56+i*52; on=i==3; s.r(lx+10,yy,160,44,'#fff7ef' if on else BG,COPPER if on else LINE,10); s.t(lx+18,yy+18,titles[i],10,NAVY,'800'); s.t(lx+18,yy+34,'6턴 · R1',9,MUTED,'600')
        s.r(rx,y+16,150,528,BG,LINE,14); s.t(rx+10,y+36,'☕ 사진이랑 다르네?',11,NAVY,'800'); s.t(rx+10,y+50,'R1 · 친구 · 6턴',9,MUTED,'600')
        s.grad(rx+10,y+58,130,30); s.t(rx+75,y+78,'▶ 모든 문장 듣기',11,'#fff','800','middle')
        s.pic(rx+10,y+96,130,80,'장면 그림(만화 1컷)')
        for i in range(5):
            yy=y+186+i*62; me=i%2==1; bx=rx+38 if me else rx+10
            s.r(bx,yy,102,52,'#efeefe' if me else PAPER,INDIGO if me else LINE,12); s.t(bx+8,yy+16,'あの…ユカさん？',10,NAVY,'800'); s.t(bx+8,yy+30,'あの…ゆかさん？',8,INDIGO,'600'); s.t(bx+8,yy+44,'저… 유카 씨예요?',8,MUTED,'600')
        s.t(rx+10,y+520,'🃏 그림 카드 · 한자를 탭 = 팝업',9,MUTED,'700')
    else:
        s.r(lx,y+16,180,528,PAPER,LINE,14); s.t(lx+12,y+40,'☕ 사진이랑 다르네?',11,NAVY,'800'); s.pic(lx+12,y+52,156,120,'현재 턴 장면 그림')
        s.t(lx+12,y+194,'자막 단계',9,MUTED,'700'); x2=lx+12
        for i,c in enumerate(['日本語','かな','독음','한국어']): x2+=s.chip(x2,y+200,c,i<2,38)+4
        s.r(lx+12,y+240,156,296,BG,LINE,12)
        ja=['あの…ユカさんですか？','はい！{name}さん？','はじめまして。あ、','うそ！髪、切った','あ、はい。でも、','ありがとう。じゃ、']; ko=['저… 유카 씨예요?','네! {name}씨?','처음 뵙겠습니다. 아,','진짜? 머리 잘라서','아, 네. 그래도','고마워. 자, 앉자']
        for i in range(6):
            yy=y+250+i*48
            if i==1: s.r(lx+18,yy-4,144,44,'#efeefe',INDIGO,10,1.5)
            s.t(lx+24,yy+12,'%d · %s'%(i+1,['ユカ','나'][i%2]),8,MUTED,'600'); s.t(lx+24,yy+26,ja[i],10,NAVY,'800'); s.t(lx+24,yy+37,ko[i],8,MUTED,'600')
        s.r(rx,y+16,150,528,BG,LINE,14); s.t(rx+10,y+36,'재생 컨트롤',10,MUTED,'700')
        s.r(rx+10,y+46,130,36,COPPER,COPPER,18); s.t(rx+75,y+69,'⏮  ⏸ 일시정지  ⏭',11,'#fff','800','middle')
        s.t(rx+10,y+100,'2 / 6',10,MUTED,'700'); s.bar(rx+40,y+94,100,5,.33,INDIGO)
        s.t(rx+10,y+124,'배속  ×0.75  ×1  ×1.25',10,NAVY,'700'); s.t(rx+10,y+146,'턴 사이 650ms 쉼',9,MUTED,'600')
        s.r(rx+10,y+164,130,120,PAPER,LINE,12); s.t(rx+18,y+184,'이 편의 핵심 표현',10,NAVY,'800')
        for i,e in enumerate(['はじめまして','うそ！','でも、いいですね']): s.t(rx+18,y+206+i*20,'• '+e,10,COPPER,'800')
        s.r(rx+10,y+296,130,100,'#fff7ef',COPPER,12,1.2,'d'); s.t(rx+18,y+316,'완주하면',10,MUTED,'700'); s.t(rx+18,y+336,'🌟 한 장면을 마쳤어요',10,NAVY,'800'); s.t(rx+18,y+354,'핵심 3개 중 2개 기억',9,MUTED,'600'); s.t(rx+18,y+372,'→ 그림 카드로 확인',9,INDIGO,'700')
        s.t(rx+10,y+520,'폰: 그림 위 / 문장 아래 전체화면',9,MUTED,'700')
scene(s,24,70,'① 홈 · 섬 목록','home'); scene(s,468,70,'② 편 화면','episode'); scene(s,912,70,'③ 모든 문장 듣기','play')
s.t(24,680,'원칙(시안 ③ 학습 데스크형, Grok 1순위): 왼쪽 레일(배우기·복습·탐색·나) + 왼쪽 목록 칸 + 오른쪽 내용 칸. 「모든 문장 듣기」를 누르면 왼쪽 칸 = 재생 패널(그림+문장), 오른쪽 = 컨트롤·핵심 표현·완주 카드.',12,NAVY,'600')
s.t(24,702,'톤: 흰 바탕 · 남색 #0A2540 · 구리→황갈 그라데이션 포인트(버튼·성과) · 인디고 #635BFF(현재 턴·가나·선택). 그림 칸 = 곧 들어올 만화 1컷(점토풍).',12,MUTED,'500')
s.t(24,724,'폰(세로 한 칸): 레일→하단 탭, 목록→전체 화면, 재생 = 그림 상단 고정 + 문장 스크롤 + 하단 컨트롤.',12,MUTED,'500')
s.save('data/review/wire/wire_01_desk.svg')

# 2 ─ 「나」 탭 성과
s=Svg('와이어프레임 2 — 「나」 탭 성과 데스크 (센다: 편 완주·라이트너 단계·핵심 표현·한자·빈도 커버율 / 안 센다: 앱 오픈·스트릭·포인트·순위)')
s.rail(24,70,900,3); lx=100
s.r(lx,70,300,900,PAPER,LINE,16); s.t(lx+16,100,'나',16,NAVY,'800'); s.chip(lx+16,114,'이번 주',True,60); s.chip(lx+82,114,'이번 달',False,60); s.chip(lx+148,114,'전체',False,44)
s.t(lx+16,166,'이번 주 한 줄',10,MUTED,'700'); s.r(lx+16,174,268,70,'#fff7ef',COPPER,12); s.t(lx+28,200,'여행 섬 왕초보를 거의 다 읽었어요',12,NAVY,'800'); s.t(lx+28,222,'편 4 완주 · 카드 9 졸업 · 한자 12자',10,MUTED,'600')
s.t(lx+16,274,'빈도 커버율',10,MUTED,'700')
s.p.append('<circle cx="%s" cy="344" r="44" fill="none" stroke="%s" stroke-width="10"/><circle cx="%s" cy="344" r="44" fill="none" stroke="%s" stroke-width="10" stroke-dasharray="116 160" transform="rotate(-90 %s 344)"/>'%(lx+70,LINE,lx+70,COPPER,lx+70)); s.t(lx+70,350,'42%',18,NAVY,'900','middle')
s.t(lx+128,322,'내가 아는 단어로',11,NAVY,'700'); s.t(lx+128,340,'일상 일본어의 약 42%',11,NAVY,'800'); s.t(lx+128,358,'를 이해할 수 있어요',11,NAVY,'700'); s.t(lx+128,380,'다음 절벽 437까지 12개 더',10,INDIGO,'700')
s.t(lx+16,420,'절벽 마일스톤',10,MUTED,'700'); s.bar(lx+16,428,268,8,.62)
for i,(n,p) in enumerate([('294',.12),('437',.33),('998',.62),('2500',.96)]): s.t(lx+16+268*p,452,n,9,COPPER if i<3 else MUTED,'800','middle')
s.t(lx+16,490,'라이트너 분포(카드 수)',10,MUTED,'700')
for i,v in enumerate([38,22,17,11,9,6,4,12]):
    hgt=v*3; s.r(lx+16+i*33,600-hgt,26,hgt,INDIGO if i<7 else GREEN,LINE,4); s.t(lx+29+i*33,616,str(i+1) if i<7 else '졸',9,MUTED,'700','middle')
s.t(lx+16,650,'이번 주 되돌아보기',10,MUTED,'700')
for i,(d,v) in enumerate([('월',2),('화',1),('수',0),('목',3),('금',1),('토',0),('일',0)]):
    s.r(lx+16+i*38,660,30,30,'#efe6dc' if v else BG,COPPER if v else LINE,8); s.t(lx+31+i*38,680,d,10,NAVY,'700','middle')
    if v: s.t(lx+31+i*38,706,'%d편'%v,9,COPPER,'800','middle')
s.t(lx+16,750,'원칙: 큰 숫자 대신 문장 + 작은 진행 막대.',10,MUTED,'600'); s.t(lx+16,768,'경쟁·순위·포인트·스트릭 없음.',10,MUTED,'600')
rx=420; s.r(rx,70,920,900,BG,LINE,16); s.t(rx+16,100,'섬별 진행(아이패드 오른쪽 칸)',12,MUTED,'700')
isl=[('🆘','서바이벌',1,1,0),('🤝','친구',.8,.31,.12),('💘','사랑',.5,.2,0),('🏠','생활',.3,.12,0),('✈️','여행',.9,.06,0),('🎬','문화',0,0,0),('💼','일',0,0,.25),('🎓','학업',0,0,.12)]
expr=['9/9','18/48','6/30','4/48','2/48','0/48','4/16','2/16']
for i,(e,n,r0,r1,r2) in enumerate(isl):
    x=rx+16+(i%4)*224; y=116+(i//4)*210; s.r(x,y,208,190,PAPER,LINE,14); s.t(x+12,y+28,'%s %s'%(e,n),13,NAVY,'800')
    for j,(lb,v) in enumerate([('왕초보',r0),('초보',r1),('중급',r2)]): s.t(x+12,y+56+j*34,lb,10,MUTED,'700'); s.bar(x+56,y+48+j*34,140,8,v); s.t(x+196,y+56+j*34,'%d%%'%int(v*100),9,COPPER if v else MUTED,'800','end')
    s.t(x+12,y+172,'핵심 표현 %s 기억'%expr[i],10,INDIGO,'700')
s.t(rx+16,556,'편 끝·복습 끝의 순간 연출(공용 ProgressSummaryCard)',12,MUTED,'700')
s.r(rx+16,566,440,160,'#fff7ef',COPPER,14); s.pic(rx+28,578,120,120,'장면 그림 살짝 확대'); s.t(rx+164,600,'🌟 한 장면을 마쳤어요',14,NAVY,'900'); s.t(rx+164,624,'핵심 표현 3개 중 2개를 기억했어요',11,NAVY,'700'); s.t(rx+164,646,'새로 본 한자 写·髪 · 커버율 +0.3%p',10,MUTED,'600'); s.t(rx+164,672,'구리빛이 한 번 스치고 짧은 효과음 0.8초, 폭죽 없음',10,MUTED,'600'); s.grad(rx+164,686,120,28); s.t(rx+224,705,'그림 카드로 →',10,'#fff','800','middle')
s.r(rx+472,566,432,160,PAPER,LINE,14); s.t(rx+484,590,'복습 끝(라이트너 세션)',12,NAVY,'800'); s.t(rx+484,614,'오늘 졸업한 카드 3장 · 7단계로 오른 카드 2장',11,NAVY,'700'); s.t(rx+484,636,'내일 돌아올 카드 14장',10,MUTED,'600'); s.t(rx+484,658,'틀린 카드는 1단계로 — 괜찮아요, 그게 복습이에요',10,MUTED,'600')
s.t(rx+16,760,'Flutter 메모: 「나」 탭 AchievementDesk = IslandProgressGrid + LeitnerDistribution + CoverageMeter + WeeklyReview · ProgressSummaryCard(편 끝·복습 끝·홈 공용)',11,NAVY,'600')
s.t(rx+16,782,'데이터: 편 완주 이벤트 · 카드 단계 변화 · 한자 조회 집합 · 단어 마스터 집합 → CoverageService(절벽 CSV 로 커버율). 폰: 왼쪽 칸이 위, 섬 카드가 세로로.',11,MUTED,'500')
s.save('data/review/wire/wire_02_achievement.svg')

# 3 ─ 맞춤 회화
s=Svg('와이어프레임 3 — 「맞춤 회화 만들기」: 입력 3단계 → 만드는 중 → 내 맞춤 회화 서랍 · 첫 편 무료 · 서버 ID 저장 · 코드 서버+Grok 제작')
s.rail(24,70,900,0); lx=100
s.r(lx,70,560,900,PAPER,LINE,16); s.t(lx+16,100,'✨ 맞춤 회화 만들기',16,NAVY,'800'); s.r(lx+16,112,528,54,'#fff7ef',COPPER,12); s.t(lx+28,134,'섬·상황·레벨을 고르면 나만의 회화 1편을 만들어 드려요.',11,NAVY,'700'); s.t(lx+28,154,'완성까지 몇 분 걸리고, 첫 1편은 무료예요. 앱을 닫아도 돼요.',10,MUTED,'600')
def step(n,y,txt): s.p.append('<circle cx="%s" cy="%s" r="11" fill="%s"/>'%(lx+28,y,NAVY)); s.t(lx+28,y+4,str(n),10,'#fff','900','middle'); s.t(lx+48,y+5,txt,13,NAVY,'800')
step(1,196,'어느 섬?')
for i,n in enumerate(['🆘 서바이벌','🤝 친구','💘 사랑','🏠 생활','✈️ 여행','🎬 문화','💼 일','🎓 학업']):
    xx=lx+16+(i%4)*132; yy=212+(i//4)*40; on=i==4
    s.r(xx,yy,124,32,'#fff7ef' if on else BG,COPPER if on else LINE,16,1.5 if on else 1); s.t(xx+62,yy+21,n,11,COPPER if on else NAVY,'800','middle')
step(2,320,'어떤 상황?'); s.r(lx+16,334,528,64,BG,COPPER,12,1.5); s.t(lx+28,360,'온천 여관에 늦게 도착해서 체크인',13,NAVY,'800'); s.t(lx+532,390,'32/120',9,MUTED,'600','end')
x=lx+16
for i,c in enumerate(['온천 여관 체크인','길거리 음식 추천받기','막차를 놓침','렌터카 반납']): x+=s.chip(x,408,c,i==0)+6
step(3,470,'레벨'); s.r(lx+16,484,528,36,BG,LINE,18)
for i,l in enumerate(['왕초보','초보','중급','고급']):
    on=i==1; xx=lx+16+i*132
    if on: s.r(xx+2,486,128,32,'#efeefe',INDIGO,16)
    s.t(xx+66,507,l,11,INDIGO if on else MUTED,'800','middle')
s.r(lx+16,540,528,40,BG,LINE,12); s.t(lx+28,565,'내 이름(선택) — 회화 속 「나」로 나와요',11,MUTED,'600')
s.grad(lx+16,600,528,46,23); s.t(lx+280,629,'✨ 나만의 회화 만들기',14,'#fff','900','middle'); s.t(lx+280,668,'첫 1편 무료 · 완성되면 「내 맞춤 회화」에 들어와요',10,MUTED,'600','middle')
s.r(lx+16,700,528,110,'#f6f5ff',INDIGO,12,1.2,'d'); s.t(lx+28,724,'2번째부터(402 paid_required)',10,INDIGO,'700'); s.t(lx+28,746,'“첫 맞춤 회화는 무료로 만들어 드렸어요. 다음부터는 유료예요.',11,NAVY,'700'); s.t(lx+28,764,' 계속 만들고 싶으시면 언제든 말씀해 주세요.”',11,NAVY,'700'); s.t(lx+28,790,'강요 없이 한 줄, 가격은 별도 화면(준비 중)',10,MUTED,'600')
s.t(lx+16,850,'폰: 같은 순서로 세로 스크롤(서랍 위, 입력 아래). 아이패드 1000pt 이상: 왼쪽 입력 / 오른쪽 서랍.',10,MUTED,'600')
rx=680; s.r(rx,70,660,900,BG,LINE,16); s.t(rx+16,100,'내 맞춤 회화  3',14,NAVY,'800'); s.t(rx+644,100,'↻ 새로고침(1분마다 자동)',10,INDIGO,'700','end')
def row(y,emoji,title,pill,pillc,sub,right,progress=None):
    s.r(rx+16,y,628,86,PAPER,LINE,14); s.t(rx+34,y+50,emoji,26,NAVY,'500'); s.t(rx+76,y+34,title,13,NAVY,'800'); s.r(rx+76,y+46,54,18,pillc+'22',pillc,9); s.t(rx+103,y+59,pill,9,pillc,'800','middle'); s.t(rx+140,y+59,sub,10,MUTED,'600'); s.t(rx+630,y+50,right,12,MUTED,'700','end')
    if progress is not None: s.bar(rx+76,y+72,400,4,progress,INDIGO)
row(120,'♨️','온천 여관에 늦게 도착해서 체크인','쓰는 중',INDIGO,'초보 · 여행 · 초안을 쓰고 있어요 → 다듬고 있어요 → 검수 중','◌',.4)
row(216,'🍜','길거리 음식 추천받기','대기 중',TAN,'초보 · 여행 · 앞에 1편','◌',0)
row(312,'🎂','생일 작전 들켰다','완성',GREEN,'중급 · 친구 · 10턴 · 「맞춤」 배지','›')
s.t(rx+16,430,'완성 편은 기존 편과 같은 구조 → 재생 패널·그림 카드·한자 팝업·라이트너에 그대로. 카드 왼쪽 위 구리색 「맞춤」 배지로 섬 편과 구분.',10,MUTED,'600')
s.t(rx+16,470,'뒤에서 일어나는 일(앱은 ID 만 들고 있음)',12,MUTED,'700')
flow=[('앱','POST /api/script/ja|{device,domain,situation,level}'),('Cloudflare D1','custom_scripts|id=ja-xxxxxxxx · queued'),('맥미니 코드 서버','claude-lab -p 초안|(5분마다 pending 확인)'),('Grok','「일본어 회화 검수」|재작성'),('검사·독음','check_dialogues|--fix-rd'),('Cloudflare D1','result → ready|(같은 ID)'),('앱','GET /<id> → 편 JSON|로컬 보관·오프라인 OK')]
for i,(h,b) in enumerate(flow):
    x=rx+16+(i%4)*158; y=486+(i//4)*96; cf='Cloudflare' in h; s.r(x,y,146,80,'#fff7ef' if cf else PAPER,COPPER if cf else LINE,10); s.t(x+8,y+20,h,10,NAVY,'800')
    for k,l in enumerate(b.split('|')): s.t(x+8,y+40+k*16,l,9,MUTED,'600')
    if i<6:
        if i%4<3: s.t(x+150,y+46,'→',14,COPPER,'900','middle')
        else: s.t(x+73,y+92,'↓',14,COPPER,'900','middle')
s.t(rx+16,700,'외부 LLM API 없음 · 1회 무료(서버가 device 로 셈) · 유료는 paid_devices 표(지금은 비움) · 많이 쓰면 그때 큐·과금 설계',10,MUTED,'600')
s.t(rx+16,730,'서버 키는 사용자가 set_script_key.sh 로 넣음(완료) — 코드 서버 launchd 는 사용자 확인 뒤 가동',10,COPPER,'700')
s.save('data/review/wire/wire_03_custom.svg')
print('svg ok')

"""
글로비 (12 표현 SVG) → Android 런처 아이콘 PNG 일괄 생성.

문제: ImageMagick 이 SVG 의 <use href="#X"/> 를 resolve 못 함 → globe 안 그려짐.
해법: 사전 inline 처리 (defs 의 <g id="X"> 를 <use> 위치에 그대로 펼침) 후 렌더.

VARIANT (0~11):
 0 happy 행복해   1 excited 신나요    2 normal 보통이야   3 worried 걱정돼
 4 angry 화가나   5 annoyed 짜증나    6 sad 슬퍼         7 disappointed 실망이야
 8 gaveup 포기    9 tired 지쳤어     10 badmood 못마땅   11 meltdown 멘붕이야
"""
import subprocess
from pathlib import Path
import shutil
import tempfile
import re

SRC_SVG = Path(__file__).resolve().parents[2] / "app" / "assets" / "svg" / "talky_globes.svg"
APP_ROOT = Path(__file__).resolve().parents[2] / "app"
RES_DIR = APP_ROOT / "android" / "app" / "src" / "main" / "res"
ASSETS_DIR = APP_ROOT / "assets"

MIPMAP_LEGACY = {
    "mipmap-mdpi": 48, "mipmap-hdpi": 72, "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144, "mipmap-xxxhdpi": 192,
}
ADAPTIVE_FG = {
    "mipmap-mdpi": 108, "mipmap-hdpi": 162, "mipmap-xhdpi": 216,
    "mipmap-xxhdpi": 324, "mipmap-xxxhdpi": 432,
}
MASTER_SIZE = 1024
BG_HEX = "#E6D9FF"

VARIANT_CENTERS = [
    ("happy",        200, 180),
    ("excited",      600, 180),
    ("normal",      1000, 180),
    ("worried",     1400, 180),
    ("angry",        200, 505),
    ("annoyed",      600, 505),
    ("sad",         1000, 505),
    ("disappointed",1400, 505),
    ("gaveup",       200, 825),
    ("tired",        600, 825),
    ("badmood",     1000, 825),
    ("meltdown",    1400, 825),
]

VARIANT_INDEX = 0  # happy
# boar+globe 캐릭터: hood 최상 y_rel=-193, globe 최하 y_rel=+110
# 인접 셀(아래 row 5 angry hood top = 505-193=312)과 겹치지 않게 crop
CELL_W = 340
CELL_H = 320
CELL_OFFSET_Y = -40  # center y = translate.y - 40 (hood + globe 가운데)


def inline_uses(svg_text: str) -> str:
    """모든 <use href="#X"/> 를 defs 의 실제 내용으로 inline."""
    # 1) defs 안 <g id="X">...</g> 추출 (style/filter 제외)
    defs_m = re.search(r"<defs>(.*?)</defs>", svg_text, re.DOTALL)
    if not defs_m:
        return svg_text
    defs_content = defs_m.group(1)

    # id → inner 매핑
    id_groups = {}
    for m in re.finditer(r'<g\s+id="([\w\-]+)"[^>]*>(.*?)</g>', defs_content, re.DOTALL):
        id_groups[m.group(1)] = m.group(2)

    # filter (id="shadow") 는 유지해야 함 → defs 일부 보존
    filter_m = re.search(r'<filter[^>]*>.*?</filter>', defs_content, re.DOTALL)
    style_m = re.search(r'<style>.*?</style>', defs_content, re.DOTALL)

    # 2) <use> 펼침 함수 (재귀)
    def expand(content: str, depth: int = 0) -> str:
        if depth > 6:
            return content

        def repl(m):
            ref = m.group(1)
            x = m.group(2)
            y = m.group(3)
            if ref not in id_groups:
                return m.group(0)
            inner = id_groups[ref]
            # 재귀로 inner 안의 <use> 도 펼침
            inner = expand(inner, depth + 1)
            if x is not None or y is not None:
                tx = x or "0"
                ty = y or "0"
                return f'<g transform="translate({tx} {ty})">{inner}</g>'
            return inner

        # <use href="#X" x="..." y="..."/> 또는 <use xlink:href="#X" .../>
        pattern = r'<use\s+(?:xlink:)?href="#([\w\-]+)"(?:\s+x="(-?\d+(?:\.\d+)?)")?(?:\s+y="(-?\d+(?:\.\d+)?)")?\s*/>'
        return re.sub(pattern, repl, content)

    # 3) id_groups 자체도 재귀 펼침 (globe-base 가 land 참조)
    for k in list(id_groups.keys()):
        id_groups[k] = expand(id_groups[k])

    # 4) body (defs 이후) 의 모든 <use> 펼침
    body = svg_text[defs_m.end():]
    body_expanded = expand(body)

    # 5) 새 defs = style + filter 만 (id="X" 그룹은 모두 inline 됐으므로 제거)
    new_defs_parts = []
    if style_m:
        new_defs_parts.append(style_m.group(0))
    if filter_m:
        new_defs_parts.append(filter_m.group(0))
    new_defs = "<defs>" + "\n".join(new_defs_parts) + "</defs>"

    # 6) 재조립
    return svg_text[:defs_m.start()] + new_defs + body_expanded


def render_full_png(out_png: Path, density: int = 200):
    out_png.parent.mkdir(parents=True, exist_ok=True)
    # 미리 inline 처리된 SVG 임시 파일에 저장 후 렌더
    inlined = inline_uses(SRC_SVG.read_text(encoding="utf-8"))
    with tempfile.NamedTemporaryFile(mode="w", suffix=".svg", delete=False, encoding="utf-8") as tf:
        tf.write(inlined)
        tmp_svg = tf.name
    try:
        cmd = ["magick", "-background", "none", "-density", str(density), tmp_svg, str(out_png)]
        subprocess.run(cmd, check=True, capture_output=True)
    finally:
        Path(tmp_svg).unlink(missing_ok=True)


def crop_variant(full_png: Path, out_png: Path, variant_idx: int, size: int, padding_ratio: float, bg: str = "white"):
    name, tx, ty = VARIANT_CENTERS[variant_idx]
    info = subprocess.run(
        ["magick", "identify", "-format", "%w %h", str(full_png)],
        check=True, capture_output=True, text=True,
    ).stdout.strip().split()
    png_w, png_h = int(info[0]), int(info[1])
    scale_x = png_w / 1600.0
    scale_y = png_h / 1000.0
    cx = (tx - CELL_W / 2) * scale_x
    cy = (ty - CELL_H / 2 + CELL_OFFSET_Y) * scale_y
    cw = CELL_W * scale_x
    ch = CELL_H * scale_y

    out_png.parent.mkdir(parents=True, exist_ok=True)
    inner = int(size * (1 - 2 * padding_ratio))
    cmd = [
        "magick", str(full_png),
        "-crop", f"{int(cw)}x{int(ch)}+{int(cx)}+{int(cy)}",
        "+repage",
        "-background", "none",
        "-resize", f"{inner}x{inner}",
        "-background", bg,
        "-gravity", "center",
        "-extent", f"{size}x{size}",
        str(out_png),
    ]
    subprocess.run(cmd, check=True, capture_output=True)
    print(f"  ✓ {out_png.relative_to(APP_ROOT)} ({size}×{size}, pad={padding_ratio*100:.0f}%, bg={bg})")


def write_adaptive_xml():
    target = RES_DIR / "mipmap-anydpi-v26"
    target.mkdir(parents=True, exist_ok=True)
    xml = '''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
    <monochrome android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
'''
    (target / "ic_launcher.xml").write_text(xml, encoding="utf-8")
    (target / "ic_launcher_round.xml").write_text(xml, encoding="utf-8")
    print(f"  ✓ mipmap-anydpi-v26/ic_launcher{{,_round}}.xml")

    values = RES_DIR / "values"
    values.mkdir(parents=True, exist_ok=True)
    colors_xml = f'''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">{BG_HEX}</color>
</resources>
'''
    (values / "ic_launcher_background.xml").write_text(colors_xml, encoding="utf-8")
    print(f"  ✓ values/ic_launcher_background.xml = {BG_HEX}")


def main():
    name, tx, ty = VARIANT_CENTERS[VARIANT_INDEX]
    print(f"== Globi 런처 아이콘 생성 ==")
    print(f"source:  {SRC_SVG}")
    print(f"variant: #{VARIANT_INDEX + 1} {name} (translate {tx},{ty})")
    print()

    with tempfile.TemporaryDirectory() as td:
        full_png = Path(td) / "talky_globes_full.png"
        print(f"== <use> inline + 전체 SVG 렌더 ==")
        render_full_png(full_png, density=200)
        info = subprocess.run(
            ["magick", "identify", "-format", "%w x %h", str(full_png)],
            check=True, capture_output=True, text=True,
        ).stdout.strip()
        print(f"  ✓ {info} (임시)")

        print()
        print("== Play Store 마스터 (1024×1024) ==")
        crop_variant(full_png, ASSETS_DIR / "icon_source.png", VARIANT_INDEX, MASTER_SIZE, padding_ratio=0.08, bg="none")

        print()
        print("== Legacy mipmap (ic_launcher.png + _round) ==")
        for folder, sz in MIPMAP_LEGACY.items():
            target = RES_DIR / folder
            png = target / "ic_launcher.png"
            crop_variant(full_png, png, VARIANT_INDEX, sz, padding_ratio=0.06, bg="none")
            shutil.copy(png, target / "ic_launcher_round.png")
            print(f"  ✓ copied → {folder}/ic_launcher_round.png")

        print()
        print("== Adaptive foreground (108dp 전체, 66dp safe zone) ==")
        for folder, sz in ADAPTIVE_FG.items():
            crop_variant(full_png, RES_DIR / folder / "ic_launcher_foreground.png", VARIANT_INDEX, sz, padding_ratio=0.22, bg="none")

    print()
    print("== Adaptive XML + background color ==")
    write_adaptive_xml()

    print()
    print(f"Done. ✨  ({name} variant)")


if __name__ == "__main__":
    main()

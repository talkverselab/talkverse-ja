"""
글로비 멧돼지 캐릭터 PNG 그대로 사용 — 12 표현 분리 + 런처 아이콘.

input:  C:/Users/Administrator/Desktop/49855777-b72c-4a2e-a2a2-fd351f81950b.png (1369×1149)
        4 cols × 3 rows = 12 캐릭터 + 한국어 라벨

output:
  app/assets/png/character_01_happy.png  ~ character_12_proud.png
    (라벨 제외, 흰 배경 → 투명, 캐릭터 영역만 tight crop)
  app/android/app/src/main/res/mipmap-*/ic_launcher.png
    (#1 행복 캐릭터 꽉 채워서 — 95% 면적)
  app/android/app/src/main/res/mipmap-*/ic_launcher_foreground.png
    (adaptive foreground — 78% 면적, 66dp safe zone 안)
  app/assets/icon_source.png (1024×1024 마스터)
"""
import subprocess
from pathlib import Path
from PIL import Image
import shutil
import tempfile

SRC_PNG = Path("C:/Users/Administrator/Desktop/49855777-b72c-4a2e-a2a2-fd351f81950b.png")
APP_ROOT = Path(__file__).resolve().parents[2] / "app"
PNG_DIR = APP_ROOT / "assets" / "png" / "characters"
RES_DIR = APP_ROOT / "android" / "app" / "src" / "main" / "res"
ASSETS_DIR = APP_ROOT / "assets"

# 12 캐릭터 순서 (이미지 위→아래, 왼→오른쪽)
NAMES = [
    "happy",      # 1 행복
    "excited",    # 2 신남
    "worried",    # 3 고민
    "surprise",   # 4 놀람
    "angry",      # 5 화남
    "annoyed",    # 6 짜증
    "sad",        # 7 슬픔
    "gaveup",     # 8 포기
    "shy",        # 9 부끄러움
    "meltdown",   # 10 멘붕
    "confident",  # 11 자신감
    "proud",      # 12 뿌듯
]

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

# 런처 아이콘 = 행복 (index 0)
ICON_VARIANT = 0


def whitish_to_transparent(im: Image.Image, threshold: int = 245) -> Image.Image:
    """흰 배경 → 투명. RGB 모두 threshold 이상이면 alpha 0."""
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if r >= threshold and g >= threshold and b >= threshold:
                px[x, y] = (255, 255, 255, 0)
    return im


def tight_crop(im: Image.Image, alpha_threshold: int = 5) -> Image.Image:
    """alpha 가 alpha_threshold 보다 큰 픽셀의 bounding box 로 crop."""
    im = im.convert("RGBA")
    alpha = im.split()[-1]
    bbox = alpha.point(lambda p: 255 if p > alpha_threshold else 0).getbbox()
    if bbox is None:
        return im
    return im.crop(bbox)


def extract_cells(src: Path, out_dir: Path):
    """원본 이미지에서 12 캐릭터 셀을 분리 + 라벨 제거 + 투명 배경 + tight crop."""
    out_dir.mkdir(parents=True, exist_ok=True)
    img = Image.open(src).convert("RGBA")
    W, H = img.size
    print(f"  source: {W}×{H}")

    # 셀 grid: 4 cols × 3 rows. 라벨이 셀 하단 ~17% 영역 차지.
    # 캐릭터만 = 셀의 위 83%
    cell_w = W / 4
    cell_h = H / 3
    char_h_ratio = 0.83  # 위 83% 가 캐릭터, 아래 17% 는 라벨

    for i, name in enumerate(NAMES):
        row, col = i // 4, i % 4
        x0 = int(col * cell_w)
        y0 = int(row * cell_h)
        x1 = int((col + 1) * cell_w)
        y1_full = int((row + 1) * cell_h)
        y1 = int(y0 + cell_h * char_h_ratio)  # 라벨 잘라냄

        cell = img.crop((x0, y0, x1, y1))
        cell = whitish_to_transparent(cell, threshold=245)
        cell = tight_crop(cell, alpha_threshold=10)
        out_path = out_dir / f"character_{i+1:02d}_{name}.png"
        cell.save(out_path, "PNG", optimize=True)
        print(f"  ✓ {out_path.name}  ({cell.width}×{cell.height})")


def render_launcher_icons(char_png: Path):
    """행복 캐릭터로 모든 mipmap + adaptive 아이콘 생성. 캐릭터 꽉 채움."""
    char = Image.open(char_png).convert("RGBA")

    def fit_into_square(size: int, fill_ratio: float, bg_color: tuple = (0, 0, 0, 0)) -> Image.Image:
        """char 를 size×size 캔버스 안에 fill_ratio (0~1) 비율로 가운데 배치."""
        canvas = Image.new("RGBA", (size, size), bg_color)
        target = int(size * fill_ratio)
        # 비율 유지하면서 가장 긴 변 = target
        ch_w, ch_h = char.size
        scale = target / max(ch_w, ch_h)
        new_w, new_h = int(ch_w * scale), int(ch_h * scale)
        resized = char.resize((new_w, new_h), Image.LANCZOS)
        off_x = (size - new_w) // 2
        off_y = (size - new_h) // 2
        canvas.paste(resized, (off_x, off_y), resized)
        return canvas

    # 1) Play Store 마스터 1024×1024 — 95% 꽉 채움, 라벤더 배경
    bg_rgba = tuple(int(BG_HEX[i:i+2], 16) for i in (1, 3, 5)) + (255,)
    master = fit_into_square(MASTER_SIZE, fill_ratio=0.92, bg_color=bg_rgba)
    master.save(ASSETS_DIR / "icon_source.png", "PNG", optimize=True)
    print(f"  ✓ assets/icon_source.png  ({MASTER_SIZE}×{MASTER_SIZE}, 92%, bg=lavender)")

    # 2) Legacy mipmap — 92% 꽉 채움, 흰 배경 (둥근 mask 적용 시 자연스럽게)
    print()
    print("  -- Legacy mipmap (ic_launcher.png + _round) --")
    for folder, sz in MIPMAP_LEGACY.items():
        target = RES_DIR / folder
        target.mkdir(parents=True, exist_ok=True)
        img = fit_into_square(sz, fill_ratio=0.92, bg_color=bg_rgba)
        img.save(target / "ic_launcher.png", "PNG", optimize=True)
        shutil.copy(target / "ic_launcher.png", target / "ic_launcher_round.png")
        print(f"    ✓ {folder}/ic_launcher{{,_round}}.png  ({sz}×{sz})")

    # 3) Adaptive foreground — 78% 꽉 채움, 투명 배경 (background 별도 lav color)
    print()
    print("  -- Adaptive foreground (108dp 전체, ~66dp safe zone) --")
    for folder, sz in ADAPTIVE_FG.items():
        target = RES_DIR / folder
        target.mkdir(parents=True, exist_ok=True)
        img = fit_into_square(sz, fill_ratio=0.78, bg_color=(0, 0, 0, 0))
        img.save(target / "ic_launcher_foreground.png", "PNG", optimize=True)
        print(f"    ✓ {folder}/ic_launcher_foreground.png  ({sz}×{sz})")


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

    values = RES_DIR / "values"
    values.mkdir(parents=True, exist_ok=True)
    colors_xml = f'''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">{BG_HEX}</color>
</resources>
'''
    (values / "ic_launcher_background.xml").write_text(colors_xml, encoding="utf-8")
    print(f"  ✓ adaptive XML + bg color ({BG_HEX})")


def main():
    print(f"== 캐릭터 추출 ==")
    extract_cells(SRC_PNG, PNG_DIR)

    print()
    print(f"== 런처 아이콘 생성 (variant #{ICON_VARIANT+1} {NAMES[ICON_VARIANT]}) ==")
    char_png = PNG_DIR / f"character_{ICON_VARIANT+1:02d}_{NAMES[ICON_VARIANT]}.png"
    render_launcher_icons(char_png)

    print()
    print(f"== Adaptive XML ==")
    write_adaptive_xml()

    print()
    print("Done. ✨")


if __name__ == "__main__":
    main()

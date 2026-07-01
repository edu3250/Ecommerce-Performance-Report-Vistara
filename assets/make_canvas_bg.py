"""
VISTARA — Generador de fondo de canvas para Power BI.
Paleta tomada del tema (deneb/sales_revenue_chart.json):
  primario   #2A6C95   |  dorado  #C2AC75   |  oscuro  #16465A
Render a 2x (2560x1440) -> usar en Power BI con "Ajustar".
"""
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter

# ---------- paleta ----------
NAVY      = (22, 70, 90)      # #16465A  azul oscuro (headers / donut)
NAVY_2    = (28, 86, 112)     # transicion header
PRIMARY   = (42, 108, 149)    # #2A6C95
GOLD      = (194, 172, 117)   # #C2AC75
CYAN      = (103, 188, 203)   # acento (segmento Active)
BASE_TOP  = (247, 250, 251)   # #F7FAFB
BASE_BOT  = (231, 238, 242)   # #E7EEF2
INK       = (47, 70, 84)
MUTED     = (120, 140, 152)

S = 2                          # supersampling / escala
W, H = 1280 * S, 720 * S

FONTS = r"C:\Windows\Fonts"
def font(name, size):
    return ImageFont.truetype(os.path.join(FONTS, name), size * S)

def vgrad(w, h, c1, c2):
    t = np.linspace(0, 1, h)[:, None]
    arr = (np.array(c1)[None, None, :] * (1 - t[:, :, None]) +
           np.array(c2)[None, None, :] * t[:, :, None])
    arr = np.repeat(arr, w, axis=1).astype(np.uint8)
    return Image.fromarray(arr, "RGB")

def hgrad(w, h, c1, c2):
    t = np.linspace(0, 1, w)[None, :]
    arr = (np.array(c1)[None, None, :] * (1 - t[:, :, None]) +
           np.array(c2)[None, None, :] * t[:, :, None])
    arr = np.repeat(arr, h, axis=0).astype(np.uint8)
    return Image.fromarray(arr, "RGB")


def build(header=True):
    img = vgrad(W, H, BASE_TOP, BASE_BOT)
    draw = ImageDraw.Draw(img, "RGBA")

    # --- watermark: anillo grande tenue abajo-derecha ---
    ov = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    od = ImageDraw.Draw(ov)
    cx, cy, r = int(W * 0.88), int(H * 0.92), int(360 * S)
    od.ellipse([cx - r, cy - r, cx + r, cy + r], outline=PRIMARY + (22,), width=44 * S)
    od.ellipse([cx - r + 90*S, cy - r + 90*S, cx + r - 90*S, cy + r - 90*S],
               outline=GOLD + (20,), width=26 * S)
    img.paste(Image.alpha_composite(img.convert("RGBA"), ov).convert("RGB"), (0, 0))
    draw = ImageDraw.Draw(img, "RGBA")

    if header:
        hh = 84 * S
        band = hgrad(W, hh, NAVY, PRIMARY)
        img.paste(band, (0, 0))
        draw = ImageDraw.Draw(img, "RGBA")
        # linea de acento dorada bajo el header
        draw.rectangle([0, hh - 4 * S, W, hh], fill=GOLD)
        # marca lateral dorada antes del titulo
        draw.rectangle([40 * S, 24 * S, 47 * S, hh - 24 * S], fill=GOLD)
        # titulo
        f_title = font("segoeuib.ttf", 30)
        f_sub   = font("segoeui.ttf", 12)
        draw.text((64 * S, 22 * S), "V I S T A R A", font=f_title, fill=(255, 255, 255))
        draw.text((66 * S, 58 * S), "CUSTOMER  ANALYTICS  ·  CHURN  &  RFM",
                  font=f_sub, fill=(206, 222, 230))
        # fecha / contexto a la derecha
        f_r = font("segoeui.ttf", 12)
        txt = "Executive Dashboard"
        tw = draw.textlength(txt, font=f_r)
        draw.text((W - tw - 48 * S, 38 * S), txt, font=f_r, fill=(206, 222, 230))

    # --- footer: linea fina + creditos ---
    fy = H - 30 * S
    draw.line([48 * S, fy, W - 48 * S, fy], fill=(*PRIMARY, 60), width=1 * S)
    f_f = font("segoeui.ttf", 11)
    draw.text((48 * S, fy + 6 * S), "VISTARA  ·  PostgreSQL → Power BI",
              font=f_f, fill=MUTED)
    rtxt = "vistara_db · schema vistara"
    rw = draw.textlength(rtxt, font=f_f)
    draw.text((W - rw - 48 * S, fy + 6 * S), rtxt, font=f_f, fill=MUTED)

    return img


out = os.path.dirname(os.path.abspath(__file__))
build(header=True).save(os.path.join(out, "vistara_canvas_bg.png"))
build(header=False).save(os.path.join(out, "vistara_canvas_bg_light.png"))
print("OK ->", out)

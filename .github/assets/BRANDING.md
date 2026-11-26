# Brand assets

| File | Size | Use |
|---|---|---|
| `logo.svg` | square, vector | master logo, scales to any size |
| `logo-mark.svg` | square, vector | logo without the rounded tile (watermarks, light backgrounds) |
| `logo-512.png` … `logo-32.png` | 512/256/128/64/32 | README, docs, favicon |
| `banner.png` | 2560 × 640 (shown at 1280 × 320) | top of the README |
| `social-preview.png` | 1280 × 640 | GitHub → Settings → General → Social preview |

## Colours

| Role | Hex |
|---|---|
| Laravel sail | `#FF6A4D` → `#E0241A` |
| Node sail | `#A6D96A` → `#3C873A` |
| Output Style accent | `#EFA081` → `#D4663F` |
| Docker water | `#2E8FE0` |
| Hull / deck | `#F4F7FB` → `#AFBDD0` |
| Navy tile | `#17263F` → `#070C16` |
| Warm tile (Output Style) | `#2A2724` → `#121110` |

Typeface: **Inter** (falls back to Segoe UI / system sans).

## Regenerating the PNGs

`banner.html` and `social-preview.html` are the sources. Screenshot them with headless Chrome:

```bash
chrome --headless --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=2 --window-size=1280,320 \
  --screenshot=banner.png banner.html

chrome --headless --disable-gpu --hide-scrollbars \
  --window-size=1280,640 \
  --screenshot=social-preview.png social-preview.html
```

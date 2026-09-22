#!/bin/sh
# OGP画像（static/og.png, 1200x630）と apple-touch-icon.png を作り直す。
# ビルド時には動かない。hugo.toml の title / params.tagline を変えたときだけ手で実行する。
#
#   sh tools/make-og.sh
#
# 必要なもの: ヘッドレスChrome（/Applications/Google Chrome.app）と python3。
set -eu

cd "$(dirname "$0")/.."
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

[ -x "$CHROME" ] || { echo "Chromeが見つからない: $CHROME" >&2; exit 1; }

python3 - "$WORK/og.html" <<'PY'
import html, sys, tomllib

with open("hugo.toml", "rb") as f:
    cfg = tomllib.load(f)

title = cfg.get("title", "")
tagline = cfg.get("params", {}).get("tagline", "")

with open("tools/og.template.html", encoding="utf-8") as f:
    tpl = f.read()

out = tpl.replace("__TITLE__", html.escape(title)).replace("__TAGLINE__", html.escape(tagline))
with open(sys.argv[1], "w", encoding="utf-8") as f:
    f.write(out)
PY

cat > "$WORK/icon.html" <<'HTML'
<!DOCTYPE html><meta charset="utf-8">
<style>*{margin:0}html,body{width:180px;height:180px}
img{width:180px;height:180px;display:block}</style>
<img src="icon.svg">
HTML
cp static/icon.svg "$WORK/icon.svg"

"$CHROME" --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 --window-size=1200,630 \
  --screenshot="$WORK/og.png" "file://$WORK/og.html" >/dev/null 2>&1

"$CHROME" --headless=new --disable-gpu --hide-scrollbars \
  --force-device-scale-factor=1 --window-size=180,180 \
  --screenshot="$WORK/apple-touch-icon.png" "file://$WORK/icon.html" >/dev/null 2>&1

mv "$WORK/og.png" static/og.png
mv "$WORK/apple-touch-icon.png" static/apple-touch-icon.png
echo "生成した: static/og.png  static/apple-touch-icon.png"

#!/bin/zsh
# Builds Machiatto.app into ./build and (with --install) copies it to /Applications and launches it.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD="$ROOT/build"
APP="$BUILD/Machiatto.app"
CONTENTS="$APP/Contents"

rm -rf "$APP"
mkdir -p "$CONTENTS/MacOS" "$CONTENTS/Resources"

swiftc -O \
  -target arm64-apple-macosx13.0 \
  -framework AppKit -framework IOKit \
  -o "$CONTENTS/MacOS/Machiatto" \
  "$ROOT/Sources/main.swift"

cp "$ROOT/Info.plist" "$CONTENTS/Info.plist"
if [[ -f "$ROOT/Assets/AppIcon.icns" ]]; then
  cp "$ROOT/Assets/AppIcon.icns" "$CONTENTS/Resources/AppIcon.icns"
fi

# Ad-hoc sign so macOS lets it run and the power assertion is attributed to the bundle.
codesign --force --sign - "$APP"

echo "Built $APP"

if [[ "${1:-}" == "--install" ]]; then
  pkill -x Machiatto 2>/dev/null || true
  rm -rf /Applications/Machiatto.app
  cp -R "$APP" /Applications/Machiatto.app
  open /Applications/Machiatto.app
  echo "Installed and launched /Applications/Machiatto.app"
fi

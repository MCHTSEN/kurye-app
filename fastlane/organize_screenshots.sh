#!/bin/bash
# Moves fastlane_*.png files from Downloads into the correct Fastlane directory structure.
# Run after clicking "🚀 Fastlane İndir" in the screenshot generator.

DOWNLOADS=~/Downloads
FASTLANE_DIR="$(dirname "$0")/screenshots/tr-TR"

# App Store (deliver) — grouped by device size
mkdir -p "$FASTLANE_DIR/iPhone6.9\""
mkdir -p "$FASTLANE_DIR/iPhone6.5\""

echo "📂 Moving App Store screenshots..."
for f in "$DOWNLOADS"/fastlane_iPhone6.9_*.png; do
  [ -f "$f" ] || continue
  name=$(basename "$f" | sed 's/fastlane_iPhone6\.9_//')
  cp "$f" "$FASTLANE_DIR/iPhone6.9\"/$name"
  echo "  ✓ iPhone6.9\" → $name"
done

for f in "$DOWNLOADS"/fastlane_iPhone6.5_*.png; do
  [ -f "$f" ] || continue
  name=$(basename "$f" | sed 's/fastlane_iPhone6\.5_//')
  cp "$f" "$FASTLANE_DIR/iPhone6.5\"/$name"
  echo "  ✓ iPhone6.5\" → $name"
done

# Google Play (supply) — uses any size, put in phoneScreenshots/
mkdir -p "$FASTLANE_DIR/phoneScreenshots"
echo "📂 Copying Play Store screenshots..."
for f in "$DOWNLOADS"/fastlane_iPhone6.9_*.png; do
  [ -f "$f" ] || continue
  name=$(basename "$f" | sed 's/fastlane_iPhone6\.9_//')
  cp "$f" "$FASTLANE_DIR/phoneScreenshots/$name"
  echo "  ✓ phoneScreenshots/ → $name"
done

echo ""
echo "✅ Done! Now run:"
echo "   cd $(dirname "$0")/.."
echo "   fastlane ios upload_screenshots     # App Store"
echo "   fastlane android upload_screenshots # Google Play"

#!/bin/bash
set -e

# Flutter Project Rename Script
# Usage: ./rename.sh <new_name> [bundle_id]
# Example: ./rename.sh myapp com.company.myapp

NEW_NAME=$1
BUNDLE_ID=${2:-"com.example.$NEW_NAME"}
OLD_NAME="eipat"
OLD_BUNDLE="com.example.eipat"
OLD_CLASS="EipatApp"

if [ -z "$NEW_NAME" ]; then
  echo "Usage: ./rename.sh <new_name> [bundle_id]"
  echo "Example: ./rename.sh myapp com.company.myapp"
  exit 1
fi

# Convert new_name to PascalCase for class name (e.g. bursamotokurye → BursamotoKurye, my_app → MyApp)
NEW_CLASS=$(echo "$NEW_NAME" | sed -E 's/(^|_)([a-z])/\U\2/g')
NEW_CLASS="${NEW_CLASS}App"

echo "Renaming project: $OLD_NAME → $NEW_NAME"
echo "Bundle ID: $OLD_BUNDLE → $BUNDLE_ID"
echo "App class: $OLD_CLASS → $NEW_CLASS"
echo ""

# 1. Dart (pubspec + imports + class name)
echo "[1/10] Dart package name & class rename..."
sed -i '' "s/name: $OLD_NAME/name: $NEW_NAME/" pubspec.yaml
find lib test integration_test -name '*.dart' -exec sed -i '' "s/package:$OLD_NAME/package:$NEW_NAME/g" {} +
find lib test integration_test -name '*.dart' -exec sed -i '' "s/$OLD_CLASS/$NEW_CLASS/g" {} +

# 2. Android
echo "[2/10] Android..."
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" android/app/build.gradle.kts
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" android/app/src/main/AndroidManifest.xml
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" android/app/src/main/kotlin/com/example/$OLD_NAME/MainActivity.kt

OLD_PACKAGE_DIR="android/app/src/main/kotlin/$(echo $OLD_BUNDLE | tr '.' '/')"
NEW_PACKAGE_DIR="android/app/src/main/kotlin/$(echo $BUNDLE_ID | tr '.' '/')"
if [ "$OLD_PACKAGE_DIR" != "$NEW_PACKAGE_DIR" ]; then
  mkdir -p "$NEW_PACKAGE_DIR"
  mv "$OLD_PACKAGE_DIR/MainActivity.kt" "$NEW_PACKAGE_DIR/"
  # Clean up empty old directories
  rmdir -p "$OLD_PACKAGE_DIR" 2>/dev/null || true
fi

# 3. iOS
echo "[3/10] iOS..."
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" ios/Runner.xcodeproj/project.pbxproj
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" ios/Runner/Info.plist

# 4. macOS
echo "[4/10] macOS..."
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" macos/Runner/Configs/AppInfo.xcconfig
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" macos/Runner/Configs/AppInfo.xcconfig
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme

# 5. Windows
echo "[5/10] Windows..."
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" windows/CMakeLists.txt
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" windows/runner/main.cpp
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" windows/runner/Runner.rc

# 6. Linux
echo "[6/10] Linux..."
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" linux/CMakeLists.txt
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" linux/CMakeLists.txt
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" linux/runner/my_application.cc

# 7. Web
echo "[7/10] Web..."
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" web/index.html
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" web/manifest.json

# 8. App title
echo "[8/10] App title..."
sed -i '' "s/'$OLD_NAME'/'$NEW_NAME'/g" lib/app/app.dart

# 9. Verify no old references remain
echo "[9/10] Verifying rename..."
REMAINING=$(grep -r "package:$OLD_NAME" lib test integration_test --include='*.dart' -l 2>/dev/null || true)
if [ -n "$REMAINING" ]; then
  echo "WARNING: Old package references still found in:"
  echo "$REMAINING"
fi

# 10. Clean & get
echo "[10/10] Flutter clean & pub get..."
flutter clean
flutter pub get

echo ""
echo "Done! Project renamed to '$NEW_NAME' ($BUNDLE_ID)"
echo "App class: $NEW_CLASS"
echo "Run 'flutter analyze' to verify no issues remain."

#!/bin/bash
set -e

# Flutter Project Rename Script
# Usage: ./rename.sh <new_name> [bundle_id]
# Example: ./rename.sh myapp com.company.myapp

NEW_NAME=$1
BUNDLE_ID=${2:-"com.example.$NEW_NAME"}
OLD_NAME="eipat"
OLD_BUNDLE="com.example.eipat"

if [ -z "$NEW_NAME" ]; then
  echo "Usage: ./rename.sh <new_name> [bundle_id]"
  echo "Example: ./rename.sh myapp com.company.myapp"
  exit 1
fi

echo "Renaming project: $OLD_NAME → $NEW_NAME"
echo "Bundle ID: $OLD_BUNDLE → $BUNDLE_ID"
echo ""

# 1. Dart (pubspec + imports)
echo "[1/9] Dart package name..."
sed -i '' "s/name: $OLD_NAME/name: $NEW_NAME/" pubspec.yaml
find lib test -name '*.dart' -exec sed -i '' "s/package:$OLD_NAME/package:$NEW_NAME/g" {} +

# 2. Android
echo "[2/9] Android..."
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
echo "[3/9] iOS..."
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" ios/Runner.xcodeproj/project.pbxproj
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" ios/Runner/Info.plist

# 4. macOS
echo "[4/9] macOS..."
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" macos/Runner/Configs/AppInfo.xcconfig
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" macos/Runner/Configs/AppInfo.xcconfig
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme

# 5. Windows
echo "[5/9] Windows..."
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" windows/CMakeLists.txt
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" windows/runner/main.cpp
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" windows/runner/Runner.rc

# 6. Linux
echo "[6/9] Linux..."
sed -i '' "s/$OLD_BUNDLE/$BUNDLE_ID/g" linux/CMakeLists.txt
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" linux/CMakeLists.txt
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" linux/runner/my_application.cc

# 7. Web
echo "[7/9] Web..."
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" web/index.html
sed -i '' "s/$OLD_NAME/$NEW_NAME/g" web/manifest.json

# 8. App title
echo "[8/9] App title..."
sed -i '' "s/'$OLD_NAME'/'$NEW_NAME'/g" lib/app/app.dart

# 9. Clean & get
echo "[9/9] Flutter clean & pub get..."
flutter clean
flutter pub get

echo ""
echo "Done! Project renamed to '$NEW_NAME' ($BUNDLE_ID)"
echo "You can now delete this script: rm rename.sh"

#!/bin/zsh
# Builds a Developer ID signed Compositor DMG, notarized unless explicitly skipped.
#
# Needs, all kept out of this repository:
#   - a "Developer ID Application" certificate in the login keychain
#   - notarization credentials saved once with:
#       xcrun notarytool store-credentials "dm-notary" --apple-id "…" --team-id "…"
#   - RELEASE_TEAM set to the team owning the signing certificate
# Set SKIP_NOTARIZATION=1 only for a release documented as not notarized.
# create-dmg is optional; hdiutil provides a plain DMG when it is not installed.
# The DMG window background is scripts/dmg/dmg-bg.jpg (600 × 380, the window's exact size) plus
# dmg-bg-retina.jpg (1200 × 760) for Retina displays.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP=Compositor
TEAM="${RELEASE_TEAM:?Set RELEASE_TEAM to the team owning your Developer ID certificate}"
IDENTITY="${RELEASE_IDENTITY:-Developer ID Application}"
NOTARY_PROFILE="${NOTARY_PROFILE:-dm-notary}"
SKIP_NOTARIZATION="${SKIP_NOTARIZATION:-0}"
# Built outside Dropbox: the extended attributes it adds to files make code signing fail.
WORK="$HOME/Library/Caches/CompositorChineseRelease"
DIST="$PROJECT_DIR/dist"

settings=$(xcodebuild -project "$PROJECT_DIR/$APP.xcodeproj" -scheme "$APP" -configuration Release -showBuildSettings 2>/dev/null)
VERSION=$(print -r -- "$settings" | awk -F' = ' '/ MARKETING_VERSION = /{print $2; exit}')
BUILD=$(print -r -- "$settings" | awk -F' = ' '/ CURRENT_PROJECT_VERSION = /{print $2; exit}')
echo "==> $APP $VERSION ($BUILD)"
[[ "$SKIP_NOTARIZATION" == 0 || "$SKIP_NOTARIZATION" == 1 ]] || { echo "SKIP_NOTARIZATION must be 0 or 1"; exit 1; }
security find-identity -v -p codesigning | grep -F "$IDENTITY" >/dev/null || { echo "Developer ID certificate not found: $IDENTITY"; exit 1; }
if [[ "$SKIP_NOTARIZATION" == 0 ]]; then
  xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null
fi

mkdir -p "$WORK" "$DIST"
rm -rf "$WORK/$APP.xcarchive" "$WORK/export" "$WORK/dmg"
cp "$PROJECT_DIR/scripts/ExportOptions.plist" "$WORK/ExportOptions.plist"
/usr/libexec/PlistBuddy -c "Set :teamID $TEAM" "$WORK/ExportOptions.plist"
/usr/libexec/PlistBuddy -c "Set :signingCertificate $IDENTITY" "$WORK/ExportOptions.plist"

echo "==> Archiving a Release build"
xcodebuild archive -quiet \
  -project "$PROJECT_DIR/$APP.xcodeproj" -scheme "$APP" -configuration Release \
  -destination "generic/platform=macOS" \
  -archivePath "$WORK/$APP.xcarchive" -derivedDataPath "$WORK/DerivedData" \
  CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY="$IDENTITY" DEVELOPMENT_TEAM="$TEAM"

echo "==> Exporting, signed with Developer ID"
xcodebuild -exportArchive -quiet \
  -archivePath "$WORK/$APP.xcarchive" \
  -exportOptionsPlist "$WORK/ExportOptions.plist" \
  -exportPath "$WORK/export"
APP_PATH="$WORK/export/$APP.app"
codesign --verify --deep --strict --verbose=2 "$APP_PATH"

if [[ "$SKIP_NOTARIZATION" == 0 ]]; then
  echo "==> Notarizing the app"
  ditto -c -k --keepParent "$APP_PATH" "$WORK/$APP.zip"
  xcrun notarytool submit "$WORK/$APP.zip" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$APP_PATH"
  xcrun stapler validate "$APP_PATH"
fi

echo "==> Building the DMG window"
STAGE="$WORK/dmg"
mkdir -p "$STAGE"
cp -R "$APP_PATH" "$STAGE/"
DMG="$DIST/$APP-$VERSION.dmg"
rm -f "$DMG"
# Icon centers in the DMG window, in points from its top-left.
APP_X=160
APPLICATIONS_X=440
ICON_Y=180
background=()
LOW="$PROJECT_DIR/scripts/dmg/dmg-bg.jpg"
HIGH="$PROJECT_DIR/scripts/dmg/dmg-bg-retina.jpg"
if [[ -f "$LOW" && -f "$HIGH" ]]; then
  # Finder takes one background file; a TIFF holding both sizes stays sharp on Retina displays.
  sips -s format png -s dpiWidth 72 -s dpiHeight 72 "$LOW" --out "$WORK/background.png" >/dev/null
  sips -s format png -s dpiWidth 144 -s dpiHeight 144 "$HIGH" --out "$WORK/background@2x.png" >/dev/null
  tiffutil -cathidpicheck "$WORK/background.png" "$WORK/background@2x.png" -out "$WORK/background.tiff" >/dev/null
  background=(--background "$WORK/background.tiff")
elif [[ -f "$LOW" ]]; then
  background=(--background "$LOW")
fi
if command -v create-dmg >/dev/null; then
  create-dmg \
  --volname "$APP" \
  --window-pos 200 120 --window-size 600 380 \
  --icon-size 128 --text-size 13 \
  --icon "$APP.app" "$APP_X" "$ICON_Y" --hide-extension "$APP.app" \
  --app-drop-link "$APPLICATIONS_X" "$ICON_Y" \
  "${background[@]}" \
  "$DMG" "$STAGE"
else
  ln -s /Applications "$STAGE/Applications"
  hdiutil create -volname "$APP" -srcfolder "$STAGE" -ov -format UDZO "$DMG"
fi

echo "==> Signing the DMG"
codesign --sign "$IDENTITY" --timestamp "$DMG"
codesign --verify --strict --verbose=2 "$DMG"
if [[ "$SKIP_NOTARIZATION" == 0 ]]; then
  echo "==> Notarizing the DMG"
  xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$DMG"
  xcrun stapler validate "$DMG"

  echo "==> What Gatekeeper will say on another Mac"
  spctl --assess --type open --context context:primary-signature --verbose=2 "$DMG"
  spctl --assess --type execute --verbose=2 "$APP_PATH"
  syspolicy_check distribution "$APP_PATH"
else
  echo "==> Signed, not notarized. Include that status in the release notes."
fi
echo "==> Done: $DMG"

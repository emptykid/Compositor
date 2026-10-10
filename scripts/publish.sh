#!/bin/zsh
# Publishes the DMG that release.sh built: a GitHub Release (v<version>) holding Compositor.dmg, then the Sparkle
# update feed (appcast.xml, committed to main) pointing at it.
#
# Run release.sh first. Needs the emptykid.Compositor Sparkle signing key in the login keychain and `gh` signed in.
# Release notes, a change a line: RELEASE_NOTES=$'First change\nSecond change' ./scripts/publish.sh
# They're listed on the GitHub Release and in the update alert (the feed item's <changes>).
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP=Compositor
REPO=emptykid/Compositor
SIGNING_ACCOUNT=emptykid.Compositor
WORK="$HOME/Library/Caches/CompositorChineseRelease"
SIGN_UPDATE="$WORK/DerivedData/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update"

settings=$(xcodebuild -project "$PROJECT_DIR/$APP.xcodeproj" -scheme "$APP" -configuration Release -showBuildSettings 2>/dev/null)
VERSION=$(print -r -- "$settings" | awk -F' = ' '/ MARKETING_VERSION = /{print $2; exit}')
BUILD=$(print -r -- "$settings" | awk -F' = ' '/ CURRENT_PROJECT_VERSION = /{print $2; exit}')
MINIMUM=$(print -r -- "$settings" | awk -F' = ' '/ MACOSX_DEPLOYMENT_TARGET = /{print $2; exit}')
TAG="v$VERSION"
[[ -z "$(git -C "$PROJECT_DIR" status --porcelain)" ]] || { echo "Commit all release changes before publishing."; exit 1; }
[[ "$(git -C "$PROJECT_DIR" branch --show-current)" == main ]] || { echo "Publish from main."; exit 1; }
origin=$(git -C "$PROJECT_DIR" remote get-url origin)
[[ "$origin" == "git@github.com:$REPO.git" || "$origin" == "https://github.com/$REPO.git" || "$origin" == "https://github.com/$REPO" ]] || { echo "origin must point to $REPO"; exit 1; }
SOURCE_COMMIT=$(git -C "$PROJECT_DIR" rev-parse HEAD)
SOURCE="$PROJECT_DIR/dist/$APP-$VERSION.dmg"
[[ -f "$SOURCE" ]] || { echo "No $SOURCE — run scripts/release.sh first."; exit 1; }
[[ -x "$SIGN_UPDATE" ]] || { echo "Sparkle's sign_update isn't built — run scripts/release.sh first."; exit 1; }
if gh release view "$TAG" --repo "$REPO" >/dev/null 2>&1; then
  echo "Release $TAG already exists. Raise the version (and build number) first."
  exit 1
fi

echo "==> $APP $VERSION ($BUILD)"
# Every release names its file Compositor.dmg, so …/releases/latest/download/Compositor.dmg always works.
mkdir -p "$WORK/publish"
DMG="$WORK/publish/$APP.dmg"
cp "$SOURCE" "$DMG"
(cd "$WORK/publish" && shasum -a 256 "$APP.dmg" > SHA256SUMS)

echo "==> Signing the update for Sparkle"
signature=$("$SIGN_UPDATE" --account "$SIGNING_ACCOUNT" "$DMG")

changes=("${(@f)${RELEASE_NOTES:-}}")
changes=(${changes:#})
[[ "${RELEASE_NOTES:-}" != *']]>'* ]] || { echo "RELEASE_NOTES can't contain ]]>."; exit 1; }
notes="$APP $VERSION"
(( ${#changes} )) && notes=$(printf -- '- %s\n' "${changes[@]}")
NOTES_PATH="${RELEASE_NOTES_FILE:-$WORK/publish/notes.md}"
[[ -n "${RELEASE_NOTES_FILE:-}" ]] || print -r -- "$notes" > "$NOTES_PATH"
[[ -f "$NOTES_PATH" ]] || { echo "Release notes file not found: $NOTES_PATH"; exit 1; }
changes_xml=""
(( ${#changes} )) && changes_xml="
      <changes><![CDATA[${(pj:\n:)changes}]]></changes>"

echo "==> Creating GitHub Release $TAG"
gh release create "$TAG" "$DMG" "$WORK/publish/SHA256SUMS" --repo "$REPO" --target "$SOURCE_COMMIT" --draft \
  --title "$APP $VERSION 简体中文版" --notes-file "$NOTES_PATH"

echo "==> Publishing the update feed"
cat > "$PROJECT_DIR/appcast.xml" <<XML
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">
  <channel>
    <title>$APP 简体中文版</title>
    <item>
      <title>Version $VERSION</title>
      <pubDate>$(LC_ALL=C date -u "+%a, %d %b %Y %H:%M:%S +0000")</pubDate>
      <sparkle:version>$BUILD</sparkle:version>
      <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
      <sparkle:minimumSystemVersion>$MINIMUM</sparkle:minimumSystemVersion>
      <link>https://github.com/$REPO/releases/tag/$TAG</link>$changes_xml
      <enclosure url="https://github.com/$REPO/releases/download/$TAG/$APP.dmg" $signature type="application/octet-stream"/>
    </item>
  </channel>
</rss>
XML
git -C "$PROJECT_DIR" add appcast.xml
git -C "$PROJECT_DIR" commit -q -m "Publish update feed for $APP $VERSION"
git -C "$PROJECT_DIR" push -q
gh release edit "$TAG" --repo "$REPO" --draft=false --latest
echo "==> Done: https://github.com/$REPO/releases/tag/$TAG"

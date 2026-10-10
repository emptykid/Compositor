# Localization

Compositor supports English and Simplified Chinese (`zh-Hans`). The app follows macOS language preferences, including the language selected for Compositor in System Settings > General > Language & Region > Applications. Quit and reopen the app after changing its language. There is no separate in-app language setting.

## Adding or changing text

Translations live in `Compositor/Resources/Localizable.xcstrings`. Add both English and Simplified Chinese translations when adding UI text. Keep standard image-editing terms consistent: layer = 图层, mask = 蒙版, clipping mask = 剪贴蒙版, opacity = 不透明度, blend mode = 混合模式.

- SwiftUI literals such as `Text("Preview")` use native localization. For a custom view accepting a built-in label as a `String`, use `L10n.string(title)` at the display boundary.
- AppKit labels, alerts, error descriptions, and interpolated messages use `String(localized: "…")`. Localize interpolated built-in labels before inserting them into the surrounding message.
- `L10n.string` looks up a complete, stable key. It cannot translate an interpolated sentence after its variables have been substituted. Use `String(localized:)` for these sentences instead.
- Do not localize user-entered text, imported names, file paths, accessibility identifiers, SF Symbol names, Core Image keys, or persisted enum raw values.
- Shortcut IDs retain their existing English group and title strings for compatibility with saved settings. Translate `localizedTitle` and the group at display time. Generated shortcut titles also need entries in the catalog.
- AppKit menu actions must identify values using `representedObject`, an identifier, or the action selector, rather than parsing translated titles. Blend modes store their original raw value in `representedObject`.

The project format and stored enum values are unchanged. Generated names such as “Layer 1” are localized when created and then become ordinary editable document content. Opening a project in another language does not translate its existing layer names.

String catalog symbol generation is disabled because existing English keys include punctuation, Swift keywords, and names that would generate duplicate symbols. The app uses the native string APIs directly.

## Validation

Build Debug, then check that translations contain matching format arguments and cover all strings extracted by the compiler:

```sh
xcodebuild -project Compositor.xcodeproj -scheme Compositor -configuration Debug -destination 'platform=macOS' -derivedDataPath /tmp/Compositor-dev build
python3 scripts/check-localizations.py --derived-data /tmp/Compositor-dev
xcodebuild -project Compositor.xcodeproj -scheme Compositor -destination 'platform=macOS' -derivedDataPath /tmp/Compositor-dev -testLanguage en test -only-testing:CompositorTests
xcodebuild -project Compositor.xcodeproj -scheme Compositor -destination 'platform=macOS' -derivedDataPath /tmp/Compositor-dev -testLanguage zh-Hans -testRegion CN test -only-testing:CompositorTests/LocalizationTests -only-testing:CompositorTests/FloatingPanelTests
```

Runtime string lookups are not automatically extracted, so review their catalog entries separately. The localization tests check compiled resources, Chinese command search, blend-mode selection and undo with translated titles, project enum values, and historical shortcut IDs. Existing tests that assert English UI text should run with `-testLanguage en`.

Preview either language without changing the saved language preference:

```sh
open -n /tmp/Compositor-dev/Build/Products/Debug/Compositor.app --args -AppleLanguages '(zh-Hans)' -AppleLocale zh_CN
open -n /tmp/Compositor-dev/Build/Products/Debug/Compositor.app --args -AppleLanguages '(en)' -AppleLocale en_US
```

Check the welcome screen, main menus, layer context menu, blend modes, command search, Camera Raw, export dialogs, and unsaved-change alerts. Review narrow labels and long help text in both languages. Release notes supplied by the update feed remain in their source language; this fork publishes Chinese release notes.

## Fork releases

The Chinese edition keeps the marketing version and build number of the upstream release being localized. Its `SUFeedURL` points to `emptykid/Compositor`, and `SUPublicEDKey` is this fork's public key. The private update-signing key is stored in the maintainer's login keychain under the Sparkle account `emptykid.Compositor`, outside the repository. Never copy the upstream update feed or signing key into a Chinese release: that would offer packages without this fork's maintained translations.

See [Releasing](../README.md#releasing) for signing, notarization and publishing. Keep the release notes explicit about whether a particular package was notarized.

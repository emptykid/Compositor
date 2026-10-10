# Compositor · Simplified Chinese

[English](README.md) | [简体中文](README.zh-CN.md)

This repository is an independently maintained **Simplified Chinese localization fork** of [robbietilton/Compositor](https://github.com/robbietilton/Compositor), created by Robbie Tilton. It follows upstream features and version numbers; changes here are limited to localization and the packaging needed to distribute the Chinese edition. It is not an official upstream release.

The current Chinese edition is **1.4.9 (build 44)**, based on upstream [v1.4.9](https://github.com/robbietilton/Compositor/releases/tag/v1.4.9), commit `0ab3ff5`. Future versions will follow upstream as they are merged and their translations are verified; synchronization is maintained manually.

The following describes the original project's purpose and features:

Adobe Photoshop costs too much and tools like GIMP don’t feel familiar enough for me to stay in flow. That’s why I built Compositor.

The goal was to create a full-featured image editor that is completely free and open source. I used to use Photoshop for compositing and post-processing, so Compositor is built around that workflow - with the tools needed to create a pixel-perfect final image.

Because it’s open source, you can download the Xcode project and add, remove, or modify any feature to fit your workflow.

## Installation

### Download
Download the Chinese edition from [this fork's GitHub Releases](https://github.com/emptykid/Compositor/releases/latest). Open the DMG and drag `Compositor.app` into Applications.

The app includes English and Simplified Chinese and follows macOS language preferences. To select Chinese just for this app, use **System Settings > General > Language & Region > Applications > Compositor > Simplified Chinese**, then quit and reopen it.

This fork uses its own signed update feed. Upstream downloads and Homebrew packages install the original edition, not this Chinese fork. See each release's notes for its signing and notarization status.

The current Chinese 1.4.9 package is Developer ID signed but **not Apple notarized**. macOS may block its first launch; see [Apple's guidance](https://support.apple.com/102445) or build from source.

### Original edition (upstream)

The original edition is available from [robbietilton.com/compositor](https://robbietilton.com/compositor), [upstream GitHub Releases](https://github.com/robbietilton/Compositor/releases/latest), or Homebrew:

```sh
brew install --cask robbietilton-compositor
```

## Features

### Layers
- Layers and folders, with opacity and Photoshop's full set of blend modes in its order — a folder's opacity dims everything inside it
- Layer masks: paint, fill, invert, blur and feather them anywhere on the canvas, past the layer's own pixels; link or unlink them to transform a mask on its own
- Clipping masks and folder masks
- Adjustment layers: Hue/Saturation, Levels, Curves, Exposure, Gradient Map, Grain, Black & White, Color Balance, Invert, Gaussian Blur, Motion Blur and Noise
- Layer effects: Stroke, Drop Shadow, Color Overlay, Inner Shadow, Outer Glow and Inner Glow, rendered on the GPU and editable at any time
- Merge Down, Merge Layers and Merge Group (⌘E)
- Duplicate, rename inline, reorder and nest by drag and drop; Option-drag to duplicate; a right-click menu in the Layers panel
- Copy and paste whole layers and folders (⌘C/⌘V with no selection), within a project or between projects, or drag them between projects

### Transform
- Non-destructive move, scale, rotate and flip — images keep their full resolution however small you make them
- Free distort (⌘-drag a handle), with Shift to lock to an axis
- Transform several layers, or a whole folder, together
- Snapping to canvas and layer edges and centers, with guides
- Exact values for position, size, scale and angle, stepped with the arrow keys
- Flip Layer and Flip Canvas, horizontal and vertical

### Selections
- Rectangle and Ellipse Marquee, Freehand and Polygonal Lasso, and the Magic tool — Wand selects by color, Object traces whatever you click (Tab switches)
- Select Subject, and Expand, Contract and Feather on any selection
- Add to and subtract from selections, move the outline, or move and duplicate the pixels inside
- Load a layer's pixels or a mask as a selection
- Content-Aware Fill, which can also extend an image past its edges

### Painting and retouching
- Brush with size, hardness, opacity and smoothing, in Paint or Erase mode (B and E), and Shift for straight lines
- Spot Healing Brush (content-aware)
- Clone Stamp, aligned or not, sampling one layer or all of them
- Blur tool, on pixels or masks
- Gradient tool and Shape tool (rectangles, rounded rectangles, ellipses and lines), which stay editable rather than being rasterized
- Type tool (T): inline multiline editing in draggable, resizable paragraph boxes; font, size, color, alignment and spacing in the tool header; transform text and use it as a clipping mask
- Eyedropper and a full color picker

### Adjustments and filters
- Camera Raw filter: light, color, curves, color mixer, color grading, detail, optics and geometry, in a panel beside the canvas
- Levels (with Auto), Curves, Hue/Saturation, Exposure, Gradient Map, Grain, Black & White, Color Balance and Invert
- Gaussian Blur and Motion Blur that spread past a layer's edges
- Add Noise, Vignette, Bloom / Glow, Dither, Scanlines, Tonal Contrast, Lens Correction and Remove Background
- Live previews, limited to the selection when there is one
- Last Filter (⌃⌘F) runs the last filter again with the same settings

### Canvas and files
- Multiple projects in tabs
- Search Commands (⌘F): find every menu command and tool by name, as in Raycast or Obsidian, and run it with Return
- Toggle Fullscreen (F): the canvas alone on black over the whole screen, with every panel put away; F or Esc brings them back
- Rulers (⌘R), guides dragged from them, a layout grid with adjustable spacing and subdivisions, and Snap To for guides, grid, layers and document bounds
- Crop with snapping, ratios including 3:4 and 9:16, and Option for symmetric cropping; with a selection, the crop starts at it
- Canvas Size, Image Size and Trim
- A Navigator minimap in the canvas's corner from 300% zoom: the whole document in small with a box around the view; click or drag to move there (View › Navigator)
- Sharp high-quality downsampling when zoomed out, and a pixel grid when zoomed in
- Import JPEG, PNG, HEIC, TIFF, WebP, SVG, camera RAW (with a develop step first) and Photoshop PSD and PSB (8-bit RGB; not CMYK). Photoshop folders, masks, blend modes, fill rectangles/ellipses, and simple horizontal text stay editable; other vectors and vertical text become pixels. A conversion report is shown before anything is applied.
- Large documents: the memory budget scales with your Mac, and a Photoshop file too big to open has its layers cropped to the canvas instead
- Export PNG (⇧⌘E), Export JPEG (⇧⌥⌘S), and Export As (⇧⌥⌘W) for PNG, JPEG or a one-page PDF at the print size, scaled if you like, with a live preview, JPEG quality and file size; Copy Merged
- Keep working while a project saves
- Photoshop-style keyboard shortcuts throughout, remappable in Edit > Keyboard Shortcuts
- Drag a number's label to scrub its value, as in Photoshop
- Automatic updates through this fork’s signed update feed; see release notes for notarization status

### Works with AI agents
- AI agents and scripts can build and edit projects directly: a `.comp` is a folder of PNG layers and a manifest, and an open project updates live as it's written. See [Writing Compositor projects](docs/writing-comp-files.md)

## Requirements

- macOS 26.0 or later on a Mac with Apple silicon
- Xcode 26 or later (to build from source)

## Translations

This branch supports English and Simplified Chinese, following the macOS language preference for the app. Read the [中文说明](README.zh-CN.md) for the fork’s scope and installation instructions. See [Localization](docs/localization.md) for translation and validation instructions. Upstream currently does not accept localization pull requests; these translations are maintained in this branch.

## Building

Open `Compositor.xcodeproj` and run the **Compositor** scheme.

## Releasing

Keep `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` aligned with the upstream release being localized. This fork publishes tags such as `v1.4.9` in its own repository; it does not modify upstream tags or releases.

`scripts/release.sh` builds a Release version, signs it with your Developer ID certificate, notarizes it, and packages it as `dist/Compositor-<version>.dmg`. It needs a Developer ID Application certificate and a `notarytool` credential profile in your local keychain. Credentials and private keys stay outside this repository. `create-dmg` is optional; the script falls back to `hdiutil`.

```sh
RELEASE_TEAM=<your-team-id> NOTARY_PROFILE=<your-keychain-profile> ./scripts/release.sh
RELEASE_NOTES_FILE=RELEASE_NOTES.md ./scripts/publish.sh
```

For an explicitly documented, signed but **not notarized** release, set `SKIP_NOTARIZATION=1` when building. Such a release may be blocked by macOS Gatekeeper on first launch; it must not be described as notarized.

The publish script targets **emptykid/Compositor**, uses the Sparkle signing key stored under account `emptykid.Compositor`, uploads a draft release, publishes this fork’s `appcast.xml`, and then makes the release public. Commit and push all source and documentation changes before publishing.

## License

MIT — see [LICENSE](LICENSE). The original application is by [Robbie Tilton and upstream contributors](https://github.com/robbietilton/Compositor). This fork maintains the Simplified Chinese localization.

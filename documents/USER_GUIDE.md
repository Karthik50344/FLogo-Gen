# Flutter Logo Generator — User Guide

Flutter Logo Generator turns one logo image into a complete set of
platform-ready icons for a Flutter app — sized, named, and organized
into the exact folders Flutter expects for Android, iOS, Web, Linux,
Windows, and macOS. Everything runs in your browser; nothing is ever
uploaded anywhere.

> This same guide is available inside the app itself — click **User
> Guide** in the footer at any time.

## Quick start

1. **Upload your logo** (Step 1) — drag a PNG/SVG/JPG/WEBP onto the
   drop zone, or click it to browse. Square images work best. Max
   file size is 20MB.
2. **Select platforms** (Step 2) — tap each platform you're shipping
   to. Use **Select All** or **Clear** to speed this up.
3. **Set image options** (Step 3) — toggle background removal,
   notification icon generation, and Android adaptive icons.
4. **Choose a notification icon theme** (Step 4) — pick Both, Light
   only, or Dark only, and adjust the background/icon colors.
5. **Check the output preview** (Step 5) — a live tree view shows
   exactly what will be in your ZIP before you download anything.
6. **Generate & Download ZIP** — click the button. A progress
   overlay shows each processing step, then your browser downloads
   `flutter_assets.zip`.

## Step-by-step details

### 1. Upload Logo

- Accepted formats: PNG, SVG, JPG, WEBP.
- Square, high-resolution source images give the cleanest results —
  the app upscales/downscales from a single 1024×1024 working copy,
  so starting below ~512×512 can look soft at the largest sizes
  (like the 1024×1024 iOS marketing icon).
- Your file never leaves your device. Everything is processed in
  memory in the browser tab.
- Click **Remove** on the preview to start over with a different
  image.

### 2. Select Platforms

Each platform generates a different bundle:

| Platform | What you get |
|---|---|
| **Android** | `mipmap-*` launcher icons (regular + round), Play Store 512×512 icon, and adaptive icon layers if enabled |
| **iOS** | Full `AppIcon.appiconset` (all required sizes) + `Contents.json` |
| **Web** | Favicon, standard PWA icons, and maskable icons for `manifest.json` |
| **Linux** | Desktop icon at the standard GTK sizes |
| **Windows** | A multi-resolution `.ico` plus a 256×256 PNG app icon |
| **macOS** | Full `AppIcon.appiconset` iconset + `Contents.json` |

You can select any combination — the output only includes what you
pick.

### 3. Image Options

- **Remove Background** — strips a white/light background from your
  logo using edge-color sampling. Works best on logos with a clean,
  solid, or near-white background. Complex photographic backgrounds
  may show artifacts around edges — check the preview tree/output
  before shipping if you're unsure.
- **Generate Notification Icon** — produces a flat, single-color
  silhouette icon suitable for status-bar/notification use (Android
  requires monochrome notification icons; other platforms accept
  full-color, but a silhouette is provided for consistency).
- **Adaptive Icon (Android)** — generates the separate foreground and
  background layers Android 8+ uses to animate and mask your icon
  (circle, squircle, rounded square, etc. depending on the device
  launcher).

### 4. Notification Icon Theme

Pick whether you need a light-mode icon, a dark-mode icon, or both,
then adjust:

- **Background color** — the fill behind your icon silhouette.
- **Icon color** — the silhouette color itself.

Tap a color swatch to open the color picker (hue/saturation/
brightness sliders, or type a hex code directly).

### 5. Output Structure Preview

This updates live as you change platforms/options so you can confirm
the ZIP's folder layout before generating anything.

### Generate & Download ZIP

Once you're happy with your selections, click **Generate & Download
ZIP**. You'll see a short progress sequence (loading → processing →
per-platform generation → packaging → download), then your browser
saves `flutter_assets.zip` to your downloads folder.

## Using the output in your Flutter project

The ZIP mirrors your project's real folder structure. For each
platform you selected, copy the matching folder's contents into the
same path in your Flutter project, overwriting the existing icon
files:

- `android/...` → your project's `android/` folder
- `ios/...` → your project's `ios/` folder
- `web/...` → your project's `web/` folder
- `linux/...` → your project's `linux/` folder
- `windows/...` → your project's `windows/` folder
- `macos/...` → your project's `macos/` folder
- `notification/...` → wherever your app expects notification assets
  (these aren't auto-wired into any platform config — add them to
  your notification plugin's setup manually)

A `README.md` is included in every ZIP with the same instructions,
generated specifically for the platforms/options you picked.

## Privacy

See the in-app **Privacy Policy** (footer link) for full details.
In short: your image and every generated asset stay on your device.
Nothing is uploaded to a server, and no analytics or tracking is
included in the app.

## Troubleshooting

- **My logo looks blurry in the largest icon sizes** — start from a
  higher-resolution source image (ideally 1024×1024 or larger).
- **Background removal left a faint edge/halo** — try a source image
  with a more uniform background color, or skip background removal
  and pre-clean the image in an image editor first.
- **The ZIP is missing a platform I expected** — double-check it's
  selected (highlighted with a checkmark) in Step 2 before
  generating.
- **Nothing downloads when I click Generate** — check your browser
  isn't blocking the download/popup; the app doesn't need any
  permission beyond a normal file download.
- **Still stuck?** — click **Contact Us** in the footer to email the
  maintainer directly.
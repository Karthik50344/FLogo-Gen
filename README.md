# Flutter Logo Generator (Flutter Web port)

A pixel-for-pixel Flutter Web port of the original single-file HTML tool.
Upload a logo once, pick your target platforms, and download a ZIP with
every icon Flutter expects — sized, named, and folder-structured exactly
right (Android mipmaps + adaptive icons, iOS AppIcon.appiconset, Web
icons, Linux, Windows ICO, macOS iconset), plus optional light/dark
notification icons. All processing happens client-side in the browser;
nothing is uploaded anywhere.

## Setup

This project was authored by hand in an offline sandbox (no access to
pub.dev), so it has **not** been run through `flutter pub get` or
`flutter analyze` yet. Do that first:

```bash
flutter pub get
flutter run -d chrome
```

If `flutter analyze` or `pub get` surfaces any errors, paste them back to
me — the app logic is complete, it just hasn't had a real compiler pass.

## Project layout

```
lib/
  main.dart                    — app entry, theme, Provider setup
  theme/app_colors.dart        — color palette (ported from :root CSS vars)
  models/app_state.dart        — all form/generation state (ChangeNotifier)
  data/platform_specs.dart     — platform metadata + icon size tables
  services/
    image_service.dart         — resize / round / mask / bg-removal / ICO encode
    generate_controller.dart   — builds the ZIP per selected platform + README
    download_helper.dart       — triggers the browser download (dart:html)
  widgets/                     — every UI section (upload, platform grid,
                                  options, theme/colors, output tree, loader,
                                  toast, generate button, header, background)
  screens/
    home_screen.dart           — assembles the page layout
    grid_background.dart       — dotted grid + glow orbs
web/
  index.html, manifest.json    — Flutter Web scaffolding
```

## Notes / things to double check once it builds

- **Fonts**: the UI references `SpaceGrotesk` / `JetBrainsMono` font
  families for visual parity with the original Google Fonts, but no font
  assets are bundled. Without them Flutter falls back to the default
  platform font (harmless, just not pixel-identical). To match exactly,
  either add `google_fonts` and swap the `fontFamily` usages for
  `GoogleFonts.spaceGrotesk()` / `GoogleFonts.jetBrainsMono()`, or drop
  the `.ttf` files into `assets/fonts/` and declare them in
  `pubspec.yaml`.
- **PWA icons**: `web/manifest.json` references `web/icons/Icon-*.png`,
  which don't exist yet — cosmetic only (affects "Add to Home Screen"
  icon, not app function). Generate them with the app itself once it's
  running, or drop in placeholders.
- **Background removal / ICO encoding** are direct ports of the
  original's canvas-pixel logic — worth a quick visual sanity check
  against the original tool's output once both are runnable side by
  side.

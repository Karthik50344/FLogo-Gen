# Flutter Logo Generator — Developer Guide

This document explains how the app is put together: architecture,
state management, the image-processing pipeline, and how to extend
it (add a platform, change icon specs, etc.).

The app is a **Flutter Web** single-page app. There is no backend —
every operation (decode, resize, mask, ZIP, download) runs
client-side in the browser tab.

## Tech stack

| Concern | Package |
|---|---|
| State management | `provider` (a single `ChangeNotifier`) |
| Image decode/resize/compositing | `image` |
| ZIP packaging | `archive` |
| File picking (click-to-browse) | `file_picker` |
| Drag & drop | `desktop_drop` |
| Browser download trigger | `dart:html` (this app is web-only, so a direct `dart:html` dependency is fine — no conditional-import shim needed) |

## Project layout

```
lib/
  main.dart                     — app entry, MaterialApp + Provider setup
  theme/
    app_colors.dart             — color palette + shared gradients/radii
  models/
    app_state.dart              — single ChangeNotifier holding all UI/generation state
  data/
    platform_specs.dart         — platform metadata + icon size tables (source of truth for sizes)
    legal_content.dart          — Privacy Policy / Terms & Conditions copy
    user_guide_content.dart     — in-app User Guide copy (same content as docs/USER_GUIDE.md, restructured as sections)
    contact_info.dart           — kContactEmail — the address the footer's "Contact Us" mailto: link uses
  services/
    image_service.dart          — pure image-processing functions (resize/mask/bg-removal/ICO encode)
    generate_controller.dart    — orchestrates: decode → process → build ZIP per platform → download
    download_helper.dart        — dart:html Blob + <a download> trigger, plus openMailto() for Contact Us
  screens/
    home_screen.dart            — top-level layout, responsive breakpoints
    grid_background.dart        — dotted grid + glow-orb background painter
    legal_page.dart             — generic hero+TOC+accordion scaffold, reused by all three info pages below
    privacy_policy_screen.dart / terms_conditions_screen.dart / user_guide_screen.dart — thin content wrappers around legal_page.dart, each supplying their own title/badges/sections/footer note
  widgets/                      — one file per UI section (upload, platform grid,
                                   options, theme/colors, output tree, loader,
                                   toast, generate button, header, footer, ...)
```

## State management

All mutable UI/generation state lives in **one** `ChangeNotifier`:
`AppState` (`lib/models/app_state.dart`). It's provided at the root
in `main.dart` via `ChangeNotifierProvider` and consumed with
`context.watch<AppState>()` (rebuild on change) or
`context.read<AppState>()` (fire-and-forget calls, e.g. inside
`onTap`).

Key fields:

- `imageBytes`, `fileName`, `fileSize`, `mimeType` — the uploaded logo
- `platforms` — `Set<String>` of selected platform ids
- `removeBg`, `genNotif`, `genAdaptive` — option toggles
- `theme`, `lightBg`, `lightFg`, `darkBg`, `darkFg` — notification icon theme
- `isGenerating`, `loaderSteps`, `currentStepIndex`, `loaderText` — drives the loader overlay

There's no persistence layer — state resets on page reload by
design (the app explicitly avoids `localStorage`/`sessionStorage`
per its "nothing leaves your device, nothing is retained" privacy
stance; see `docs/USER_GUIDE.md`).

## The image pipeline (`image_service.dart`)

Everything here operates on `package:image`'s `Image` type (not
`dart:ui`'s `Image` — watch for the naming collision; this codebase
always imports it as `img.Image`).

- **`resizeImage(src, size, {bgColor, maskable, rounded})`** — the
  core primitive. Creates a `size × size` canvas, optionally filled
  with `bgColor`, and composites a resized copy of `src` onto it.
    - `maskable: true` shrinks the source to 80% and centers it (for
      Android/Web maskable icons, which need a safe-zone margin).
    - `rounded: true` applies a rounded-rect alpha mask afterward
      (`_applyRoundedMask`), used for `ic_launcher_round.png`.
- **`removeBackground(src)`** — samples the top-left, top-right, and
  bottom-left pixels, averages them as the presumed background
  color, then zeroes the alpha of any pixel within a fixed color
  distance (`threshold = 40`) of that average.
- **`generateNotificationIcon(src, size, bgColor, fgColor)`** —
  builds a flat single-color silhouette: any pixel with alpha > 10
  is recolored to `fgColor` (alpha preserved), then composited at
  80% scale, 10% inset, onto a `bgColor`-filled canvas.
- **`generateIco(src, sizes)`** — hand-rolled ICO container: an
  `ICONDIR` header, one `ICONDIRENTRY` per requested size, and the
  embedded PNG payloads back-to-back. No external ICO-writing
  dependency; if you ever need BMP-format ICO entries instead of
  PNG-in-ICO, this function needs to grow a second code path — every
  modern OS/browser reads PNG-in-ICO fine, so it wasn't necessary
  here.

All of the above are pure functions (no I/O), which makes them easy
to unit test in isolation from ZIP building / UI state.

## ZIP assembly (`generate_controller.dart`)

`GenerateController.generate(AppState state)` is the single entry
point the **Generate & Download ZIP** button calls. Flow:

1. Validate: an image is uploaded and at least one platform is
   selected.
2. Build the ordered list of loader step labels (used to drive the
   progress overlay) based on which platforms/options are active.
3. Decode the uploaded image, resize it to a 1024×1024 **working
   copy** (`baseImg`) — every per-platform/per-size asset is derived
   from this one working copy, not from the raw upload, so behavior
   is consistent regardless of the source image's original
   dimensions.
4. If background removal is on, apply it to `baseImg` once (not
   per-output-file) so every downstream asset is consistent.
5. For each selected platform, call the matching `_addX(archive,
   baseImg, ...)` method (`_addAndroid`, `_addIos`, `_addWeb`,
   `_addLinux`, `_addWindows`, `_addMacos`). Each one writes its
   files directly into a shared `Archive` via `_addFile`.
6. If notification icons are enabled, `_addNotificationIcons` writes
   the light/dark variants (and, if Android is selected, the
   per-density `drawable-*/ic_notification.png` set).
7. Add a generated `README.md` (`_generateReadme`) tailored to the
   exact platforms/options chosen.
8. Encode the archive with `ZipEncoder()`, convert to `Uint8List`,
   and hand off to `DownloadHelper.downloadBytes`.
9. Reset the loader and clear the uploaded image on success.

Progress reporting: `state.setStep(i)` is awaited between phases —
it updates `loaderText`/`currentStepIndex` and does a tiny
`Future.delayed` so the UI actually gets a chance to repaint between
CPU-heavy steps (Dart is single-threaded here; there's no isolate
work happening, so without a yield the browser tab would appear to
hang during generation).

## Data-driven size tables (`platform_specs.dart`)

All icon dimensions live in one place:

- `kPlatforms` — the 6 platform cards' metadata (id, emoji, label,
  description) shown in Step 2.
- `kAndroidMipmapSizes` — density folder → `[launcherSize,
  adaptiveForegroundSize]`.
- `kIosIconSizes` / `kMacIconSizes` — the required iOS/macOS icon
  dimensions.
- `kAndroidNotifDrawableSizes` — density folder → notification icon
  size.

**To change what gets generated for a platform, edit this file
first** — `generate_controller.dart`'s per-platform methods just
iterate these tables, so most size changes don't require touching
the ZIP-building logic at all.

## Layout notes (things that bit us during development)

A few Flutter-specific gotchas are baked into how this UI is built —
worth knowing before you touch layout code:

1. **Don't let a `Stack` child flip between positioned and
   non-positioned across rebuilds.** `LoaderOverlay` always returns
   `Positioned.fill(...)` and toggles visibility internally with
   `IgnorePointer` + `AnimatedOpacity`, rather than sometimes
   returning `Positioned.fill` and sometimes a bare `SizedBox`. The
   latter caused an intermittent "Cannot hit test a render box with
   no size" crash, especially around window resizes.
2. **`IntrinsicHeight` and `LayoutBuilder`/scrollable viewports don't
   mix.** `home_screen.dart` uses `IntrinsicHeight` +
   `CrossAxisAlignment.stretch` to make side-by-side cards share a
   height. Any widget nested inside that subtree that itself
   contains a `LayoutBuilder`, `GridView`, `ListView`, or
   `CustomScrollView` (even with `shrinkWrap: true`) will throw
   *"LayoutBuilder does not support returning intrinsic
   dimensions"* (or the equivalent Viewport assertion). That's why
   `PlatformGridCard` and `ThemeCard` build their grids manually
   with `Row` + `Expanded` (computed from column counts passed in
   from `home_screen`'s own `LayoutBuilder`, which sits *above* the
   `IntrinsicHeight`, not inside it) instead of `GridView` or an
   internal `LayoutBuilder`.
3. **Give every `AnimatedContainer`/`Container` an explicit
   `alignment` if its child is narrower than itself.** Without one,
   a shrink-wrapped child (e.g. a `Column` sized to its widest line
   of text) sits at the container's top-left instead of centering —
   easy to miss until the container gets wider than its content
   (e.g. after a responsive breakpoint change).
4. **`Wrap` is intrinsic-height-safe; `LayoutBuilder` and
   scrollables are not.** `Wrap` implements proper
   `computeMinIntrinsicHeight`/`computeMaxIntrinsicHeight`, so it's
   fine to use inside an `IntrinsicHeight` subtree (see the chip row
   in `upload_card.dart`). `LayoutBuilder` and any `Viewport`-backed
   widget explicitly refuse intrinsic-dimension queries.

## In-app info pages (Privacy Policy, Terms & Conditions, User Guide)

All three share one scaffold: `screens/legal_page.dart`'s `LegalPage`
widget (hero icon/title/subtitle, a `Wrap` of badge pills, a tappable
table of contents that scrolls to and expands the matching section,
and accordion-style section cards). It's deliberately generic —
`badges`, `footerIcon`/`footerIconColor`, and `footerNote` are all
constructor parameters rather than hardcoded, specifically so the
User Guide (not a legal document) could reuse it without inheriting
"Effective date" / "No data collected" badges that wouldn't make
sense there.

Each of the three screens is a thin wrapper: it just supplies its own
title, hero icon, subtitle, `PageBadge` list, `LegalSection` list
(content lives in `data/legal_content.dart` and
`data/user_guide_content.dart`), and footer note text.

**To add a fourth info page** (say, a Changelog): add a
`kChangelogSections` list to a new `data/changelog_content.dart`,
then a `ChangelogScreen` following the exact shape of
`user_guide_screen.dart`, and add a `_FooterLink` entry for it in
`widgets/app_footer.dart`.

### Guides & Articles (long-form content)

`data/article_model.dart` defines the `Article`/`ArticleSection`
shape; `data/articles_content.dart` holds the actual 12 articles
(exported alongside the model via `export 'article_model.dart';`, so
anything importing `articles_content.dart` gets both). Two screens
render them:

- `screens/guides_list_screen.dart` — the `/guides` index, listing
  every article as a card.
- `screens/article_screen.dart` — renders one `Article`'s full
  content (heading + paragraphs per section).

Article routes are **not** hardcoded one-by-one in `main.dart`'s
`routes` map — `onGenerateRoute` matches any `/guides/<slug>` path,
looks the slug up in `kArticles`, and builds an `ArticleScreen` for
it (falling back to Home for an unknown slug). `_TitleRouteObserver`
does the same slug lookup to set the browser tab title. **To add a
13th article, you only need to add one `Article` entry to
`kArticles`** — routing, titles, and the guides index all pick it up
automatically. You do still need to add its URL to
`web/sitemap.xml` by hand, since that file is static.

### Homepage content sections

Four widgets add real prose/content to the landing page, inserted
between the Generate button and the footer in `home_screen.dart`
(width-capped to 1000px for readability, unlike the full-width
generator UI above them):

- `widgets/how_it_works_section.dart` — the 4-step process, in prose.
- `widgets/why_use_section.dart` — a benefits/value-proposition
  section.
- `widgets/guides_teaser_section.dart` — the first 3 articles from
  `kArticles`, linking to `/guides`.
- `widgets/faq_section.dart` — an accordion over `data/faq_content.dart`'s
  `kFaqs` list.

This content was added specifically to satisfy ad-network content
requirements (e.g. AdSense expects a site to have substantive,
original text content beyond just a tool UI) — if you trim any of
it, keep that requirement in mind.

### Contact Us (footer)

`widgets/app_footer.dart`'s `_ContactBlock` shows "Contact Us" and
the address from `data/contact_info.dart`'s `kContactEmail`
constant, and opens the user's mail client via
`DownloadHelper.openMailto()` (in `services/download_helper.dart`) —
a plain `mailto:` link, built and clicked the same off-DOM-anchor way
`downloadBytes()` triggers the ZIP download. **`kContactEmail` ships
with a placeholder value (`your-email@example.com`) — replace it
with a real address before shipping.**

## SEO

Two independent things had to change for this to be even remotely
SEO-friendly — metadata alone doesn't help if the pages it describes
aren't reachable by URL:

### 1. Real, path-based routes

`main.dart` now calls `usePathUrlStrategy()` (from
`flutter_web_plugins`, ships with the SDK — no `pub.dev` fetch
needed) before `runApp`, and `MaterialApp` uses a `routes:` map
(`/`, `/privacy-policy`, `/terms`, `/user-guide`) instead of
`home:`. Without `usePathUrlStrategy()`, Flutter Web defaults to
hash-based URLs (`/#/privacy-policy`), which search engines
effectively don't index as distinct pages. `widgets/app_footer.dart`
navigates with `Navigator.pushNamed('/user-guide')` etc. instead of
`Navigator.push(MaterialPageRoute(...))`, specifically so the
browser's address bar actually updates.

**If you add a new page, update all four of these together:**
`main.dart`'s `routes` map, `kRouteTitles` (same file),
`widgets/app_footer.dart`'s links, and `web/sitemap.xml`.

### 2. Per-route browser tab titles

`main.dart`'s `_TitleRouteObserver` (a `NavigatorObserver`) sets
`document.title` on every push/pop/replace, keyed off
`kRouteTitles`. This is deliberately centralized rather than done in
each screen's `initState` — a screen's `State` object isn't
recreated on `Navigator.pop()`, so a per-screen approach fails to
reset the title when the user hits "back."

### 3. `<head>` metadata (`web/index.html`)

Description, keywords, canonical URL, Open Graph tags (for
Facebook/LinkedIn/Discord/Slack link previews), a Twitter Card, a
`SoftwareApplication` JSON-LD block, and a `<noscript>` fallback for
crawlers/scrapers that don't execute JavaScript. **The domain used
throughout (`flogo-gen.web.app`) is a placeholder based on the
screenshots shared during development — find-and-replace it with
your real production domain** in `index.html`, `robots.txt`, and
`sitemap.xml` if it differs.

### 4. Hosting rewrite rule — required, not optional

Path-based routing only works if your host serves `index.html` for
*every* path (Flutter's router then reads the URL client-side and
picks the right route). Without this, a fresh visit to
`/privacy-policy` (a shared link, a bookmark, a search-result click)
404s at the server before Flutter ever loads.

- **Firebase Hosting** (your screenshots showed `flogo-gen.web.app`,
  which is a Firebase Hosting domain): `firebase.json` at the repo
  root already has the required `rewrites: [{ "source": "**",
  "destination": "/index.html" }]` rule. Deploy with `firebase
  deploy` after `flutter build web`.
- **Netlify**: add a `_redirects` file to `web/` (copied into
  `build/web/` on build) containing `/*  /index.html  200`.
- **Vercel**: add a `vercel.json` with a catch-all rewrite to
  `/index.html`.
- **Nginx**: `try_files $uri $uri/ /index.html;` in the relevant
  `location /` block.
- **Apache**: an `.htaccess` with `FallbackResource /index.html` (or
  equivalent `mod_rewrite` rules).

If you're not sure which of these applies, check `robots.txt`/visit
`/privacy-policy` directly (not via an in-app link) after deploying
— a 404 there means the rewrite rule is missing or misconfigured.

### 5. Renderer choice — the one item above doesn't fix on its own

Everything above (routing, `<head>` metadata, the rewrite rule)
makes pages *discoverable and linkable*. It does not by itself make
their *body content* crawlable, and this is the part most guides
skip:

- **CanvasKit** (Flutter Web's current default) paints the entire UI
  — including all text — onto a `<canvas>`/WebGL surface. Even when
  a crawler executes the JavaScript, there are no real DOM text
  nodes to extract; the rendered pixels live in the GPU's
  framebuffer, not the DOM. Googlebot's HTML extractor reads DOM
  nodes, so CanvasKit output is effectively invisible to
  text-based indexing regardless of how good your meta tags are.
- **The HTML renderer** paints text and basic widgets as real DOM
  elements (with CSS/Canvas 2D/SVG for the rest), so crawlers can
  read actual text nodes — meaningfully better for SEO and
  accessibility, at some cost to visual/animation fidelity and a
  different performance profile than CanvasKit.

**If ranking on the actual page content (not just the title/
description shown in search results) matters, switch the renderer
for this app.** How you do that has changed across Flutter
versions, so check what your installed SDK supports:

- Try `flutter build web --web-renderer html` first — the flag has
  existed for a long time and may still work on your version.
- If it doesn't, configure it in the generated bootstrap instead:
  Flutter Web's `index.html` loads via `flutter_bootstrap.js`, which
  calls `_flutter.loader.load(...)`. You can pass
  `config: { renderer: 'html' }` there (see "Customizing web app
  initialization" in the official Flutter docs for the exact current
  syntax, since this file is regenerated by `flutter build web` and
  isn't something to hand-edit permanently).

Even with the HTML renderer, Flutter's widget tree doesn't
automatically produce semantic HTML (headings, landmarks, etc.) —
it's still `<div>`-heavy unless you deliberately use `Semantics`
widgets. The HTML renderer's real win here is simply that your
copy becomes actual, indexable text instead of pixels; it's not a
substitute for semantic markup if this app ever needs deeper
on-page SEO than "the page is indexed at all."

## Adding a new output platform

1. Add its metadata to `kPlatforms` in `platform_specs.dart` (id,
   emoji, label, description) — this automatically adds it to the
   Step 2 grid.
2. Add a size table if it needs one (follow the pattern of
   `kIosIconSizes`/`kMacIconSizes`).
3. Add a `_addYourPlatform(Archive archive, img.Image baseImg)`
   method in `generate_controller.dart`, following the shape of the
   existing `_addX` methods, and call it from the `switch` in
   `generate()`.
4. If the new platform needs a config file (like iOS/macOS's
   `Contents.json`), build the string/JSON directly in that method
   and add it via `archive.addFile(ArchiveFile.string(path,
   content))`.
5. Update `_generateReadme` with usage instructions for the new
   platform, and add a matching branch to
   `output_tree_card.dart`'s `_buildTreeLines` so the live preview
   reflects it.

## Running the project

```bash
flutter pub get
flutter run -d chrome
```

This project was authored offline (no `pub.dev` access at write
time), so if `pub get`/`flutter analyze` turns up anything, it
hasn't had a real compiler pass yet — fix forward from whatever it
reports.

## Known gaps / things to double-check

- **Contact email**: `data/contact_info.dart`'s `kContactEmail` is
  still the placeholder `your-email@example.com` — replace it before
  shipping, or the footer's Contact Us link will mail nowhere.
- **Fonts**: the UI references `SpaceGrotesk`/`JetBrainsMono` font
  families but no font assets are bundled — falls back to the
  platform default font. Add `google_fonts` or bundle `.ttf` files
  under `assets/fonts/` if pixel-exact typography matters.
- **PWA icons**: `web/manifest.json` references
  `web/icons/Icon-*.png`, which aren't included in the repo —
  generate them with the app itself (Web platform, then copy the
  output into `web/icons/`) or drop in placeholders.
- **Legal page content**: `data/legal_content.dart` has real copy
  for the Privacy Policy's "Overview" section; the remaining
  sections in both documents are placeholder text in the same voice
  — replace with your actual policy/terms if they differ.
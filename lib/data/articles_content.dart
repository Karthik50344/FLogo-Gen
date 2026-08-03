import 'article_model.dart';
export 'article_model.dart';

const List<Article> kArticles = [
  Article(
    slug: 'flutter-app-icon-sizes-guide',
    title: 'Flutter App Icon Sizes: The Complete Guide for Every Platform',
    excerpt:
        'Every size Flutter expects for Android, iOS, Web, Windows, macOS, '
        'and Linux — and why there are so many of them.',
    readTime: '7 min read',
    sections: [
      ArticleSection(paragraphs: [
        'One of the more surprising things about shipping a Flutter app is '
            'discovering just how many different icon files a single logo '
            'turns into. A developer coming from web design, where a '
            'favicon might be the only icon a project needs, can be caught '
            'off guard by the dozens of PNGs, an ICO file, and several '
            'JSON manifests that a "finished" app icon actually requires. '
            'This guide walks through every size Flutter needs, platform '
            'by platform, and explains why the count is so high.',
      ]),
      ArticleSection(heading: 'Android: five densities, two shapes', paragraphs: [
        'Android ships five standard pixel densities — mdpi, hdpi, xhdpi, '
            'xxhdpi, and xxxhdpi — and expects a differently sized launcher '
            'icon in each one, from 48×48 up to 192×192 pixels. On top of '
            'that, most modern launchers render a "round" variant of the '
            'icon for devices or themes that mask icons into a circle, so '
            'each density folder also gets an ic_launcher_round.png. '
            'Add a single 512×512 icon for the Play Store listing itself, '
            'and a basic Android icon set is already ten-plus files before '
            'adaptive icons even enter the picture.',
        'Since Android 8.0 (API 26), launchers can additionally mask and '
            'animate icons into whatever shape a given device theme uses — '
            'squircle, teardrop, circle, or something else entirely. That '
            'requires splitting the icon into a foreground layer and a '
            'background layer, each generated at a larger canvas size than '
            'the flat launcher icon so the system has room to crop and '
            'animate without clipping important content.',
      ]),
      ArticleSection(heading: 'iOS: one iconset, fifteen sizes', paragraphs: [
        'iOS consolidates everything into a single AppIcon.appiconset '
            'folder, but that folder still needs a size for every context '
            'the icon might appear in: the home screen at 1x/2x/3x scale '
            'factors, Settings, Spotlight search, notifications, and the '
            'App Store listing itself (a 1024×1024 marketing icon). Each '
            'of those contexts has its own required pixel dimensions, and '
            'a Contents.json file ties the filenames to their intended '
            'usage so Xcode knows which file goes where.',
      ]),
      ArticleSection(heading: 'Web, Windows, macOS, and Linux', paragraphs: [
        'A Flutter web build needs a favicon, a couple of standard PWA '
            'icon sizes for the home-screen/install prompt, and — if the '
            'app supports being "installed" as a PWA — maskable variants '
            'with extra padding so operating systems can safely crop them '
            'into a circle or squircle without cutting off the logo.',
        'Windows desktop apps use a single multi-resolution .ico file '
            '(which is really several PNG or BMP images bundled together '
            'behind one filename) plus a plain PNG for use inside the app '
            'itself. macOS follows the same iconset pattern as iOS, just '
            'with its own required sizes — 16 up to 1024 pixels — and its '
            'own Contents.json. Linux desktop icons are the simplest of '
            'the six, following the standard GTK icon sizes used across '
            'most Linux desktop environments.',
      ]),
      ArticleSection(heading: 'Why this adds up to so many files', paragraphs: [
        'Multiply five Android densities, fifteen iOS sizes, several web '
            'variants, a Windows ICO, a macOS iconset, and Linux sizes '
            'together, and a full six-platform icon set can easily reach '
            '40-50 individual files — every one of them needing the exact '
            'right pixel dimensions and the exact right filename, because '
            'each platform\'s build tooling looks for those files by name, '
            'not by inspecting the image itself. Getting even one '
            'dimension or filename wrong typically means the platform '
            'either falls back to a default icon or rejects the build '
            'outright — which is exactly the tedious, error-prone part '
            'that an automated generator exists to remove.',
      ]),
    ],
  ),
  Article(
    slug: 'android-adaptive-icons-explained',
    title: 'Android Adaptive Icons Explained: Foreground, Background, and Safe Zones',
    excerpt:
        'What adaptive icons actually are, why Android needs two layers '
        'instead of one image, and how to design a foreground that '
        'survives being cropped into a circle.',
    readTime: '6 min read',
    sections: [
      ArticleSection(paragraphs: [
        'Before Android 8.0 (Oreo), an app icon was just one flat image. '
            'Every device showed it the same way, in whatever shape the '
            'manufacturer\'s launcher used — usually a rounded square. '
            'Adaptive icons changed that by letting the system itself '
            'decide the final shape, which means the icon can no longer '
            'be a single flat image; it has to be built from separable '
            'pieces the system can mask and animate independently.',
      ]),
      ArticleSection(heading: 'Two layers, one icon', paragraphs: [
        'An adaptive icon is made of a background layer and a foreground '
            'layer, each its own full-size image, stacked on top of each '
            'other. The system applies a mask shape — circle, squircle, '
            'rounded square, or a manufacturer-specific shape — to both '
            'layers together, and can also apply subtle parallax or '
            'pulsing animations to the foreground independently of the '
            'background when the user interacts with the icon.',
        'This is also what allows Android to render a consistent visual '
            'style across every app on a device, even when each app\'s '
            'icon was designed by a different team — the system, not the '
            'app, ultimately decides the outer shape.',
      ]),
      ArticleSection(heading: 'Why the foreground needs a safe zone', paragraphs: [
        'Because the mask can crop fairly aggressively — a circular mask '
            'removes the corners of a square image, for instance — the '
            'foreground layer is drawn on a canvas noticeably larger than '
            'the final visible icon, with the actual logo confined to a '
            'smaller "safe zone" in the center. Google\'s own guidance '
            'puts the visible-content area at roughly two-thirds of the '
            'total canvas, leaving generous margin on every side so that '
            'no mask shape can clip essential parts of the logo.',
        'Designers moving from flat icons to adaptive icons for the '
            'first time often make the mistake of drawing their logo edge '
            'to edge, the way they would for a normal square icon. On an '
            'adaptive icon, that all but guarantees clipping on circular '
            'or squircle masks — the fix is simply scaling the artwork '
            'down and centering it well inside the safe zone before '
            'exporting the foreground layer.',
      ]),
      ArticleSection(heading: 'Choosing a background', paragraphs: [
        'The background layer is usually a flat, solid color, though it '
            'can be a subtle pattern or gradient. Because it sits behind '
            'the foreground and gets masked the same way, it should be '
            'simple enough that it doesn\'t distract from the actual '
            'logo, and its color should complement the foreground rather '
            'than competing with it.',
      ]),
    ],
  ),
  Article(
    slug: 'ios-app-icon-requirements',
    title: 'iOS App Icon Requirements: Every Size You Need',
    excerpt:
        'From the 20×20 Settings icon to the 1024×1024 App Store artwork '
        '— what each iOS icon size is for and how Contents.json ties '
        'them together.',
    readTime: '5 min read',
    sections: [
      ArticleSection(paragraphs: [
        'iOS icons look deceptively simple from the outside — one icon, '
            'one shape, rounded corners the system applies automatically. '
            'Underneath, an AppIcon.appiconset actually bundles well over '
            'a dozen differently sized images, because the same icon has '
            'to look sharp in several very different contexts.',
      ]),
      ArticleSection(heading: 'Home screen, Settings, and Spotlight', paragraphs: [
        'The icon a user taps to launch the app is only one of the '
            'places it appears. iOS also shows a smaller version in '
            'Settings, an even smaller one in Spotlight search results, '
            'and a notification-badge-sized version in the notification '
            'center — each at its own precise pixel dimensions, and each '
            'multiplied by the 1x, 2x, and 3x scale factors needed to '
            'stay sharp across every physical screen density Apple has '
            'shipped.',
      ]),
      ArticleSection(heading: 'The App Store icon is its own asset', paragraphs: [
        'Separately from every size the icon appears at on the device '
            'itself, Apple requires a single 1024×1024 "marketing" icon '
            'purely for the App Store listing. It has to be provided '
            'without transparency and without rounded corners pre-baked '
            'in — Apple\'s own store front applies the corner mask, so an '
            'icon with corners already rounded ends up with a visible '
            'double-rounding artifact.',
      ]),
      ArticleSection(heading: 'Contents.json ties it all together', paragraphs: [
        'Rather than inferring an image\'s purpose from its dimensions, '
            'Xcode reads a Contents.json manifest inside the '
            '.appiconset folder that explicitly maps each filename to an '
            'idiom (iphone, ipad, ios-marketing) and scale (1x, 2x, 3x). '
            'This is why simply dropping correctly-sized PNGs into the '
            'folder isn\'t enough on its own — the manifest has to '
            'reference them by the exact filenames it expects, which is '
            'the detail most manual icon-replacement mistakes trip over.',
      ]),
    ],
  ),
  Article(
    slug: 'designing-a-logo-that-scales',
    title: 'How to Design a Logo That Works at Every Size',
    excerpt:
        'The design choices that hold up from a 1024×1024 App Store '
        'listing down to a 16×16 favicon — and the ones that fall apart.',
    readTime: '6 min read',
    sections: [
      ArticleSection(paragraphs: [
        'An app icon has an unusually wide size range to survive. The '
            'same source artwork has to read clearly at 1024×1024 on an '
            'App Store listing and still be recognizable at 16×16 in a '
            'browser tab. Very few design choices work equally well at '
            'both extremes, so designing "for the icon" rather than '
            'shrinking an existing logo tends to produce far better '
            'results.',
      ]),
      ArticleSection(heading: 'Simplify before you scale down', paragraphs: [
        'Fine detail, thin strokes, and small text are the first things '
            'to disappear at small sizes — a hairline stroke that looks '
            'crisp at 512×512 can vanish into a single blurred pixel row '
            'at 24×24. The most durable icons tend to reduce their '
            'concept to a single bold shape or silhouette rather than a '
            'detailed illustration, precisely because a simple shape '
            'keeps its silhouette recognizable no matter how small it '
            'gets rendered.',
      ]),
      ArticleSection(heading: 'Contrast matters more than color', paragraphs: [
        'At very small sizes, subtle color differences blend together '
            'before a viewer\'s eye can register them, but a strong '
            'light/dark contrast stays legible far longer. Testing an '
            'icon in grayscale is a quick way to check whether it\'s '
            'relying on contrast (which survives shrinking) or purely on '
            'color separation (which doesn\'t).',
      ]),
      ArticleSection(heading: 'Leave margin — platforms will crop', paragraphs: [
        'Android\'s adaptive icons, iOS and macOS\'s rounded corners, and '
            'web app maskable icons all crop into their final shape from '
            'a square (or larger) source canvas. A logo drawn all the way '
            'to the edges of its canvas will get clipped the moment any '
            'of those masks are applied. Designing with generous, even '
            'margin on all sides — even if it looks slightly small in an '
            'un-cropped preview — is what keeps the logo intact once '
            'every platform\'s mask has been applied.',
      ]),
      ArticleSection(heading: 'Start big, not small', paragraphs: [
        'Because every downstream size is a downscale, not an upscale, '
            'starting from the highest-resolution version of the artwork '
            'you can produce (1024×1024 or larger, and vector if '
            'possible) gives every generated size the most detail to work '
            'with. Starting from a small or low-resolution source image '
            'and scaling it up only amplifies existing softness or '
            'compression artifacts at every larger size generated from '
            'it.',
      ]),
    ],
  ),
  Article(
    slug: 'pwa-maskable-icons-explained',
    title: 'PWA Icons and Maskable Icons: What Web Developers Need to Know',
    excerpt:
        'Why a Progressive Web App needs more than a favicon, and what '
        '"maskable" actually means in a web app manifest.',
    readTime: '5 min read',
    sections: [
      ArticleSection(paragraphs: [
        'A Flutter web build that only ships a favicon is leaving a '
            'noticeable gap: the moment a user tries to "install" the app '
            'to their home screen or app drawer as a Progressive Web App, '
            'the operating system needs a set of properly sized icons '
            'described in the web app manifest — and increasingly, it '
            'needs a maskable variant of those icons too.',
      ]),
      ArticleSection(heading: 'Standard icons vs. maskable icons', paragraphs: [
        'A standard PWA icon is just a PNG at a couple of common sizes '
            '(192×192 and 512×512 cover most cases) referenced in '
            'manifest.json. A maskable icon is the same idea, but drawn '
            'with extra padding around the actual logo, because the '
            'operating system reserves the right to crop a maskable icon '
            'into whatever shape its home screen uses — circle, squircle, '
            'rounded square — the same way Android\'s adaptive icons '
            'work.',
        'Without the extra padding, a maskable icon\'s logo can end up '
            'clipped at the edges the moment the OS applies its mask — '
            'exactly the same failure mode as an Android adaptive icon '
            'drawn without a safe zone.',
      ]),
      ArticleSection(heading: 'Why both variants are worth shipping', paragraphs: [
        'Not every platform respects the maskable purpose flag the same '
            'way, and some browsers fall back to the standard icon if no '
            'maskable one is present (or vice versa). Shipping both — a '
            'plain icon for platforms that display it as-is, and a '
            'padded maskable version for platforms that crop it — covers '
            'both cases without relying on any one browser\'s specific '
            'behavior.',
      ]),
    ],
  ),
  Article(
    slug: 'windows-ico-files-explained',
    title: 'Windows ICO Files Explained: What\'s Inside a .ico and Why It Matters',
    excerpt:
        'A .ico file isn\'t one image — it\'s a small container holding '
        'several. Here\'s what\'s actually inside one and why Windows '
        'wants it that way.',
    readTime: '5 min read',
    sections: [
      ArticleSection(paragraphs: [
        'Unlike a PNG or JPG, a Windows .ico file isn\'t a single image '
            'at all — it\'s a small container format that bundles several '
            'images of different sizes together behind one filename. '
            'That\'s an intentional design, and understanding why '
            'explains a lot about how Windows displays app icons in the '
            'first place.',
      ]),
      ArticleSection(heading: 'Why one file needs to hold several images', paragraphs: [
        'Windows shows an app\'s icon in a lot of different places — the '
            'taskbar, the desktop, File Explorer\'s various view modes, '
            'the Alt-Tab switcher, jump lists — and each of those '
            'contexts renders the icon at a different pixel size. Rather '
            'than making Windows scale one image up and down for every '
            'context (which tends to look soft at small sizes and blocky '
            'at large ones), an .ico file embeds separate, purpose-built '
            'images for the common sizes — typically 16×16, 32×32, 48×48, '
            'and 256×256 — and Windows simply picks whichever embedded '
            'size best matches the context it needs.',
      ]),
      ArticleSection(heading: 'What\'s actually inside the file', paragraphs: [
        'Structurally, an ICO file starts with a short header describing '
            'how many images it contains, followed by one directory '
            'entry per image recording that image\'s width, height, and '
            'where its actual pixel data sits later in the file. The '
            'embedded images themselves are typically stored as ordinary '
            'PNG data (modern Windows versions read PNG-in-ICO natively), '
            'so in effect an ICO file is a lightweight index sitting in '
            'front of a handful of regular PNGs.',
      ]),
      ArticleSection(heading: 'Why this trips people up', paragraphs: [
        'Because an ICO looks like "one icon" from the outside, it\'s '
            'easy to assume any single image can just be renamed with a '
            '.ico extension and it\'ll work everywhere. In practice, an '
            'ICO built from only one embedded size will look fine in the '
            'one context that matches that size and noticeably blurry '
            'or blocky everywhere else — which is exactly why a proper '
            'app-icon ICO bundles several sizes rather than one.',
      ]),
    ],
  ),
  Article(
    slug: 'macos-app-icon-guidelines',
    title: 'macOS App Icon Guidelines: Rounded Squares and the Human Interface Guidelines',
    excerpt:
        'macOS icons follow a distinct visual language from iOS — here\'s '
        'what Apple\'s guidelines actually ask for.',
    readTime: '5 min read',
    sections: [
      ArticleSection(paragraphs: [
        'It\'s tempting to assume a macOS app icon is just a bigger '
            'version of the same app\'s iOS icon, but Apple\'s Human '
            'Interface Guidelines treat the two as distinct visual '
            'languages, and macOS icons that are simply resized iOS '
            'icons tend to look noticeably out of place next to Apple\'s '
            'own system apps.',
      ]),
      ArticleSection(heading: 'A rounded square, not a full square', paragraphs: [
        'Where iOS renders an icon nearly edge-to-edge inside its rounded '
            'corners, macOS icons traditionally sit within a rounded-square '
            'shape that itself occupies only part of the full canvas, '
            'with visible padding around it — closer to the visual '
            'weight of a real-world app icon sitting on a desk than a '
            'screen filled corner to corner. Icons designed without that '
            'padding tend to look oversized and heavy in the Dock '
            'compared to icons designed with it in mind from the start.',
      ]),
      ArticleSection(heading: 'Depth and consistent lighting', paragraphs: [
        'Apple\'s macOS icon guidance has historically encouraged a '
            'subtle sense of depth and dimensionality — soft shadows, '
            'gentle highlights, a consistent implied light source — '
            'rather than the flatter, more graphic style common in '
            'mobile and web iconography. This has shifted over successive '
            'macOS design refreshes, so it\'s worth checking Apple\'s '
            'current Human Interface Guidelines for the specific visual '
            'style in effect at the time you\'re designing, rather than '
            'assuming an older screenshot or reference icon is still '
            'current.',
      ]),
      ArticleSection(heading: 'One iconset, many sizes', paragraphs: [
        'Structurally, macOS follows the same iconset-plus-Contents.json '
            'pattern as iOS, just with its own required sizes — from '
            '16×16 up through 1024×1024 — to cover everything from a '
            'small file-list icon to the Dock and Launchpad.',
      ]),
    ],
  ),
  Article(
    slug: 'android-notification-icons-monochrome',
    title: 'Why Android Notification Icons Must Be Monochrome',
    excerpt:
        'A full-color logo in the status bar renders as a solid white '
        'block — here\'s the design rule Android enforces and why.',
    readTime: '4 min read',
    sections: [
      ArticleSection(paragraphs: [
        'A common first-time surprise when shipping notifications on '
            'Android is discovering that a perfectly good, full-color '
            'app logo shows up in the status bar as a flat white square '
            'or circle with no detail at all. This isn\'t a bug — it\'s '
            'Android deliberately ignoring every color in the supplied '
            'image.',
      ]),
      ArticleSection(heading: 'The system colors the icon, not you', paragraphs: [
        'Since Android 5.0, the platform has required status-bar and '
            'notification icons to be monochrome: a transparent '
            'background with a single-color silhouette, using only the '
            'alpha channel to define the shape. Android then tints that '
            'silhouette itself, based on the current system theme, '
            'accent color, or notification channel — which is exactly '
            'why supplying full color has no effect; every non-transparent '
            'pixel gets treated as "opaque" and recolored regardless of '
            'what color it originally was.',
      ]),
      ArticleSection(heading: 'Why Android enforces this', paragraphs: [
        'The rule exists mostly for visual consistency: a status bar '
            'full of differently colored, full-detail app icons reads as '
            'visually noisy at the tiny size notification icons render '
            'at, whereas a row of simple, theme-tinted silhouettes reads '
            'clearly regardless of how many apps have posted '
            'notifications at once.',
      ]),
      ArticleSection(heading: 'Building one from a full-color logo', paragraphs: [
        'The practical fix is generating a dedicated silhouette version '
            'of the logo — every visible pixel recolored to a single '
            'flat color, background fully transparent — separately from '
            'the full-color launcher icon used everywhere else. Doing '
            'this by hand for every density folder Android expects is '
            'tedious, which is exactly the kind of repetitive, '
            'well-defined transformation an automated tool handles in a '
            'single pass.',
      ]),
    ],
  ),
  Article(
    slug: 'background-removal-for-logos',
    title: 'Background Removal for Logos: How It Works and When to Use It',
    excerpt:
        'A practical look at how automated background removal actually '
        'identifies "background," and the kinds of source images it '
        'handles well versus poorly.',
    readTime: '5 min read',
    sections: [
      ArticleSection(paragraphs: [
        'Automated background removal for a logo sounds like it should '
            'require sophisticated image recognition, but for the kind '
            'of clean, flat artwork most logos are made of, a much '
            'simpler technique — color-distance sampling — does the job '
            'reliably, and understanding how it works makes it much '
            'easier to predict when it will and won\'t give a clean '
            'result.',
      ]),
      ArticleSection(heading: 'Sampling corners, not detecting objects', paragraphs: [
        'Rather than trying to recognize "the logo" as a distinct '
            'object, this style of background removal samples the pixels '
            'in the image\'s corners — on the assumption that a logo sits '
            'somewhere near the center of its canvas and the corners are '
            'background — and averages them into a single presumed '
            'background color. Every pixel in the image is then compared '
            'against that average; pixels close enough in color are '
            'made transparent, and pixels far enough away (the actual '
            'logo artwork) are left untouched.',
      ]),
      ArticleSection(heading: 'Where this works well', paragraphs: [
        'This approach works cleanly on exactly the kind of source image '
            'most logos start as: a flat, single, solid-colored '
            'background (white is the most common case) behind '
            'high-contrast artwork. Because the whole background is one '
            'uniform color, the corner samples are representative of the '
            'entire background, and the color-distance threshold cleanly '
            'separates "background" from "logo" everywhere in the image, '
            'not just near the corners.',
      ]),
      ArticleSection(heading: 'Where it struggles', paragraphs: [
        'Photographic backgrounds, gradients, and soft drop-shadows '
            'baked into the source image all break the core assumption '
            'that the background is one uniform color — a gradient '
            'background, for instance, means the corner samples don\'t '
            'represent the background color everywhere else in the '
            'image, which can leave visible un-removed patches or, at '
            'the opposite extreme, accidentally erase part of the logo '
            'itself if its colors happen to fall close to the sampled '
            'average. Anti-aliased edges — where the logo blends into '
            'the background over a few semi-transparent pixels — can '
            'also leave a faint halo, since those edge pixels sit right '
            'at the color-distance threshold and may or may not get '
            'cleared depending on exactly how close they land to it.',
      ]),
      ArticleSection(heading: 'The practical takeaway', paragraphs: [
        'For the cleanest automated result, start from a logo already '
            'sitting on a flat, solid, uniformly colored background — '
            'ideally pure white — rather than relying on background '
            'removal to salvage a busier source image. If a logo\'s only '
            'available version has a photographic or gradient '
            'background, cleaning it up in an image editor first will '
            'almost always give a better result than any automated '
            'corner-sampling approach alone.',
      ]),
    ],
  ),
  Article(
    slug: 'flutter-launcher-icons-manual-vs-automated',
    title: 'Flutter Launcher Icons: Manual Setup vs. Automated Generators',
    excerpt:
        'What it actually takes to add app icons to a Flutter project by '
        'hand, and where an automated generator saves real time.',
    readTime: '6 min read',
    sections: [
      ArticleSection(paragraphs: [
        'Setting a Flutter app\'s icon manually is entirely possible — '
            'every platform\'s requirements are publicly documented — but '
            'walking through what "by hand" actually involves makes it '
            'clear why most teams reach for an automated tool the moment '
            'they need to support more than one platform.',
      ]),
      ArticleSection(heading: 'What manual setup actually involves', paragraphs: [
        'Doing it by hand means, at minimum: exporting your logo at '
            'every required pixel size for every platform you support; '
            'naming each exported file exactly as that platform\'s build '
            'tooling expects; placing each file in the correct nested '
            'folder inside android/, ios/, web/, windows/, macos/, or '
            'linux/; and, for iOS and macOS specifically, hand-editing '
            'a Contents.json manifest so Xcode knows which file maps to '
            'which idiom and scale. For Android, it also means separately '
            'producing a monochrome silhouette for notification icons '
            'and, if you want adaptive icons, a foreground/background '
            'layer pair with the artwork correctly scaled into a safe '
            'zone.',
        'None of these steps are individually hard, but there are '
            'roughly 40-50 individual files across a full six-platform '
            'set, and a single wrong dimension or misspelled filename '
            'typically fails silently — the platform falls back to a '
            'default icon rather than throwing a build error, which '
            'makes mistakes easy to miss until you actually run the app.',
      ]),
      ArticleSection(heading: 'What changes when your logo changes', paragraphs: [
        'The real cost of the manual approach shows up on the second '
            'pass, not the first — the moment a logo gets redesigned or '
            'a color changes, every one of those 40-50 files needs to be '
            're-exported and re-placed by hand, again, correctly. A '
            'generator that produces the whole set from one source image '
            'in a single run turns that repeat cost back down to '
            'whatever it costs to run the tool again.',
      ]),
      ArticleSection(heading: 'When manual editing still makes sense', paragraphs: [
        'None of this means automation is always the right call — a '
            'team that needs a genuinely different (not just resized) '
            'icon per platform, with platform-specific art direction '
            'baked in by hand, is doing something a generic size-and-'
            'format generator was never meant to replace. Automated '
            'generation is squarely aimed at the far more common case: '
            'one logo, resized and formatted correctly everywhere it '
            'needs to go.',
      ]),
    ],
  ),
  Article(
    slug: 'history-of-the-app-icon',
    title: 'A Brief History of the App Icon: From Skeuomorphism to Flat Design',
    excerpt:
        'How app icons went from photorealistic leather and glass to flat '
        'shapes and back toward subtle depth again.',
    readTime: '6 min read',
    sections: [
      ArticleSection(paragraphs: [
        'App icons have gone through a few distinct visual eras since '
            'smartphones put a grid of them on every home screen, and '
            'each era says something about the design priorities and '
            'screen technology of its time.',
      ]),
      ArticleSection(heading: 'Skeuomorphism: icons that imitated real objects', paragraphs: [
        'Early smartphone icons leaned heavily on skeuomorphism — '
            'designing digital objects to closely resemble their '
            'physical counterparts, complete with stitched leather '
            'textures, glossy glass reflections, and realistic drop '
            'shadows. A notes app icon looked like a paper notepad; a '
            'calculator icon looked like a physical calculator. This '
            'style made an unfamiliar interaction model — tapping a '
            'glass rectangle — feel more approachable by grounding it in '
            'familiar physical objects.',
      ]),
      ArticleSection(heading: 'The shift to flat design', paragraphs: [
        'As touchscreens became familiar and screen resolutions climbed, '
            'the industry broadly moved away from photorealistic '
            'textures toward flat design — solid colors, simple '
            'geometric shapes, and minimal or no drop shadows. Flat '
            'icons scale down far more gracefully than heavily textured '
            'ones (fine leather-grain detail simply disappears at small '
            'sizes), and they render more consistently across the wider '
            'range of screen densities that had emerged by that point.',
      ]),
      ArticleSection(heading: 'A return to subtle depth', paragraphs: [
        'More recently, design languages have swung back partway toward '
            'depth — soft shadows, gentle gradients, and layered '
            'elements — without fully returning to the photorealistic '
            'textures of the skeuomorphic era. Android\'s adaptive icons '
            'and macOS\'s current icon guidelines both reflect this: '
            'flat enough to stay legible at small sizes, but with just '
            'enough shadow and dimensionality to avoid feeling '
            'completely flat.',
      ]),
      ArticleSection(heading: 'What stayed constant', paragraphs: [
        'Across every era, the icons that aged best share the same '
            'underlying trait: a simple, high-contrast silhouette that '
            'stays recognizable regardless of the surface treatment '
            'applied on top of it. Trends in texture and depth have come '
            'and gone; a strong, simple shape has been the one constant '
            'through all of them.',
      ]),
    ],
  ),
  Article(
    slug: 'common-app-icon-mistakes',
    title: 'Common App Icon Mistakes That Get Apps Rejected From App Stores',
    excerpt:
        'The recurring icon problems that trigger App Store and Play '
        'Store review rejections — and how to avoid each one.',
    readTime: '5 min read',
    sections: [
      ArticleSection(paragraphs: [
        'App icon problems are a surprisingly common reason for a '
            'submission to bounce back from app store review, and most '
            'of the recurring issues are avoidable once you know what '
            'reviewers (and automated pre-checks) are actually looking '
            'for.',
      ]),
      ArticleSection(heading: 'Missing or wrong-sized icons', paragraphs: [
        'The most basic failure is simply not providing every required '
            'size for the platform — a missing 1024×1024 App Store '
            'marketing icon, for instance, is an instant, mechanical '
            'rejection before a human reviewer ever looks at the app '
            'itself. Because each platform expects an exact set of '
            'filenames and dimensions, this is also the category of '
            'mistake automated generation tools are specifically built '
            'to eliminate.',
      ]),
      ArticleSection(heading: 'Baked-in transparency where it isn\'t allowed', paragraphs: [
        'Apple\'s App Store marketing icon specifically must not contain '
            'transparency — an icon exported with a transparent '
            'background where a solid one is required can render with '
            'unexpected black or white fill once the store processes '
            'it, which is flagged during review.',
      ]),
      ArticleSection(heading: 'Pre-rounded corners', paragraphs: [
        'Both Apple and Google apply their own corner rounding/masking '
            'to the icon you submit — supplying an icon with the corners '
            'already rounded results in a visible double-rounded edge '
            'once the platform applies its own mask on top. The fix is '
            'submitting a full square (or full-bleed) source image and '
            'letting the platform handle the final shape itself.',
      ]),
      ArticleSection(heading: 'Full-color notification icons on Android', paragraphs: [
        'A full-color logo submitted as an Android notification icon '
            'either renders as a solid block or gets flagged during '
            'review, since Android specifically requires a monochrome '
            'silhouette for this icon type rather than the full-color '
            'launcher icon.',
      ]),
      ArticleSection(heading: 'Placeholder or default icons left in place', paragraphs: [
        'Finally, one of the most common — and most avoidable — issues '
            'is simply forgetting to replace a framework\'s default '
            'placeholder icon at all before submitting. Both major app '
            'stores treat a default framework icon as a strong signal '
            'that the app isn\'t finished, and it\'s worth explicitly '
            'checking every platform folder for a real, final icon '
            'before shipping a build for review.',
      ]),
    ],
  ),
];

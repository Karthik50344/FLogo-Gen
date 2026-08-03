class FaqItem {
  final String question;
  final String answer;
  const FaqItem(this.question, this.answer);
}

const List<FaqItem> kFaqs = [
  FaqItem(
    'Is FLogo Generator really free?',
    'Yes. There is no account, no paywall, and no limit on how many '
        'times you can generate a ZIP. The tool runs entirely in your '
        'browser, so there is no server cost tied to how much you use it.',
  ),
  FaqItem(
    'Does my logo get uploaded anywhere?',
    'No. Every step — decoding, resizing, background removal, ZIP '
        'packaging — happens locally in your browser tab using '
        'client-side JavaScript/WebAssembly. Your image is never sent '
        'to a server. See the Privacy Policy for full details.',
  ),
  FaqItem(
    'What image format should I upload?',
    'PNG with a transparent or solid background works best, ideally '
        'at least 1024×1024 pixels. SVG, JPG, and WEBP are also '
        'accepted, but a large, clean PNG gives the sharpest results '
        'across every generated size.',
  ),
  FaqItem(
    'Why do I need different icon sizes for each platform?',
    'Android, iOS, Web, Windows, macOS, and Linux each render app '
        'icons at different resolutions and in different formats — '
        'launcher icons, adaptive icon layers, favicons, .ico files, '
        'and iconsets are not interchangeable. Generating them '
        'individually by hand is tedious and error-prone; this tool '
        'produces every required size and file name in one pass.',
  ),
  FaqItem(
    'What is an Android adaptive icon?',
    'Since Android 8.0, launchers can mask and animate app icons into '
        'different shapes (circle, squircle, rounded square) depending '
        'on the device. This requires a separate foreground layer and '
        'background layer instead of one flat image. Turn on "Adaptive '
        'Icon" in Step 3 to generate both layers automatically.',
  ),
  FaqItem(
    'Why does my notification icon need to be a silhouette?',
    'Android specifically requires monochrome (single-color, '
        'transparent-background) notification icons — the system '
        'colors them itself based on the current theme. A full-color '
        'logo will either be rejected or rendered as a solid white '
        'block. This tool generates the correct silhouette '
        'automatically.',
  ),
  FaqItem(
    'Can I use this for a logo that isn\'t for a Flutter app?',
    'The generated folder structure matches Flutter\'s conventions, '
        'but the underlying PNG/ICO/iconset files are standard formats '
        'used by native Android, iOS, and desktop apps too — you can '
        'still use the individual image files even if your project '
        'isn\'t built with Flutter.',
  ),
  FaqItem(
    'My background removal left a faint edge around the logo. What happened?',
    'Background removal works by sampling the corner pixels and '
        'treating anything close to that color as background. Logos '
        'with soft gradients, anti-aliased edges, or a non-uniform '
        'background can leave a faint halo. Starting from a logo with '
        'a flat, uniform background gives the cleanest cutout.',
  ),
  FaqItem(
    'Does the generated ZIP overwrite my existing icons automatically?',
    'No — it\'s a plain ZIP you download and merge into your project '
        'yourself. Copy each platform folder\'s contents into the '
        'matching path in your Flutter project, overwriting the '
        'existing icon files there. This gives you a chance to review '
        'everything before it touches your codebase.',
  ),
  FaqItem(
    'Will this tool keep working the same way in the future?',
    'The generator follows the icon size and folder-structure '
        'conventions defined by each platform (Android, iOS, Web, '
        'Windows, macOS, Linux) and by Flutter\'s own tooling. If a '
        'platform changes its requirements, this page will be updated '
        'to match — check the Developer Guide in the project '
        'repository for the current size tables.',
  ),
];

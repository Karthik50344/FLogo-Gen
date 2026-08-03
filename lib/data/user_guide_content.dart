import 'legal_content.dart';

const List<LegalSection> kUserGuideSections = [
  LegalSection('Quick Start', [
    '1. Upload your logo — drag a PNG/SVG/JPG/WEBP onto the drop zone, '
        'or click it to browse. Square images work best. Max file size '
        'is 20MB.',
    '2. Select platforms — tap each platform you\'re shipping to. Use '
        'Select All or Clear to speed this up.',
    '3. Set image options — toggle background removal, notification icon '
        'generation, and Android adaptive icons.',
    '4. Choose a notification icon theme — pick Both, Light only, or Dark '
        'only, and adjust the background/icon colors.',
    '5. Check the output preview — a live tree view shows exactly what '
        'will be in your ZIP before you download anything.',
    '6. Generate & Download ZIP — click the button. A progress overlay '
        'shows each processing step, then your browser downloads '
        'flutter_assets.zip.',
  ]),
  LegalSection('1. Upload Logo', [
    'Accepted formats: PNG, SVG, JPG, WEBP.',
    'Square, high-resolution source images give the cleanest results — '
        'the app upscales/downscales from a single 1024×1024 working '
        'copy, so starting below roughly 512×512 can look soft at the '
        'largest sizes (like the 1024×1024 iOS marketing icon).',
    'Your file never leaves your device. Everything is processed in '
        'memory in the browser tab.',
    'Click Remove on the preview to start over with a different image.',
  ]),
  LegalSection('2. Select Platforms', [
    'Android generates mipmap launcher icons (regular + round), a Play '
        'Store 512×512 icon, and adaptive icon layers if enabled.',
    'iOS generates the full AppIcon.appiconset (all required sizes) '
        'plus Contents.json.',
    'Web generates a favicon, standard PWA icons, and maskable icons '
        'for manifest.json.',
    'Linux generates a desktop icon at the standard GTK sizes.',
    'Windows generates a multi-resolution .ico plus a 256×256 PNG app '
        'icon.',
    'macOS generates the full AppIcon.appiconset iconset plus '
        'Contents.json.',
    'You can select any combination — the output only includes what '
        'you pick.',
  ]),
  LegalSection('3. Image Options', [
    'Remove Background strips a white/light background from your logo '
        'using edge-color sampling. Works best on logos with a clean, '
        'solid, or near-white background — complex photographic '
        'backgrounds may show artifacts around edges.',
    'Generate Notification Icon produces a flat, single-color '
        'silhouette icon suitable for status-bar/notification use '
        '(Android requires monochrome notification icons).',
    'Adaptive Icon (Android) generates the separate foreground and '
        'background layers Android 8+ uses to animate and mask your '
        'icon depending on the device launcher\'s shape.',
  ]),
  LegalSection('4. Notification Icon Theme', [
    'Pick whether you need a light-mode icon, a dark-mode icon, or '
        'both, then adjust the background color (the fill behind your '
        'icon silhouette) and the icon color (the silhouette itself).',
    'Tap a color swatch to open the color picker — hue/saturation/'
        'brightness sliders, or type a hex code directly.',
  ]),
  LegalSection('5. Output Structure Preview', [
    'This updates live as you change platforms/options so you can '
        'confirm the ZIP\'s folder layout before generating anything.',
  ]),
  LegalSection('Generate & Download ZIP', [
    'Once you\'re happy with your selections, click Generate & Download '
        'ZIP. You\'ll see a short progress sequence — loading, '
        'processing, per-platform generation, packaging, download — '
        'then your browser saves flutter_assets.zip to your downloads '
        'folder.',
  ]),
  LegalSection('Using the Output in Your Flutter Project', [
    'The ZIP mirrors your project\'s real folder structure. For each '
        'platform you selected, copy the matching folder\'s contents '
        'into the same path in your Flutter project, overwriting the '
        'existing icon files (android/, ios/, web/, linux/, windows/, '
        'macos/).',
    'The notification/ folder isn\'t auto-wired into any platform '
        'config — add those assets to your notification plugin\'s '
        'setup manually.',
    'A README.md is included in every ZIP with the same instructions, '
        'generated specifically for the platforms/options you picked.',
  ]),
  LegalSection('Troubleshooting', [
    'My logo looks blurry in the largest icon sizes — start from a '
        'higher-resolution source image (ideally 1024×1024 or larger).',
    'Background removal left a faint edge/halo — try a source image '
        'with a more uniform background color, or pre-clean the image '
        'in an editor first.',
    'The ZIP is missing a platform I expected — double-check it\'s '
        'selected (highlighted with a checkmark) in Step 2 before '
        'generating.',
    'Nothing downloads when I click Generate — check your browser '
        'isn\'t blocking the download/popup; the app doesn\'t need any '
        'special permission beyond a normal file download.',
  ]),
];

import 'legal_content.dart';

/// Content for the About page. Written as a genuine project page — what
/// the tool is, why it exists, and how it's built — rather than SEO copy.
const List<LegalSection> kAboutSections = [
  LegalSection('What FLogo Generator Is', [
    'FLogo Generator is a free, browser-based tool that turns one logo '
        'into a complete set of app icons for a Flutter project. Upload a '
        'single image, choose which platforms you\'re shipping to '
        '(Android, iOS, Web, Windows, macOS, Linux), and download a ZIP '
        'containing every size, filename, and folder Flutter\'s build '
        'tooling expects.',
    'It is a Flutter Web application itself — the generator you use in '
        'the browser is written in the same framework it generates icons '
        'for.',
  ]),
  LegalSection('Why It Was Built', [
    'Producing a correct icon set by hand means exporting dozens of '
        'differently-sized PNGs, building an iOS AppIcon.appiconset with '
        'its own Contents.json, encoding a multi-resolution Windows ICO, '
        'and getting Android\'s adaptive-icon foreground/background split '
        'and notification-icon silhouette rules right — all before a '
        'single line of app code runs. Most of that work is mechanical: '
        'resize, rename, place in the right folder. FLogo Generator '
        'automates the mechanical part so the only thing left to decide '
        'is the logo itself.',
  ]),
  LegalSection('Who It Is For', [
    'Flutter developers — solo, freelance, or on a team — who need a '
        'correct icon set without hand-exporting every size themselves. '
        'It\'s equally useful for a first app icon or for refreshing an '
        'existing one after a rebrand, and works whether you\'re '
        'targeting one platform or all six.',
  ]),
  LegalSection('How the Generator Works', [
    'Everything happens in four steps: upload a logo, pick platforms and '
        'options (background removal, notification icon, adaptive icon '
        'layers), the app resizes and packages every required file from '
        'one working copy of your image, and a ZIP downloads straight to '
        'your device with the same folder structure as a real Flutter '
        'project. See the User Guide for the full walkthrough.',
  ]),
  LegalSection('Why Processing Happens on Your Device', [
    'The generator decodes, resizes, masks, and packages your image '
        'entirely inside the browser tab using Dart running compiled to '
        'JavaScript/Wasm — there is no upload step and no backend that '
        'ever sees your logo. This was a deliberate design choice, not '
        'an afterthought: a logo is often unreleased brand material, and '
        'the simplest way to keep it private is to never let it leave '
        'the device in the first place.',
  ]),
  LegalSection('Privacy Philosophy', [
    'The App does not require an account, does not track usage with '
        'analytics, and does not store your image anywhere outside the '
        'current browser tab\'s memory. The full technical detail of '
        'what is and isn\'t collected — including how advertising, if '
        'shown, is handled — is in the Privacy Policy.',
  ]),
  LegalSection('Supported Platforms', [
    'Android (launcher icons, round variants, adaptive icon layers, '
        'monochrome notification icons), iOS (full AppIcon.appiconset), '
        'Web (favicon, PWA icons, maskable icons), Windows (multi-'
        'resolution ICO), macOS (AppIcon.appiconset), and Linux '
        '(standard GTK desktop icon sizes).',
  ]),
  LegalSection('Open Source', [
    'FLogo Generator is open source under the MIT License. The source '
        'code, including the exact resizing and packaging logic used by '
        'the generator, is publicly available in the project repository '
        'linked from the footer of this site — you\'re welcome to read '
        'it, audit it, or adapt it.',
  ]),
  LegalSection('Future Direction', [
    'Planned areas of focus include expanding the guide library, '
        'refining background-removal accuracy on more complex source '
        'images, and adding a few more platform-specific icon variants '
        'as they come up. There\'s no fixed roadmap or release schedule '
        '— it\'s developed incrementally, based on what turns out to be '
        'genuinely useful.',
  ]),
  LegalSection('Contact', [
    'Questions, bug reports, or feature requests are welcome any time — '
        'see the Contact page for the best way to reach out.',
  ]),
];

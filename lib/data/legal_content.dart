class LegalSection {
  final String title;
  final List<String> paragraphs;
  const LegalSection(this.title, this.paragraphs);
}

class LegalBadge {
  final String label;
  const LegalBadge(this.label);
}

/// Content for the Privacy Policy screen. The image-processing sections
/// describe the generator's actual client-side behavior; the advertising
/// section is written to be accurate once ad units are live (the site
/// carries a Google AdSense publisher tag) without overclaiming "zero
/// data collected" in a way that would conflict with that.
const List<LegalSection> kPrivacySections = [
  LegalSection('Overview', [
    'FLogo Generator ("the App") is a browser-based, client-side tool. It '
        'accepts an image file from your device, processes it locally to '
        'produce Flutter-compatible icon assets, and packages them into a '
        'ZIP archive that is saved directly to your device.',
    'Your logo and the assets generated from it are never transmitted to '
        'any server, cloud service, or third party. All image processing '
        '— decoding, resizing, background removal, ZIP packaging — '
        'happens entirely in your browser tab, and uploaded image bytes '
        'are removed from memory once the ZIP has been written.',
    'This site may display advertising served by Google AdSense. That '
        'part of the page is covered separately below — it does not '
        'change how your logo is handled.',
  ]),
  LegalSection('1. Information We Collect', [
    'The App itself — the generator you interact with — does not collect, '
        'store, or transmit your logo, generated assets, or any personal '
        'data. There is no account system, no form that submits data to '
        'us, and no first-party analytics or tracking SDK bundled with '
        'the App.',
  ]),
  LegalSection('2. How Your Image Data Is Processed', [
    'Any logo you upload is decoded and resized entirely in local memory '
        'on your device. It is never written to disk except as part of '
        'the ZIP archive you explicitly choose to download, and it is '
        'never uploaded to any external service — including Google '
        'AdSense, which has no access to the image you\'re working with.',
  ]),
  LegalSection('3. Local Storage & Cookies', [
    'The App may use local, on-device browser storage to remember your '
        'last-used settings (such as selected platforms or theme colors) '
        'between sessions. This data stays on your device and is never '
        'synced anywhere.',
    'The App itself does not set cookies. If advertising is being shown '
        'on a given page, Google and its advertising partners may set '
        'cookies or use similar technologies in that ad slot — see the '
        '"Google AdSense" section below for what that covers.',
  ]),
  LegalSection('4. Permissions', [
    'The App only requests the file-system access needed to let you '
        'choose an image and save the generated ZIP archive. No camera, '
        'contacts, location, or network permissions are required.',
  ]),
  LegalSection('5. Google AdSense', [
    'This site is set up to display ads through Google AdSense. When an '
        'ad is shown, Google and its advertising partners may use '
        'cookies, device identifiers, or similar technologies to serve '
        'ads and measure their performance — this is standard behavior '
        'for any AdSense-monetized site and is controlled by Google, not '
        'by this App.',
    'You can see what data Google associates with your account, and opt '
        'out of personalized advertising, at Google\'s Ads Settings '
        '(adssettings.google.com). Google\'s own use of advertising '
        'cookies is explained at policies.google.com/technologies/ads.',
    'Ad placement on this site is kept away from the generator itself — '
        'ads are not placed on loading screens, error states, or inside '
        'interactive controls.',
  ]),
  LegalSection('6. Other Third-Party Services', [
    'Beyond Google AdSense, the App does not integrate any third-party '
        'analytics, crash-reporting, or advertising services. It has no '
        'social-login, chat-widget, or embedded-content dependency that '
        'would load a third-party script.',
  ]),
  LegalSection("7. Children's Privacy", [
    'The App is not directed at children under 13. It does not knowingly '
        'collect personal information from anyone, and any advertising '
        'shown is expected to be non-personalized where required by '
        'applicable law for users likely to be under that age.',
  ]),
  LegalSection('8. Your Rights', [
    'Because the App does not maintain an account system or store your '
        'personal data on any server, there is no personal data of yours '
        'held by us to access, correct, or delete. Any rights you have '
        'over data Google collects through advertising (such as access, '
        'deletion, or opting out of personalization) are exercised '
        'directly through Google\'s Ads Settings, linked above.',
  ]),
  LegalSection('9. Security', [
    'Because your logo and generated assets never leave your device, '
        'there is no transmission channel for that data to secure. Keep '
        'your device and browser up to date as general good practice.',
  ]),
  LegalSection('10. Changes to This Policy', [
    'If this policy changes, the "Effective" date at the top of this '
        'page will be updated. Continued use of the App after a change '
        'constitutes acceptance of the revised policy.',
  ]),
  LegalSection('11. Contact', [
    'Questions about this policy, including anything about advertising '
        'on this site, can be sent through the Contact page.',
  ]),
];

/// Content for the Terms & Conditions screen.
const List<LegalSection> kTermsSections = [
  LegalSection('Agreement', [
    'By using FLogo Generator you agree to these terms. They '
        'cover acceptable use, intellectual property, output quality, and '
        'limitations of liability. If you do not agree, please do not use '
        'the App.',
  ]),
  LegalSection('1. Description of the App', [
    'FLogo Generator is a free, client-side tool that converts a single '
        'uploaded logo into a set of platform-specific icon assets for '
        'Flutter projects (Android, iOS, Web, Linux, Windows, and '
        'macOS). It runs in your browser and does not require an '
        'account.',
  ]),
  LegalSection('2. Acceptable Use', [
    'You agree to use the App only for lawful purposes, and only to '
        'process images you own or have the right to use. You may not use '
        'the App to generate assets that infringe on the intellectual '
        'property of others, and you may not attempt to disrupt, scrape, '
        'or abuse the site\'s availability for other users.',
  ]),
  LegalSection('3. Intellectual Property', [
    'You retain all rights to the logo you upload and to the icon assets '
        'generated from it. The App itself, including its source code and '
        'design, remains the property of its authors under the license '
        'noted in the project repository (see "Open Source Licences" '
        'below).',
  ]),
  LegalSection('4. Output Quality and Fitness for Purpose', [
    'The App resizes and packages your logo automatically; results '
        'depend on the quality and format of the source image you '
        'provide. We recommend reviewing generated assets before '
        'shipping them in a production app.',
  ]),
  LegalSection('5. Flutter Platform Requirements', [
    'Generated assets are structured to match the folder layout expected '
        'by a standard Flutter project at the time of writing. Future '
        'changes to Flutter or platform tooling may require manual '
        'adjustment.',
  ]),
  LegalSection('6. Advertising', [
    'This site may display advertising served through Google AdSense to '
        'support its free, no-account operation. Advertisements are '
        'served and selected by Google; their content is not endorsed by '
        'the App\'s authors. See the Privacy Policy for how advertising '
        'data is handled.',
  ]),
  LegalSection('7. Availability', [
    'The App is provided on a best-effort basis with no guaranteed '
        'uptime or availability. Since it runs entirely client-side once '
        'loaded, generation itself continues to work offline even if the '
        'hosting site becomes temporarily unreachable — but the initial '
        'page load still requires connectivity.',
  ]),
  LegalSection('8. Disclaimer of Warranties', [
    'The App is provided "as is", without warranty of any kind, express '
        'or implied, including but not limited to warranties of '
        'merchantability or fitness for a particular purpose.',
  ]),
  LegalSection('9. Limitation of Liability', [
    'In no event shall the authors of the App be liable for any claim, '
        'damages, or other liability arising from, out of, or in '
        'connection with the App or the use of assets it generates.',
  ]),
  LegalSection('10. Open Source Licences', [
    'The App is built on open-source packages, each under their own '
        'license, and is itself released under the MIT License. A full '
        'list of dependencies and licenses is available in the project '
        'repository.',
  ]),
  LegalSection('11. Governing Law', [
    'These terms are governed by the laws of the jurisdiction in which '
        'the project maintainers operate, without regard to conflict-of-'
        'law principles.',
  ]),
  LegalSection('12. Changes to These Terms', [
    'If these terms change, the "Effective" date at the top of this page '
        'will be updated. Continued use of the App after a change '
        'constitutes acceptance of the revised terms.',
  ]),
  LegalSection('13. Contact', [
    'Questions about these terms can be sent through the Contact page.',
  ]),
];

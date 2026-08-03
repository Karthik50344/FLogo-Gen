class LegalSection {
  final String title;
  final List<String> paragraphs;
  const LegalSection(this.title, this.paragraphs);
}

class LegalBadge {
  final String label;
  const LegalBadge(this.label);
}

/// Content for the Privacy Policy screen. Section 1 ("Overview") mirrors
/// the copy already shipped in the live app; the remaining sections are
/// standard-shape placeholders in the same voice — replace with your
/// actual policy text if it differs.
const List<LegalSection> kPrivacySections = [
  LegalSection('Overview', [
    'FLogo Generator ("the App") is a fully offline, client-side '
        'tool. It accepts an image file from your device, processes it '
        'locally to produce Flutter-compatible icon assets, and packages '
        'them into a ZIP archive that is saved directly to your device.',
    'No personal information, image data, or generated assets are ever '
        'transmitted to any server, cloud service, or third party. All '
        'computation happens entirely on your device using Dart isolates, '
        'and uploaded image bytes are removed from memory as soon as the '
        'ZIP file has been written to disk.',
  ]),
  LegalSection('1. Information We Collect', [
    'The App does not collect, store, or transmit any personal data. We '
        'do not operate a backend server, and no analytics or tracking '
        'SDKs are bundled with the App.',
  ]),
  LegalSection('2. How Your Image Data Is Processed', [
    'Any logo you upload is decoded and resized entirely in local memory '
        'on your device. It is never written to disk except as part of '
        'the ZIP archive you explicitly choose to download, and it is '
        'never uploaded to any external service.',
  ]),
  LegalSection('3. Local Storage', [
    'The App may use local, on-device storage to remember your last-used '
        'settings (such as selected platforms or theme colors) between '
        'sessions. This data stays on your device and is never synced '
        'anywhere.',
  ]),
  LegalSection('4. Permissions', [
    'The App only requests the file-system access needed to let you '
        'choose an image and save the generated ZIP archive. No camera, '
        'contacts, location, or network permissions are required.',
  ]),
  LegalSection('5. Third-Party Services', [
    'The App does not integrate any third-party analytics, advertising, '
        'or crash-reporting services.',
  ]),
  LegalSection("6. Children's Privacy", [
    'The App is not directed at children and does not knowingly collect '
        'information from anyone, of any age, because it does not collect '
        'information at all.',
  ]),
  LegalSection('7. Security', [
    'Because all processing happens locally and no data leaves your '
        'device, there is no transmission channel to secure. Keep your '
        'device and browser up to date as general good practice.',
  ]),
  LegalSection('8. Changes to This Policy', [
    'If this policy changes, the "Effective" date at the top of this '
        'page will be updated. Continued use of the App after a change '
        'constitutes acceptance of the revised policy.',
  ]),
  LegalSection('9. Contact', [
    'Questions about this policy can be directed to the project '
        'maintainers via the repository listed in the App.',
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
    'FLogo Generator is a free, offline, client-side tool that '
        'converts a single uploaded logo into a set of platform-specific '
        'icon assets for Flutter projects (Android, iOS, Web, Linux, '
        'Windows, and macOS).',
  ]),
  LegalSection('2. Acceptable Use', [
    'You agree to use the App only for lawful purposes, and only to '
        'process images you own or have the right to use. You may not use '
        'the App to generate assets that infringe on the intellectual '
        'property of others.',
  ]),
  LegalSection('3. Intellectual Property', [
    'You retain all rights to the logo you upload and to the icon assets '
        'generated from it. The App itself, including its source code and '
        'design, remains the property of its authors under the license '
        'noted in the project repository.',
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
  LegalSection('6. Disclaimer of Warranties', [
    'The App is provided "as is", without warranty of any kind, express '
        'or implied, including but not limited to warranties of '
        'merchantability or fitness for a particular purpose.',
  ]),
  LegalSection('7. Limitation of Liability', [
    'In no event shall the authors of the App be liable for any claim, '
        'damages, or other liability arising from, out of, or in '
        'connection with the App or the use of assets it generates.',
  ]),
  LegalSection('8. Open Source Licences', [
    'The App is built on open-source packages, each under their own '
        'license. A full list of dependencies and licenses is available '
        'in the project repository.',
  ]),
  LegalSection('9. Governing Law', [
    'These terms are governed by the laws of the jurisdiction in which '
        'the project maintainers operate, without regard to conflict-of-'
        'law principles.',
  ]),
  LegalSection('10. Changes to These Terms', [
    'If these terms change, the "Effective" date at the top of this page '
        'will be updated. Continued use of the App after a change '
        'constitutes acceptance of the revised terms.',
  ]),
  LegalSection('11. Contact', [
    'Questions about these terms can be directed to the project '
        'maintainers via the repository listed in the App.',
  ]),
];

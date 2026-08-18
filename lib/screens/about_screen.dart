import 'package:flutter/material.dart';

import '../data/about_content.dart';
import '../theme/app_colors.dart';
import 'legal_page.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'About FLogo Generator',
      heroIcon: Icons.info_outline,
      subtitle: 'What FLogo Generator is, why it was built, and how it '
          'handles your logo and your privacy.',
      effectiveDate: 'Aug 2026',
      version: '1.0',
      sections: kAboutSections,
      badges: [
        PageBadge(icon: Icons.code_outlined, label: 'Open source · MIT', color: AppColors.accent),
        PageBadge(icon: Icons.lock_outline, label: 'Client-side only', color: AppColors.success),
        PageBadge(icon: Icons.attach_money, label: 'Free, no account', color: AppColors.accent),
      ],
      footerIcon: Icons.mail_outline,
      footerIconColor: AppColors.accent,
      footerNote: 'Have a question this page didn\'t answer? Reach out '
          'through the Contact page.',
    );
  }
}

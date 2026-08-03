import 'package:flutter/material.dart';

import '../data/user_guide_content.dart';
import '../theme/app_colors.dart';
import 'legal_page.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'User Guide',
      heroIcon: Icons.menu_book_outlined,
      subtitle: 'Everything you need to turn one logo into a full set of '
          'Flutter platform icons — step by step, plus fixes for the most '
          'common snags.',
      effectiveDate: 'Aug 2026',
      version: '1.0',
      sections: kUserGuideSections,
      badges: [
        PageBadge(icon: Icons.list_alt_outlined, label: '6 steps', color: AppColors.accent),
        PageBadge(icon: Icons.timer_outlined, label: '~5 min read', color: AppColors.success),
        PageBadge(icon: Icons.lock_outline, label: 'Runs fully offline', color: AppColors.accent),
      ],
      footerIcon: Icons.mail_outline,
      footerIconColor: AppColors.accent,
      footerNote: 'Still stuck? Use the Contact Us link in the footer to '
          'reach out directly.',
    );
  }
}

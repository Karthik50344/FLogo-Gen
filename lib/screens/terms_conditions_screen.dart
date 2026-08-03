import 'package:flutter/material.dart';

import '../data/legal_content.dart';
import '../theme/app_colors.dart';
import 'legal_page.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const _effectiveDate = 'April 1, 2025';
  static const _version = '1.0';

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Terms & Conditions',
      heroIcon: Icons.gavel_outlined,
      subtitle: 'By using Flutter Logo Generator you agree to these terms. '
          'They cover acceptable use, intellectual property, output quality, '
          'and limitations of liability.',
      effectiveDate: _effectiveDate,
      version: _version,
      sections: kTermsSections,
      badges: [
        PageBadge(icon: Icons.calendar_today_outlined, label: 'Effective $_effectiveDate', color: AppColors.accent),
        PageBadge(icon: Icons.verified_outlined, label: 'Version $_version', color: AppColors.success),
        PageBadge(icon: Icons.lock_outline, label: 'No data collected', color: AppColors.accent),
      ],
    );
  }
}

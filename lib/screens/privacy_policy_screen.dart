import 'package:flutter/material.dart';

import '../data/legal_content.dart';
import '../theme/app_colors.dart';
import 'legal_page.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _effectiveDate = 'April 1, 2025';
  static const _version = '1.0';

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Privacy Policy',
      heroIcon: Icons.privacy_tip_outlined,
      subtitle: 'Flutter Logo Generator processes all images locally on your '
          'device. This policy explains exactly what data is handled and how.',
      effectiveDate: _effectiveDate,
      version: _version,
      sections: kPrivacySections,
      badges: [
        PageBadge(icon: Icons.calendar_today_outlined, label: 'Effective $_effectiveDate', color: AppColors.accent),
        PageBadge(icon: Icons.verified_outlined, label: 'Version $_version', color: AppColors.success),
        PageBadge(icon: Icons.lock_outline, label: 'No data collected', color: AppColors.accent),
      ],
    );
  }
}

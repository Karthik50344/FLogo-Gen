import 'package:flutter/material.dart';

import '../data/legal_content.dart';
import 'legal_page.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Privacy Policy',
      heroIcon: Icons.privacy_tip_outlined,
      subtitle: 'Flutter Logo Generator processes all images locally on your '
          'device. This policy explains exactly what data is handled and how.',
      effectiveDate: 'April 1, 2025',
      version: '1.0',
      sections: kPrivacySections,
    );
  }
}

import 'package:flutter/material.dart';

import '../data/legal_content.dart';
import 'legal_page.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Terms & Conditions',
      heroIcon: Icons.gavel_outlined,
      subtitle: 'By using Flutter Logo Generator you agree to these terms. '
          'They cover acceptable use, intellectual property, output quality, '
          'and limitations of liability.',
      effectiveDate: 'April 1, 2025',
      version: '1.0',
      sections: kTermsSections,
    );
  }
}

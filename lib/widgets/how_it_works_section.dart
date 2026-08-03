import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  static const _steps = [
    (
      icon: Icons.upload_file_outlined,
      title: 'Upload your logo',
      body: 'Drop in a single PNG, SVG, JPG, or WEBP file — ideally square '
          'and at least 512×512 pixels. The image stays in your browser '
          'the entire time; it\'s never sent to a server.',
    ),
    (
      icon: Icons.dashboard_customize_outlined,
      title: 'Pick your platforms and options',
      body: 'Choose any combination of Android, iOS, Web, Windows, macOS, '
          'and Linux, then decide whether you need background removal, '
          'a monochrome notification icon, or Android adaptive icon '
          'layers.',
    ),
    (
      icon: Icons.auto_awesome_outlined,
      title: 'Everything gets resized and packaged',
      body: 'From one working copy of your logo, the generator produces '
          'every required size and file format for each platform you '
          'picked — matching the exact folder structure a Flutter '
          'project expects.',
    ),
    (
      icon: Icons.folder_zip_outlined,
      title: 'Download and drop it into your project',
      body: 'A single ZIP downloads straight to your device. Copy each '
          'platform folder into the matching path in your Flutter '
          'project, and every icon is in place.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How It Works',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640),
          child: Text(
            'Four steps, entirely in your browser, from one source logo to a '
            'complete, ready-to-use icon set.',
            style: TextStyle(fontSize: 15, color: AppColors.text2, height: 1.6),
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 780;
          final cards = [for (final s in _steps) _StepCard(step: s)];
          if (!wide) {
            return Column(
              children: [
                for (var i = 0; i < cards.length; i++)
                  Padding(padding: const EdgeInsets.only(bottom: 14), child: cards[i]),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final ({IconData icon, String title, String body}) step;
  const _StepCard({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(step.icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(height: 14),
          Text(step.title,
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 8),
          Text(step.body,
              style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.6)),
        ],
      ),
    );
  }
}

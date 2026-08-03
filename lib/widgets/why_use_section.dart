import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WhyUseSection extends StatelessWidget {
  const WhyUseSection({super.key});

  static const _points = [
    (
      icon: Icons.rule_folder_outlined,
      title: 'Every size, correctly named, in the right folder',
      body: 'Flutter app icons aren\'t one file — a full six-platform set '
          'can mean 40+ individual images across five density folders, an '
          'iOS iconset, a Windows ICO, and more. This generator produces '
          'every one of them at once, named and placed exactly the way '
          'each platform\'s build tooling expects.',
    ),
    (
      icon: Icons.lock_outline,
      title: 'Nothing ever leaves your browser',
      body: 'Decoding, resizing, background removal, and ZIP packaging all '
          'happen client-side. Your logo is never uploaded to a server, '
          'and no account or sign-up is required to use the tool.',
    ),
    (
      icon: Icons.layers_outlined,
      title: 'Handles the platform-specific quirks for you',
      body: 'Android adaptive icon safe zones, monochrome notification '
          'icon silhouettes, multi-resolution Windows ICO containers, '
          'iOS/macOS Contents.json manifests — the parts of icon '
          'generation that are easy to get subtly wrong by hand are '
          'built directly into the generator.',
    ),
    (
      icon: Icons.bolt_outlined,
      title: 'One upload, every platform',
      body: 'Instead of exporting a dozen sizes by hand for each platform '
          'you support, upload a logo once and select every platform you '
          'need — the ZIP comes back with everything ready to drop into '
          'your project.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Why Use FLogo Generator',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640),
          child: Text(
            'Generating app icons by hand is tedious and easy to get subtly '
            'wrong. Here\'s what this tool takes care of for you.',
            style: TextStyle(fontSize: 15, color: AppColors.text2, height: 1.6),
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 700;
          final cards = [for (final p in _points) _PointCard(point: p)];
          if (!wide) {
            return Column(
              children: [
                for (var i = 0; i < cards.length; i++)
                  Padding(padding: const EdgeInsets.only(bottom: 14), child: cards[i]),
              ],
            );
          }
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }),
      ],
    );
  }
}

class _PointCard extends StatelessWidget {
  final ({IconData icon, String title, String body}) point;
  const _PointCard({required this.point});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppColors.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(point.icon, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(point.title,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 8),
                Text(point.body,
                    style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

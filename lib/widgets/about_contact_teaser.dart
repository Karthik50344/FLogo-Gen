import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Short "About FLogo Generator" / "Contact" cards on the homepage. Full
/// content lives on the dedicated /about and /contact pages — this is
/// just enough context to explain what those pages are before linking
/// to them, and to give the homepage real internal links to both.
class AboutContactTeaser extends StatelessWidget {
  const AboutContactTeaser({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > 700;
      final cards = [
        _TeaserCard(
          icon: Icons.info_outline,
          title: 'About This Project',
          body: 'Why FLogo Generator was built, how the client-side '
              'generation actually works, and what\'s planned next.',
          linkLabel: 'Read the story',
          route: '/about',
        ),
        _TeaserCard(
          icon: Icons.mail_outline,
          title: 'Get In Touch',
          body: 'Found a bug, want a platform added, or have a privacy '
              'question? Every message is read directly by the developer.',
          linkLabel: 'Contact us',
          route: '/contact',
        ),
      ];
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
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
        ],
      );
    });
  }
}

class _TeaserCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String body;
  final String linkLabel;
  final String route;
  const _TeaserCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.linkLabel,
    required this.route,
  });

  @override
  State<_TeaserCard> createState() => _TeaserCardState();
}

class _TeaserCardState extends State<_TeaserCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(widget.route),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: _hovering ? AppColors.border2 : AppColors.border),
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
                child: Icon(widget.icon, color: AppColors.accent, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 8),
                    Text(widget.body,
                        style: const TextStyle(fontSize: 13, color: AppColors.text2, height: 1.6)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.linkLabel,
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: _hovering ? AppColors.accent : AppColors.text2)),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14, color: _hovering ? AppColors.accent : AppColors.text3),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

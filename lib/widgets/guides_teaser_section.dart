import 'package:flutter/material.dart';
import '../data/articles_content.dart';
import '../theme/app_colors.dart';

class GuidesTeaserSection extends StatelessWidget {
  const GuidesTeaserSection({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = kArticles.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Guides & Articles',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: const Text(
                      'App icon sizing, platform requirements, and design tips, '
                      'written up in full.',
                      style: TextStyle(fontSize: 15, color: AppColors.text2, height: 1.6),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/guides'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View all', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 16, color: AppColors.accent),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (context, constraints) {
          final wide = constraints.maxWidth > 700;
          final cards = [for (final a in featured) _GuideCard(article: a)];
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

class _GuideCard extends StatefulWidget {
  final Article article;
  const _GuideCard({required this.article});

  @override
  State<_GuideCard> createState() => _GuideCardState();
}

class _GuideCardState extends State<_GuideCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed('/guides/${widget.article.slug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radius),
            border: Border.all(color: _hovering ? AppColors.border2 : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.article.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: _hovering ? AppColors.accent : AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.article.excerpt,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, color: AppColors.text2, height: 1.5),
              ),
              const SizedBox(height: 12),
              Text(widget.article.readTime,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.text3)),
            ],
          ),
        ),
      ),
    );
  }
}

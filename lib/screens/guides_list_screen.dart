import 'package:flutter/material.dart';

import '../data/articles_content.dart';
import '../theme/app_colors.dart';
import '../widgets/site_nav_bar.dart';

class GuidesListScreen extends StatelessWidget {
  const GuidesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SiteNavBar(showBack: true),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.accent.withOpacity(0.25)),
                          ),
                          child: const Icon(Icons.auto_stories_outlined, color: AppColors.accent, size: 26),
                        ),
                        const SizedBox(height: 20),
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors.titleGradient.createShader(bounds),
                          child: const Text(
                            'Guides & Articles',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 640),
                          child: Text(
                            'App icon sizing, platform requirements, and design tips — '
                            'everything we learned building this generator, written up '
                            'so you don\'t have to dig through platform docs yourself.',
                            style: TextStyle(fontSize: 15, color: AppColors.text2, height: 1.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        for (final article in kArticles) _ArticleCard(article: article),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatefulWidget {
  final Article article;
  const _ArticleCard({required this.article});

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/guides/${widget.article.slug}'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppColors.radius),
              border: Border.all(color: _hovering ? AppColors.border2 : AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.article.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _hovering ? AppColors.accent : AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.article.excerpt,
                        style: const TextStyle(fontSize: 13.5, color: AppColors.text2, height: 1.5),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 13, color: AppColors.text3),
                          const SizedBox(width: 6),
                          Text(widget.article.readTime,
                              style: const TextStyle(fontSize: 12, color: AppColors.text3)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right, color: _hovering ? AppColors.accent : AppColors.text3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

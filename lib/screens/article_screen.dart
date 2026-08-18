import 'package:flutter/material.dart';

import '../data/article_model.dart';
import '../data/articles_content.dart';
import '../theme/app_colors.dart';
import '../widgets/site_nav_bar.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;
  const ArticleScreen({super.key, required this.article});

  /// Up to 3 other articles, used for the "Related guides" section —
  /// real internal links between content pages instead of every guide
  /// only linking back to /guides.
  List<Article> _relatedArticles() {
    final others = kArticles.where((a) => a.slug != article.slug).toList();
    final startIndex = kArticles.indexOf(article);
    final rotated = [
      for (var i = 0; i < others.length; i++)
        others[(startIndex + i) % others.length],
    ];
    return rotated.take(3).toList();
  }

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
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBreadcrumb(context),
                        const SizedBox(height: 20),
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors.titleGradient.createShader(bounds),
                          child: Text(
                            article.title,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildMetaRow(),
                        const SizedBox(height: 24),
                        Text(
                          article.excerpt,
                          style: const TextStyle(
                              fontSize: 16, color: AppColors.text2, height: 1.6, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 32),
                        for (final section in article.sections) _buildSection(section),
                        const SizedBox(height: 8),
                        _buildFooter(context),
                        const SizedBox(height: 28),
                        _buildRelated(context),
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

  Widget _buildMetaRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 14, color: AppColors.text3),
            const SizedBox(width: 6),
            Text(article.readTime, style: const TextStyle(fontSize: 13, color: AppColors.text3)),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_outlined, size: 14, color: AppColors.text3),
            const SizedBox(width: 6),
            const Text('Written by FLogo Generator',
                style: TextStyle(fontSize: 13, color: AppColors.text3)),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.update_outlined, size: 14, color: AppColors.text3),
            const SizedBox(width: 6),
            Text('Updated ${article.lastUpdated}',
                style: const TextStyle(fontSize: 13, color: AppColors.text3)),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(ArticleSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.heading != null) ...[
            Text(
              section.heading!,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.text),
            ),
            const SizedBox(height: 10),
          ],
          for (var i = 0; i < section.paragraphs.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == section.paragraphs.length - 1 ? 0 : 14),
              child: Text(
                section.paragraphs[i],
                style: const TextStyle(fontSize: 15, color: AppColors.text2, height: 1.75),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
          child: const Text('Home',
              style: TextStyle(fontSize: 13, color: AppColors.text3, fontWeight: FontWeight.w500)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('/', style: TextStyle(fontSize: 13, color: AppColors.text3)),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/guides', (r) => false),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories_outlined, size: 14, color: AppColors.accent),
              SizedBox(width: 6),
              Text('Guides & Articles',
                  style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Ready to generate your icons?',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                    SizedBox(height: 4),
                    Text('Upload a logo and get every size covered in this guide, in one pass.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.text2)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('Open Generator'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _InlineLink(
                label: 'User Guide',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/user-guide', (r) => false),
              ),
              _InlineLink(
                label: 'About FLogo Generator',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/about', (r) => false),
              ),
              _InlineLink(
                label: 'Contact',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/contact', (r) => false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelated(BuildContext context) {
    final related = _relatedArticles();
    if (related.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Related Guides',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text)),
        const SizedBox(height: 14),
        for (final a in related) _RelatedRow(article: a),
      ],
    );
  }
}

class _InlineLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _InlineLink({required this.label, required this.onTap});

  @override
  State<_InlineLink> createState() => _InlineLinkState();
}

class _InlineLinkState extends State<_InlineLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _hovering ? AppColors.accent : AppColors.text2,
            decoration: _hovering ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _RelatedRow extends StatefulWidget {
  final Article article;
  const _RelatedRow({required this.article});

  @override
  State<_RelatedRow> createState() => _RelatedRowState();
}

class _RelatedRowState extends State<_RelatedRow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushReplacementNamed('/guides/${widget.article.slug}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppColors.radius2),
            border: Border.all(color: _hovering ? AppColors.border2 : AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.article.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _hovering ? AppColors.accent : AppColors.text,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: _hovering ? AppColors.accent : AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}

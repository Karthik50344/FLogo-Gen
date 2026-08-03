import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/article_model.dart';
import '../theme/app_colors.dart';

class ArticleScreen extends StatelessWidget {
  final Article article;
  const ArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
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
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: AppColors.text3),
                            const SizedBox(width: 6),
                            Text(article.readTime,
                                style: const TextStyle(fontSize: 13, color: AppColors.text3)),
                          ],
                        ),
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
    return GestureDetector(
      onTap: () => Navigator.of(context).pushReplacementNamed('/guides'),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_outlined, size: 14, color: AppColors.accent),
          SizedBox(width: 6),
          Text('Guides & Articles',
              style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              article.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
            ),
          ),
          IconButton(
            tooltip: 'Copy link',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: article.title));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied')),
              );
            },
            icon: const Icon(Icons.copy_outlined, color: AppColors.text2, size: 20),
          ),
        ],
      ),
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
      child: Row(
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
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
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
    );
  }
}

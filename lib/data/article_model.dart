class ArticleSection {
  final String? heading;
  final List<String> paragraphs;
  const ArticleSection({this.heading, required this.paragraphs});
}

class Article {
  final String slug;
  final String title;
  final String excerpt;
  final String readTime;
  final List<ArticleSection> sections;

  /// When this article's content was last reviewed/updated. Shown on the
  /// article page as a trust signal and used for the JSON-LD `dateModified`
  /// field. Defaults to the date this content pass was written.
  final String lastUpdated;

  const Article({
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.readTime,
    required this.sections,
    this.lastUpdated = 'August 2026',
  });

  /// Meta description for this article's page. Reuses the excerpt (already
  /// written as a 1-2 sentence summary) so every /guides/<slug> route gets
  /// a unique, accurate <meta name="description"> without duplicating text.
  String get metaDescription => excerpt;
}

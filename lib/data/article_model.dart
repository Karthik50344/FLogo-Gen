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

  const Article({
    required this.slug,
    required this.title,
    required this.excerpt,
    required this.readTime,
    required this.sections,
  });
}

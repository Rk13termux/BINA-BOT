/// Modelo para artículos de noticias
class NewsArticle {
  final String title;
  final String url;
  final String source;
  final DateTime publishedAt;
  final String summary;
  final String content; // Contenido completo del artículo
  final String? imageUrl;
  final List<String> tags;
  final String category; // Categoría del artículo
  final String sentiment; // Sentimiento: Positive, Negative, Neutral

  NewsArticle({
    required this.title,
    required this.url,
    required this.source,
    required this.publishedAt,
    required this.summary,
    required this.content,
    this.imageUrl,
    this.tags = const [],
    required this.category,
    required this.sentiment,
  });

  /// Convierte a JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'source': source,
      'publishedAt': publishedAt.toIso8601String(),
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'tags': tags,
      'category': category,
      'sentiment': sentiment,
    };
  }

  /// Crea desde JSON
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      source: json['source'] ?? '',
      publishedAt: DateTime.parse(
          json['publishedAt'] ?? DateTime.now().toIso8601String()),
      summary: json['summary'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? 'General',
      sentiment: json['sentiment'] ?? 'Neutral',
    );
  }

  /// Crea copia con modificaciones
  NewsArticle copyWith({
    String? title,
    String? url,
    String? source,
    DateTime? publishedAt,
    String? summary,
    String? content,
    String? imageUrl,
    List<String>? tags,
    String? category,
    String? sentiment,
  }) {
    return NewsArticle(
      title: title ?? this.title,
      url: url ?? this.url,
      source: source ?? this.source,
      publishedAt: publishedAt ?? this.publishedAt,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      sentiment: sentiment ?? this.sentiment,
    );
  }

  @override
  String toString() {
    return 'NewsArticle(title: $title, source: $source, publishedAt: $publishedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NewsArticle &&
        other.title == title &&
        other.url == url &&
        other.source == source;
  }

  @override
  int get hashCode {
    return title.hashCode ^ url.hashCode ^ source.hashCode;
  }
}

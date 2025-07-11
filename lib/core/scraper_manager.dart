import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/news_article.dart';
import '../utils/logger.dart';

/// Gestiona el scraping de noticias de criptomonedas sin usar APIs externas
class ScraperManager {
  final AppLogger _logger = AppLogger();
  final Map<String, Timer> _scheduledScrapers = {};
  
  // URLs de fuentes de noticias
  static const Map<String, String> _newsSources = {
    'coindesk': 'https://www.coindesk.com/tag/markets/',
    'cointelegraph': 'https://cointelegraph.com/tags/markets',
    'cryptonews': 'https://cryptonews.com/news/',
    'decrypt': 'https://decrypt.co/news',
  };

  /// Scraping de CoinDesk
  Future<List<NewsArticle>> scrapeCoinDesk() async {
    final List<NewsArticle> articles = [];
    
    try {
      final response = await http.get(
        Uri.parse(_newsSources['coindesk']!),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final articleElements = document.querySelectorAll('.card-title, .article-card, .headline');

        for (final element in articleElements.take(10)) {
          final title = _extractText(element, 'a, h2, h3, .title');
          final link = _extractAttribute(element, 'a', 'href');
          final time = _extractText(element.parent, '.time, .date, .timestamp');

          if (title.isNotEmpty && link.isNotEmpty) {
            articles.add(NewsArticle(
              title: title,
              url: _makeAbsoluteUrl(link, 'https://www.coindesk.com'),
              source: 'CoinDesk',
              publishedAt: _parseTime(time),
              summary: '',
            ));
          }
        }
      }
    } catch (e) {
      _logger.error('Error scraping CoinDesk: $e');
    }

    return articles;
  }

  /// Scraping de CoinTelegraph
  Future<List<NewsArticle>> scrapeCoinTelegraph() async {
    final List<NewsArticle> articles = [];
    
    try {
      final response = await http.get(
        Uri.parse(_newsSources['cointelegraph']!),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final articleElements = document.querySelectorAll('.post-card, .news-item, .article');

        for (final element in articleElements.take(10)) {
          final title = _extractText(element, '.post-card__title, .title, h2, h3');
          final link = _extractAttribute(element, 'a', 'href');
          final time = _extractText(element, '.post-card__date, .date, time');

          if (title.isNotEmpty && link.isNotEmpty) {
            articles.add(NewsArticle(
              title: title,
              url: _makeAbsoluteUrl(link, 'https://cointelegraph.com'),
              source: 'CoinTelegraph',
              publishedAt: _parseTime(time),
              summary: '',
            ));
          }
        }
      }
    } catch (e) {
      _logger.error('Error scraping CoinTelegraph: $e');
    }

    return articles;
  }

  /// Scraping de CryptoNews
  Future<List<NewsArticle>> scrapeCryptoNews() async {
    final List<NewsArticle> articles = [];
    
    try {
      final response = await http.get(
        Uri.parse(_newsSources['cryptonews']!),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final articleElements = document.querySelectorAll('.news-item, .article-card, .post');

        for (final element in articleElements.take(10)) {
          final title = _extractText(element, '.title, h2, h3, a');
          final link = _extractAttribute(element, 'a', 'href');
          final time = _extractText(element, '.date, .time, .timestamp');

          if (title.isNotEmpty && link.isNotEmpty) {
            articles.add(NewsArticle(
              title: title,
              url: _makeAbsoluteUrl(link, 'https://cryptonews.com'),
              source: 'CryptoNews',
              publishedAt: _parseTime(time),
              summary: '',
            ));
          }
        }
      }
    } catch (e) {
      _logger.error('Error scraping CryptoNews: $e');
    }

    return articles;
  }

  /// Scraping de Decrypt
  Future<List<NewsArticle>> scrapeDecrypt() async {
    final List<NewsArticle> articles = [];
    
    try {
      final response = await http.get(
        Uri.parse(_newsSources['decrypt']!),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final articleElements = document.querySelectorAll('.post, .article, .news-card');

        for (final element in articleElements.take(10)) {
          final title = _extractText(element, '.post-title, .title, h2, h3');
          final link = _extractAttribute(element, 'a', 'href');
          final time = _extractText(element, '.post-date, .date, time');

          if (title.isNotEmpty && link.isNotEmpty) {
            articles.add(NewsArticle(
              title: title,
              url: _makeAbsoluteUrl(link, 'https://decrypt.co'),
              source: 'Decrypt',
              publishedAt: _parseTime(time),
              summary: '',
            ));
          }
        }
      }
    } catch (e) {
      _logger.error('Error scraping Decrypt: $e');
    }

    return articles;
  }

  /// Obtiene noticias de todas las fuentes
  Future<List<NewsArticle>> scrapeAllSources() async {
    final List<NewsArticle> allArticles = [];
    
    final futures = [
      scrapeCoinDesk(),
      scrapeCoinTelegraph(),
      scrapeCryptoNews(),
      scrapeDecrypt(),
    ];

    final results = await Future.wait(futures);
    
    for (final articles in results) {
      allArticles.addAll(articles);
    }

    // Ordenar por fecha (más recientes primero)
    allArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    
    // Remover duplicados basados en título similar
    final uniqueArticles = <NewsArticle>[];
    for (final article in allArticles) {
      final isDuplicate = uniqueArticles.any((existing) => 
        _calculateSimilarity(existing.title, article.title) > 0.8
      );
      
      if (!isDuplicate) {
        uniqueArticles.add(article);
      }
    }

    _logger.info('Scraped ${uniqueArticles.length} unique articles');
    return uniqueArticles;
  }

  /// Programa scraping automático
  void scheduleAutoScraping({Duration interval = const Duration(minutes: 30)}) {
    _scheduledScrapers['auto'] = Timer.periodic(interval, (timer) {
      scrapeAllSources();
    });
    
    _logger.info('Auto scraping scheduled every ${interval.inMinutes} minutes');
  }

  /// Detiene el scraping automático
  void stopAutoScraping() {
    _scheduledScrapers['auto']?.cancel();
    _scheduledScrapers.remove('auto');
    _logger.info('Auto scraping stopped');
  }

  /// Scraping específico de un término de búsqueda
  Future<List<NewsArticle>> scrapeByKeyword(String keyword) async {
    final allArticles = await scrapeAllSources();
    
    final filteredArticles = allArticles.where((article) =>
      article.title.toLowerCase().contains(keyword.toLowerCase()) ||
      article.summary.toLowerCase().contains(keyword.toLowerCase())
    ).toList();

    _logger.info('Found ${filteredArticles.length} articles for keyword: $keyword');
    return filteredArticles;
  }

  /// Extrae texto de un elemento
  String _extractText(Element? element, String selector) {
    if (element == null) return '';
    
    final targetElement = selector.isEmpty 
        ? element 
        : element.querySelector(selector);
    
    return targetElement?.text.trim() ?? '';
  }

  /// Extrae atributo de un elemento
  String _extractAttribute(Element? element, String selector, String attribute) {
    if (element == null) return '';
    
    final targetElement = element.querySelector(selector);
    return targetElement?.attributes[attribute] ?? '';
  }

  /// Convierte URL relativa a absoluta
  String _makeAbsoluteUrl(String url, String baseUrl) {
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return '$baseUrl$url';
    return '$baseUrl/$url';
  }

  /// Parsea fecha y hora
  DateTime _parseTime(String timeStr) {
    if (timeStr.isEmpty) return DateTime.now();
    
    try {
      // Intentar varios formatos de fecha comunes
      final now = DateTime.now();
      
      // Si contiene "ago", calcular tiempo relativo
      if (timeStr.toLowerCase().contains('ago')) {
        return _parseRelativeTime(timeStr);
      }
      
      // Intentar parsear fecha ISO
      if (timeStr.contains('T')) {
        return DateTime.parse(timeStr);
      }
      
      return now;
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Parsea tiempo relativo ("2 hours ago", etc.)
  DateTime _parseRelativeTime(String timeStr) {
    final now = DateTime.now();
    final lower = timeStr.toLowerCase();
    
    if (lower.contains('hour')) {
      final match = RegExp(r'(\d+)').firstMatch(lower);
      if (match != null) {
        final hours = int.parse(match.group(1)!);
        return now.subtract(Duration(hours: hours));
      }
    }
    
    if (lower.contains('minute')) {
      final match = RegExp(r'(\d+)').firstMatch(lower);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        return now.subtract(Duration(minutes: minutes));
      }
    }
    
    if (lower.contains('day')) {
      final match = RegExp(r'(\d+)').firstMatch(lower);
      if (match != null) {
        final days = int.parse(match.group(1)!);
        return now.subtract(Duration(days: days));
      }
    }
    
    return now;
  }

  /// Calcula similitud entre dos strings
  double _calculateSimilarity(String str1, String str2) {
    if (str1 == str2) return 1.0;
    
    final len1 = str1.length;
    final len2 = str2.length;
    
    if (len1 == 0 || len2 == 0) return 0.0;
    
    final maxLen = len1 > len2 ? len1 : len2;
    final distance = _levenshteinDistance(str1.toLowerCase(), str2.toLowerCase());
    
    return 1.0 - (distance / maxLen);
  }

  /// Calcula distancia de Levenshtein
  int _levenshteinDistance(String str1, String str2) {
    final matrix = List.generate(
      str1.length + 1,
      (i) => List.filled(str2.length + 1, 0),
    );

    for (int i = 0; i <= str1.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= str2.length; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= str1.length; i++) {
      for (int j = 1; j <= str2.length; j++) {
        final cost = str1[i - 1] == str2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[str1.length][str2.length];
  }

  /// Limpia recursos
  void dispose() {
    for (final timer in _scheduledScrapers.values) {
      timer.cancel();
    }
    _scheduledScrapers.clear();
    _logger.info('ScraperManager disposed');
  }
}

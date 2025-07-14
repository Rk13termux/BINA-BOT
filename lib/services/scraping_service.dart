import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as html_dom;
import '../models/news_article.dart';
import '../utils/logger.dart';
import '../utils/constants.dart';

class ScrapingService {
  static final AppLogger _logger = AppLogger();
  static const Map<String, String> _headers = {
    'User-Agent': AppConstants.userAgent,
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
    'Accept-Encoding': 'gzip, deflate',
    'Connection': 'keep-alive',
    'Upgrade-Insecure-Requests': '1',
  };

  // News sources configuration
  static const Map<String, Map<String, String>> _newsSources = {
    'coindesk': {
      'url': 'https://www.coindesk.com/tag/bitcoin/',
      'titleSelector': 'h2 a, h3 a, .headline a',
      'linkSelector': 'h2 a, h3 a, .headline a',
      'excerptSelector': '.excerpt, .summary, p',
      'timeSelector': 'time, .timestamp, .date',
      'baseUrl': 'https://www.coindesk.com',
    },
    'cointelegraph': {
      'url': 'https://cointelegraph.com/tags/bitcoin',
      'titleSelector': '.post-card-inline__title a, .post-title a',
      'linkSelector': '.post-card-inline__title a, .post-title a',
      'excerptSelector': '.post-card-inline__text, .post-excerpt',
      'timeSelector': '.post-card-inline__time, .post-meta time',
      'baseUrl': 'https://cointelegraph.com',
    },
    'cryptonews': {
      'url': 'https://cryptonews.com/news/',
      'titleSelector': '.article__title a, h2 a',
      'linkSelector': '.article__title a, h2 a',
      'excerptSelector': '.article__excerpt, .excerpt',
      'timeSelector': '.article__time, time',
      'baseUrl': 'https://cryptonews.com',
    },
  };

  /// Scrape news from all configured sources
  Future<List<NewsArticle>> scrapeAllNews(
      {int maxArticlesPerSource = 5}) async {
    final List<NewsArticle> allNews = [];

    for (final source in _newsSources.keys) {
      try {
        final articles =
            await scrapeNewsFromSource(source, limit: maxArticlesPerSource);
        allNews.addAll(articles);
        _logger.info('Scraped ${articles.length} articles from $source');

        // Add delay between requests to be respectful
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        _logger.error('Failed to scrape news from $source: $e');
      }
    }

    // Sort by publish date (newest first)
    allNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    _logger.info('Total scraped articles: ${allNews.length}');
    return allNews;
  }

  /// Scrape news from a specific source
  Future<List<NewsArticle>> scrapeNewsFromSource(String source,
      {int limit = 10}) async {
    final sourceConfig = _newsSources[source];
    if (sourceConfig == null) {
      throw Exception('Unknown news source: $source');
    }

    try {
      final response = await http
          .get(
            Uri.parse(sourceConfig['url']!),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode} for $source');
      }

      final document = html_parser.parse(response.body);
      final articles = <NewsArticle>[];

      // Extract articles based on selectors
      final titleElements =
          document.querySelectorAll(sourceConfig['titleSelector']!);
      final linkElements =
          document.querySelectorAll(sourceConfig['linkSelector']!);
      final excerptElements =
          document.querySelectorAll(sourceConfig['excerptSelector']!);
      final timeElements =
          document.querySelectorAll(sourceConfig['timeSelector']!);

      final maxElements = [titleElements.length, linkElements.length]
          .reduce((a, b) => a < b ? a : b);
      final articlesCount = maxElements > limit ? limit : maxElements;

      for (int i = 0; i < articlesCount; i++) {
        try {
          final title = _extractText(titleElements, i);
          final link = _extractLink(linkElements, i, sourceConfig['baseUrl']!);
          final excerpt = _extractText(excerptElements, i);
          final publishedAt = _extractDate(timeElements, i);

          if (title.isNotEmpty && link.isNotEmpty) {
            articles.add(NewsArticle(
              title: title,
              summary: excerpt,
              url: link,
              source: source,
              publishedAt: publishedAt,
              imageUrl: '', // Could be enhanced to extract images
            ));
          }
        } catch (e) {
          _logger.debug('Failed to parse article $i from $source: $e');
        }
      }

      return articles;
    } catch (e) {
      _logger.error('Failed to scrape $source: $e');
      return [];
    }
  }

  /// Extract text content from DOM elements
  String _extractText(List<html_dom.Element> elements, int index) {
    if (index >= elements.length) return '';
    return elements[index].text.trim();
  }

  /// Extract and normalize link from DOM elements
  String _extractLink(
      List<html_dom.Element> elements, int index, String baseUrl) {
    if (index >= elements.length) return '';

    final href = elements[index].attributes['href'] ?? '';
    if (href.isEmpty) return '';

    // Handle relative URLs
    if (href.startsWith('/')) {
      return '$baseUrl$href';
    } else if (href.startsWith('http')) {
      return href;
    } else {
      return '$baseUrl/$href';
    }
  }

  /// Extract and parse date from DOM elements
  DateTime _extractDate(List<html_dom.Element> elements, int index) {
    if (index >= elements.length) return DateTime.now();

    final element = elements[index];
    final dateStr = element.attributes['datetime'] ??
        element.attributes['content'] ??
        element.text.trim();

    try {
      // Try to parse ISO format first
      return DateTime.parse(dateStr);
    } catch (e) {
      // Try common date formats
      final patterns = [
        RegExp(r'(\d{4})-(\d{2})-(\d{2})'),
        RegExp(r'(\d{2})/(\d{2})/(\d{4})'),
        RegExp(r'(\d{1,2})\s+(hours?|minutes?|days?)\s+ago',
            caseSensitive: false),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(dateStr);
        if (match != null) {
          try {
            if (pattern == patterns[2]) {
              // Handle relative time (e.g., "2 hours ago")
              final value = int.parse(match.group(1)!);
              final unit = match.group(2)!.toLowerCase();

              if (unit.startsWith('hour')) {
                return DateTime.now().subtract(Duration(hours: value));
              } else if (unit.startsWith('minute')) {
                return DateTime.now().subtract(Duration(minutes: value));
              } else if (unit.startsWith('day')) {
                return DateTime.now().subtract(Duration(days: value));
              }
            } else if (pattern == patterns[0]) {
              // YYYY-MM-DD format
              return DateTime(
                int.parse(match.group(1)!),
                int.parse(match.group(2)!),
                int.parse(match.group(3)!),
              );
            } else if (pattern == patterns[1]) {
              // MM/DD/YYYY format
              return DateTime(
                int.parse(match.group(3)!),
                int.parse(match.group(1)!),
                int.parse(match.group(2)!),
              );
            }
          } catch (e) {
            _logger.debug('Failed to parse date: $dateStr');
          }
        }
      }

      // Default to current time if parsing fails
      return DateTime.now();
    }
  }

  /// Search for specific cryptocurrency news
  Future<List<NewsArticle>> searchCryptoNews(String cryptocurrency) async {
    final List<NewsArticle> results = [];

    // Enhanced search URLs for specific cryptocurrencies
    final searchSources = <String, String>{
      'coindesk':
          'https://www.coindesk.com/tag/${cryptocurrency.toLowerCase()}/',
      'cointelegraph':
          'https://cointelegraph.com/tags/${cryptocurrency.toLowerCase()}',
      'cryptonews':
          'https://cryptonews.com/news/?q=${cryptocurrency.toLowerCase()}',
    };

    for (final entry in searchSources.entries) {
      try {
        final source = entry.key;
        final url = entry.value;

        final sourceConfig = Map<String, String>.from(_newsSources[source]!);
        sourceConfig['url'] = url;

        final response = await http
            .get(
              Uri.parse(url),
              headers: _headers,
            )
            .timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final document = html_parser.parse(response.body);
          final articles = <NewsArticle>[];

          final titleElements =
              document.querySelectorAll(sourceConfig['titleSelector']!);
          final linkElements =
              document.querySelectorAll(sourceConfig['linkSelector']!);

          final maxElements = [titleElements.length, linkElements.length]
              .reduce((a, b) => a < b ? a : b);
          final articlesCount = maxElements > 5 ? 5 : maxElements;

          for (int i = 0; i < articlesCount; i++) {
            try {
              final title = _extractText(titleElements, i);
              final link =
                  _extractLink(linkElements, i, sourceConfig['baseUrl']!);

              if (title.isNotEmpty && link.isNotEmpty) {
                articles.add(NewsArticle(
                  title: title,
                  summary: '',
                  url: link,
                  source: source,
                  publishedAt: DateTime.now(),
                  imageUrl: '',
                ));
              }
            } catch (e) {
              _logger
                  .debug('Failed to parse search result $i from $source: $e');
            }
          }

          results.addAll(articles);
        }

        // Delay between requests
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        _logger.error(
            'Failed to search $cryptocurrency news from ${entry.key}: $e');
      }
    }

    _logger.info('Found ${results.length} articles for $cryptocurrency');
    return results;
  }

  /// Get trending cryptocurrency topics
  Future<List<String>> getTrendingTopics() async {
    try {
      // This would typically scrape trending topics from crypto news sites
      // For now, return common trending topics
      return [
        'Bitcoin',
        'Ethereum',
        'DeFi',
        'NFT',
        'Blockchain',
        'Cryptocurrency',
        'Altcoin',
        'Trading',
        'Investment',
        'Market Analysis'
      ];
    } catch (e) {
      _logger.error('Failed to get trending topics: $e');
      return [];
    }
  }

  /// Validate if a URL is accessible
  Future<bool> validateNewsSource(String url) async {
    try {
      final response = await http
          .head(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      _logger.error('Failed to validate news source $url: $e');
      return false;
    }
  }
}

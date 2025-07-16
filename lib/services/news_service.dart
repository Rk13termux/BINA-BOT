
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import '../../models/news_article.dart';
import '../../utils/logger.dart';

class NewsService {
  final AppLogger _logger = AppLogger();
  static const String _sourceUrl = 'https://www.coindesk.com'; // Fuente de noticias como ejemplo

  Future<List<NewsArticle>> fetchNews() async {
    _logger.info('Fetching news from $_sourceUrl');
    try {
      final response = await http.get(Uri.parse(_sourceUrl));

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        // Esta es la parte "frágil". El selector CSS depende de la estructura de la web.
        // Si Coindesk cambia su web, esto dejará de funcionar.
        final elements = document.querySelectorAll('a[href*="/markets/"]');

        if (elements.isEmpty) {
          _logger.warning('No news articles found. The website structure might have changed.');
          return [];
        }

        List<NewsArticle> articles = [];
        for (var element in elements) {
          final title = element.text.trim();
          final url = element.attributes['href'];

          if (title.isNotEmpty && url != null) {
            articles.add(NewsArticle(
              title: title,
              url: '$_sourceUrl$url',
              source: 'CoinDesk',
              publishedAt: DateTime.now(), // El scraping no siempre permite obtener la fecha
              summary: '', // Añadido para cumplir con el modelo
            ));
          }
        }
        _logger.info('Successfully fetched ${articles.length} articles.');
        return articles;
      } else {
        _logger.error('Failed to load news. Status code: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      _logger.error('An error occurred while fetching news: $e');
      return [];
    }
  }
}

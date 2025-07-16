import 'package:flutter/material.dart';
import '../../models/news_article.dart';
import '../../services/news_service.dart';
import '../../utils/logger.dart';

class NewsController extends ChangeNotifier {
  final AppLogger _logger = AppLogger();
  final NewsService _newsService = NewsService();

  // State
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NewsController() {
    loadNews();
  }

  /// Load all news from the source
  Future<void> loadNews({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _setLoading(true);
    _clearError();

    try {
      _logger.info('Loading news articles using NewsService...');
      
      _articles = await _newsService.fetchNews();

      _logger.info('Loaded ${_articles.length} news articles');
    } catch (e) {
      _setError('Failed to load news: $e');
      _logger.error('Failed to load news: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error state
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error state
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}

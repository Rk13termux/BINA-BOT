import 'package:flutter/material.dart';
import '../../models/news_article.dart';
import '../../services/scraping_service.dart';
import '../../utils/logger.dart';

class NewsController extends ChangeNotifier {
  static final AppLogger _logger = AppLogger();
  final ScrapingService _scrapingService = ScrapingService();

  // State
  List<NewsArticle> _allArticles = [];
  List<NewsArticle> _filteredArticles = [];
  List<String> _trendingTopics = [];
  final List<String> _searchHistory = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSource = 'All';
  String _sortBy = 'date'; // date, relevance, source

  // Categories
  final List<String> _categories = [
    'All',
    'Bitcoin',
    'Ethereum',
    'DeFi',
    'NFT',
    'Trading',
    'Regulation',
    'Technology',
    'Market',
  ];

  // News sources
  final List<String> _sources = [
    'All',
    'coindesk',
    'cointelegraph',
    'cryptonews',
  ];

  // Getters
  List<NewsArticle> get articles => _filteredArticles;
  List<NewsArticle> get allArticles => _allArticles;
  List<String> get trendingTopics => _trendingTopics;
  List<String> get searchHistory => _searchHistory;
  List<String> get categories => _categories;
  List<String> get sources => _sources;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedSource => _selectedSource;
  String get sortBy => _sortBy;

  /// Load all news from sources
  Future<void> loadNews({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    _setLoading(true);
    _clearError();

    try {
      _logger.info('Loading news articles...');

      // Load articles and trending topics in parallel
      final futures = await Future.wait([
        _scrapingService.scrapeAllNews(maxArticlesPerSource: 10),
        _scrapingService.getTrendingTopics(),
      ]);

      _allArticles = futures[0] as List<NewsArticle>;
      _trendingTopics = futures[1] as List<String>;

      _applyFilters();
      _logger.info('Loaded ${_allArticles.length} news articles');
    } catch (e) {
      _setError('Failed to load news: $e');
      _logger.error('Failed to load news: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Search for specific news
  Future<void> searchNews(String query) async {
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }

    _setSearching(true);
    _searchQuery = query.trim();

    // Add to search history
    if (!_searchHistory.contains(_searchQuery)) {
      _searchHistory.insert(0, _searchQuery);
      if (_searchHistory.length > 10) {
        _searchHistory.removeLast();
      }
    }

    try {
      _logger.info('Searching news for: $_searchQuery');

      // Search in existing articles first
      final localResults = _allArticles.where((article) {
        return article.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            article.summary
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            article.tags.any((tag) =>
                tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();

      // If we have good local results, use them
      if (localResults.length >= 5) {
        _filteredArticles = localResults;
        _applySorting();
        notifyListeners();
        _setSearching(false);
        return;
      }

      // Otherwise, search online
      final searchResults =
          await _scrapingService.searchCryptoNews(_searchQuery);

      // Merge with local results and remove duplicates
      final allResults = <NewsArticle>[...localResults, ...searchResults];
      final uniqueResults = <NewsArticle>[];
      final seenUrls = <String>{};

      for (final article in allResults) {
        if (!seenUrls.contains(article.url)) {
          seenUrls.add(article.url);
          uniqueResults.add(article);
        }
      }

      _filteredArticles = uniqueResults;
      _applySorting();

      _logger.info('Found ${_filteredArticles.length} search results');
    } catch (e) {
      _setError('Failed to search news: $e');
      _logger.error('Failed to search news: $e');
    } finally {
      _setSearching(false);
    }
  }

  /// Clear search and show all articles
  void clearSearch() {
    _clearSearch();
    _applyFilters();
  }

  /// Set category filter
  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  /// Set source filter
  void setSource(String source) {
    _selectedSource = source;
    _applyFilters();
  }

  /// Set sorting method
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    _applySorting();
    notifyListeners();
  }

  /// Get articles by category
  Future<List<NewsArticle>> getArticlesByCategory(String category) async {
    try {
      final results = await _scrapingService.searchCryptoNews(category);
      return results;
    } catch (e) {
      _logger.error('Failed to get articles by category $category: $e');
      return [];
    }
  }

  /// Refresh trending topics
  Future<void> refreshTrendingTopics() async {
    try {
      _trendingTopics = await _scrapingService.getTrendingTopics();
      notifyListeners();
    } catch (e) {
      _logger.error('Failed to refresh trending topics: $e');
    }
  }

  /// Get article by URL (for detailed view)
  NewsArticle? getArticleByUrl(String url) {
    try {
      return _allArticles.firstWhere((article) => article.url == url);
    } catch (e) {
      return null;
    }
  }

  /// Mark article as read
  void markAsRead(String url) {
    final index = _allArticles.indexWhere((article) => article.url == url);
    if (index != -1) {
      // In a real app, this would update the read status in local storage
      _logger.debug('Marked article as read: $url');
    }
  }

  /// Share article
  void shareArticle(NewsArticle article) {
    // In a real app, this would use the share package
    _logger.info('Sharing article: ${article.title}');
  }

  /// Bookmark article
  void bookmarkArticle(NewsArticle article) {
    // In a real app, this would save to local storage
    _logger.info('Bookmarked article: ${article.title}');
  }

  /// Get articles from specific time period
  List<NewsArticle> getArticlesFromPeriod(Duration period) {
    final cutoff = DateTime.now().subtract(period);
    return _allArticles
        .where((article) => article.publishedAt.isAfter(cutoff))
        .toList();
  }

  /// Apply filters to articles
  void _applyFilters() {
    _filteredArticles = _allArticles.where((article) {
      // Category filter
      if (_selectedCategory != 'All') {
        final categoryMatch = article.title
                .toLowerCase()
                .contains(_selectedCategory.toLowerCase()) ||
            article.summary
                .toLowerCase()
                .contains(_selectedCategory.toLowerCase()) ||
            article.tags.any((tag) =>
                tag.toLowerCase().contains(_selectedCategory.toLowerCase()));
        if (!categoryMatch) return false;
      }

      // Source filter
      if (_selectedSource != 'All' && article.source != _selectedSource) {
        return false;
      }

      return true;
    }).toList();

    _applySorting();
    notifyListeners();
  }

  /// Apply sorting to filtered articles
  void _applySorting() {
    switch (_sortBy) {
      case 'date':
        _filteredArticles
            .sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        break;
      case 'source':
        _filteredArticles.sort((a, b) => a.source.compareTo(b.source));
        break;
      case 'title':
        _filteredArticles.sort((a, b) => a.title.compareTo(b.title));
        break;
      default:
        _filteredArticles
            .sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    }
  }

  /// Clear search state
  void _clearSearch() {
    _searchQuery = '';
    _isSearching = false;
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set searching state
  void _setSearching(bool searching) {
    _isSearching = searching;
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

  /// Clear search history
  void clearSearchHistory() {
    _searchHistory.clear();
    notifyListeners();
  }

  /// Remove item from search history
  void removeFromSearchHistory(String query) {
    _searchHistory.remove(query);
    notifyListeners();
  }
}

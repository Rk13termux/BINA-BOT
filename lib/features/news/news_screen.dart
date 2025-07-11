import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../ui/theme/colors.dart';
import '../../models/news_article.dart';
import '../../services/auth_service.dart';
import '../../services/subscription_service.dart';
import 'news_controller.dart';
import 'news_detail_screen.dart';
import 'bookmarks_screen.dart';
import 'search_history_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsController>().loadNews();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilters(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewsTab(),
                _buildTrendingTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      title: Text(
        'Crypto News',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        Consumer<NewsController>(
          builder: (context, newsController, child) {
            return IconButton(
              icon: Icon(
                _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                color: _showFilters ? AppColors.goldPrimary : AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            );
          },
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
          color: AppColors.surfaceDark,
          onSelected: (value) {
            switch (value) {
              case 'bookmarks':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BookmarksScreen(),
                  ),
                );
                break;
              case 'search_history':
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SearchHistoryScreen(),
                  ),
                );
                break;
              case 'refresh':
                context.read<NewsController>().loadNews(refresh: true);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'bookmarks',
              child: Row(
                children: [
                  Icon(Icons.bookmark, color: AppColors.goldPrimary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Bookmarks',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'search_history',
              child: Row(
                children: [
                  Icon(Icons.history, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Search History',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: AppColors.goldPrimary, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Refresh',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Consumer<NewsController>(
        builder: (context, newsController, child) {
          return TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search crypto news...',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (newsController.searchHistory.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.history, color: AppColors.textSecondary),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SearchHistoryScreen(),
                          ),
                        );
                      },
                      tooltip: 'Search History',
                    ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        newsController.clearSearch();
                      },
                    )
                  else if (newsController.isSearching)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            onSubmitted: (query) {
              if (query.isNotEmpty) {
                newsController.searchNews(query);
              }
            },
            onChanged: (query) {
              if (query.isEmpty) {
                newsController.clearSearch();
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<NewsController>(
        builder: (context, newsController, child) {
          return Column(
            children: [
              // Category Filter
              Row(
                children: [
                  Text(
                    'Category:',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: newsController.categories.map((category) {
                          final isSelected = newsController.selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                newsController.setCategory(category);
                              },
                              selectedColor: AppColors.goldPrimary,
                              backgroundColor: AppColors.surfaceDark,
                              labelStyle: TextStyle(
                                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Source and Sort Filter
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Source:',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: newsController.selectedSource,
                            dropdownColor: AppColors.surfaceDark,
                            style: TextStyle(color: AppColors.textPrimary),
                            onChanged: (source) {
                              if (source != null) {
                                newsController.setSource(source);
                              }
                            },
                            items: newsController.sources.map((source) {
                              return DropdownMenuItem(
                                value: source,
                                child: Text(source),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Sort:',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            value: newsController.sortBy,
                            dropdownColor: AppColors.surfaceDark,
                            style: TextStyle(color: AppColors.textPrimary),
                            onChanged: (sortBy) {
                              if (sortBy != null) {
                                newsController.setSortBy(sortBy);
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'date', child: Text('Date')),
                              DropdownMenuItem(value: 'source', child: Text('Source')),
                              DropdownMenuItem(value: 'title', child: Text('Title')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Consumer<NewsController>(
      builder: (context, newsController, child) {
        return TabBar(
          controller: _tabController,
          indicatorColor: AppColors.goldPrimary,
          labelColor: AppColors.goldPrimary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'News (${newsController.articles.length})'),
            Tab(text: 'Trending (${newsController.trendingTopics.length})'),
            Tab(text: 'Categories'),
          ],
        );
      },
    );
  }

  Widget _buildNewsTab() {
    return Column(
      children: [
        // Ad banner for free users
        Consumer<AuthService>(
          builder: (context, auth, child) {
            final user = auth.currentUser;
            if (user?.subscriptionTier == 'free') {
              return Consumer<SubscriptionService>(
                builder: (context, subscription, child) {
                  if (subscription.isBannerAdReady && subscription.bannerAd != null) {
                    return Container(
                      margin: const EdgeInsets.all(16),
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AdWidget(ad: subscription.bannerAd!),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        
        Expanded(
          child: Consumer<NewsController>(
            builder: (context, newsController, child) {
              return _buildNewsContent(newsController);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsContent(NewsController newsController) {
    if (newsController.isLoading && newsController.articles.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrimary),
      );
    }

    if (newsController.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.bearish,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load news',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              newsController.error!,
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => newsController.loadNews(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrimary,
                foregroundColor: AppColors.primaryDark,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (newsController.articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              newsController.searchQuery.isNotEmpty ? 'No search results' : 'No news available',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              newsController.searchQuery.isNotEmpty 
                  ? 'Try a different search term'
                  : 'Pull to refresh for latest updates',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => newsController.loadNews(refresh: true),
      color: AppColors.goldPrimary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: newsController.articles.length,
        itemBuilder: (context, index) {
          final article = newsController.articles[index];
          return _buildNewsCard(article, newsController);
        },
      ),
    );
  }

  Widget _buildTrendingTab() {
    return Consumer<NewsController>(
      builder: (context, newsController, child) {
        if (newsController.isLoading && newsController.trendingTopics.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.goldPrimary),
          );
        }

        if (newsController.trendingTopics.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 64,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No trending topics',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for trending updates',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => newsController.refreshTrendingTopics(),
          color: AppColors.goldPrimary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: newsController.trendingTopics.length,
            itemBuilder: (context, index) {
              final topic = newsController.trendingTopics[index];
              return _buildTrendingCard(topic, index + 1, newsController);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return Consumer<NewsController>(
      builder: (context, newsController, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: newsController.categories.where((cat) => cat != 'All').length,
          itemBuilder: (context, index) {
            final categories = newsController.categories.where((cat) => cat != 'All').toList();
            final category = categories[index];
            return _buildCategoryCard(category, newsController);
          },
        );
      },
    );
  }

  Widget _buildNewsCard(NewsArticle article, NewsController newsController) {
    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openArticle(article, newsController),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      article.source.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatTime(article.publishedAt),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (article.summary.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  article.summary,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (article.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: article.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.remove_red_eye,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Read more',
                    style: TextStyle(
                      color: AppColors.goldPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _shareArticle(article, newsController),
                    icon: Icon(
                      Icons.share,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _bookmarkArticle(article, newsController),
                    icon: Icon(
                      Icons.bookmark_border,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingCard(String topic, int rank, NewsController newsController) {
    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _searchController.text = topic;
          newsController.searchNews(topic);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getRankColor(rank),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$rank',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  topic,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.trending_up,
                color: AppColors.bullish,
                size: 20,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.search,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String category, NewsController newsController) {
    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          newsController.setCategory(category);
          _tabController.animateTo(0); // Switch to news tab
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _getCategoryIcon(category),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Explore $category news',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    IconData iconData;
    Color color = AppColors.goldPrimary;

    switch (category.toLowerCase()) {
      case 'bitcoin':
        iconData = Icons.currency_bitcoin;
        color = Colors.orange;
        break;
      case 'ethereum':
        iconData = Icons.hexagon;
        color = Colors.blue;
        break;
      case 'defi':
        iconData = Icons.account_balance;
        break;
      case 'nft':
        iconData = Icons.image;
        break;
      case 'trading':
        iconData = Icons.show_chart;
        break;
      case 'regulation':
        iconData = Icons.gavel;
        break;
      case 'technology':
        iconData = Icons.computer;
        break;
      case 'market':
        iconData = Icons.trending_up;
        break;
      default:
        iconData = Icons.article;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return AppColors.goldPrimary;
    if (rank <= 5) return AppColors.warning;
    return AppColors.textSecondary;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _openArticle(NewsArticle article, NewsController newsController) async {
    newsController.markAsRead(article.url);
    
    // Navigate to detail screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(article: article),
      ),
    );
  }

  void _shareArticle(NewsArticle article, NewsController newsController) {
    newsController.shareArticle(article);
    _showMessage('Sharing: ${article.title}');
  }

  void _bookmarkArticle(NewsArticle article, NewsController newsController) {
    newsController.bookmarkArticle(article);
    _showMessage('Bookmarked: ${article.title}');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.info,
      ),
    );
  }
}

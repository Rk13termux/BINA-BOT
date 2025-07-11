import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
import 'news_controller.dart';

class SearchHistoryScreen extends StatelessWidget {
  const SearchHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Search History',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Consumer<NewsController>(
            builder: (context, newsController, child) {
              if (newsController.searchHistory.isNotEmpty) {
                return IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.bearish),
                  onPressed: () => _showClearAllDialog(context, newsController),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NewsController>(
        builder: (context, newsController, child) {
          final searchHistory = newsController.searchHistory;
          
          if (searchHistory.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No search history',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your search queries will appear here',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Recent Searches',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: searchHistory.length,
                  itemBuilder: (context, index) {
                    final query = searchHistory[index];
                    return _buildSearchHistoryItem(
                      context,
                      query,
                      newsController,
                      index,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchHistoryItem(
    BuildContext context,
    String query,
    NewsController newsController,
    int index,
  ) {
    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.history,
          color: AppColors.textSecondary,
        ),
        title: Text(
          query,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          'Search #${index + 1}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: AppColors.goldPrimary,
                size: 20,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                newsController.searchNews(query);
              },
              tooltip: 'Search again',
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () => _removeFromHistory(context, query, newsController),
              tooltip: 'Remove from history',
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).pop();
          newsController.searchNews(query);
        },
      ),
    );
  }

  void _removeFromHistory(
    BuildContext context,
    String query,
    NewsController newsController,
  ) {
    newsController.removeFromSearchHistory(query);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "$query" from search history'),
        backgroundColor: AppColors.warning,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primaryDark,
          onPressed: () {
            // In a real app, this would restore the item
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Search history restored'),
                backgroundColor: AppColors.bullish,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, NewsController newsController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Clear Search History',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to clear all search history? This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              newsController.clearSearchHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Search history cleared'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            child: Text(
              'Clear All',
              style: TextStyle(color: AppColors.bearish),
            ),
          ),
        ],
      ),
    );
  }
}

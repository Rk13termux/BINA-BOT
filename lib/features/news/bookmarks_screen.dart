import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
import '../../models/news_article.dart';
import 'news_controller.dart';
import 'news_detail_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: Text(
          'Bookmarked Articles',
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
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.bearish),
            onPressed: () => _showClearAllDialog(context),
          ),
        ],
      ),
      body: Consumer<NewsController>(
        builder: (context, newsController, child) {
          // In a real app, this would get bookmarked articles from local storage
          final bookmarkedArticles = _getBookmarkedArticles(newsController);
          
          if (bookmarkedArticles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarked articles',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bookmark articles to read them later',
                    style: TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookmarkedArticles.length,
            itemBuilder: (context, index) {
              final article = bookmarkedArticles[index];
              return _buildBookmarkedArticleCard(context, article, newsController);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookmarkedArticleCard(
    BuildContext context,
    NewsArticle article,
    NewsController newsController,
  ) {
    return Card(
      color: AppColors.surfaceDark,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(article: article),
            ),
          );
        },
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
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _removeBookmark(context, article, newsController),
                    icon: Icon(
                      Icons.bookmark,
                      color: AppColors.goldPrimary,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
                  maxLines: 2,
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
            ],
          ),
        ),
      ),
    );
  }

  List<NewsArticle> _getBookmarkedArticles(NewsController newsController) {
    // In a real app, this would retrieve bookmarked articles from local storage
    // For demo purposes, return some sample articles
    return newsController.allArticles.take(3).toList();
  }

  void _removeBookmark(
    BuildContext context,
    NewsArticle article,
    NewsController newsController,
  ) {
    // In a real app, this would remove the bookmark from local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed bookmark: ${article.title}'),
        backgroundColor: AppColors.warning,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primaryDark,
          onPressed: () {
            // Restore bookmark
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Bookmark restored'),
                backgroundColor: AppColors.bullish,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          'Clear All Bookmarks',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to remove all bookmarked articles? This action cannot be undone.',
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
              _clearAllBookmarks(context);
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

  void _clearAllBookmarks(BuildContext context) {
    // In a real app, this would clear all bookmarks from local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All bookmarks cleared'),
        backgroundColor: AppColors.warning,
      ),
    );
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
}

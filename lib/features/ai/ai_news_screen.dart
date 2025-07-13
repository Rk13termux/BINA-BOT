import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui/theme/colors.dart';
import 'ai_news_controller.dart';
import 'crypto_detail_screen.dart';

class AINewsScreen extends StatefulWidget {
  const AINewsScreen({super.key});

  @override
  State<AINewsScreen> createState() => _AINewsScreenState();
}

class _AINewsScreenState extends State<AINewsScreen> {
  final TextEditingController _cryptoSearchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Bitcoin',
    'Ethereum',
    'Market Analysis',
    'Regulations',
    'DeFi',
  ];

  final List<String> _popularCryptos = [
    'BITCOIN',
    'ETHEREUM',
    'BINANCE',
    'CARDANO',
    'SOLANA',
    'POLYGON',
    'AVALANCHE',
    'CHAINLINK',
  ];

  @override
  void dispose() {
    _cryptoSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: Text(
          'AI Crypto News',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.goldPrimary),
            onPressed: () {
              context.read<AINewsController>().refreshNews();
            },
          ),
        ],
      ),
      body: Consumer<AINewsController>(
        builder: (context, aiNews, child) {
          if (aiNews.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.goldPrimary,
              ),
            );
          }

          return Column(
            children: [
              // Search and Analysis Section
              _buildSearchSection(context, aiNews),
              
              // Category Filter
              _buildCategoryFilter(),
              
              // AI Analysis Summary
              _buildAIAnalysisSummary(aiNews),
              
              // News List
              Expanded(
                child: _buildNewsList(aiNews),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, AINewsController aiNews) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Crypto Search Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.goldPrimary, width: 1),
            ),
            child: TextField(
              controller: _cryptoSearchController,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar criptomoneda para análisis...',
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.goldPrimary),
                suffixIcon: IconButton(
                  icon: Icon(Icons.analytics, color: AppColors.goldPrimary),
                  onPressed: () => _analyzeCrypto(context),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) => _analyzeCrypto(context),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Popular Cryptos
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _popularCryptos.length,
              itemBuilder: (context, index) {
                final crypto = _popularCryptos[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _selectCrypto(context, crypto),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: aiNews.selectedCrypto == crypto
                            ? AppColors.goldPrimary
                            : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.goldPrimary,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        crypto,
                        style: TextStyle(
                          color: aiNews.selectedCrypto == crypto
                              ? AppColors.primaryDark
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.goldPrimary
                      : AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.goldPrimary,
                    width: 1,
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAIAnalysisSummary(AINewsController aiNews) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldPrimary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.psychology, color: AppColors.goldPrimary),
              const SizedBox(width: 8),
              Text(
                'AI Market Insights',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: aiNews.aiAnalysis.length,
              itemBuilder: (context, index) {
                final analysis = aiNews.aiAnalysis[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.goldPrimary, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analysis['title'],
                        style: TextStyle(
                          color: AppColors.goldPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        analysis['description'],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (analysis['confidence'] != null)
                        Text(
                          'Confidence: ${analysis['confidence']}%',
                          style: TextStyle(
                            color: AppColors.bullish,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(AINewsController aiNews) {
    var news = aiNews.cryptoNews;
    
    if (_selectedCategory != 'All') {
      news = aiNews.getNewsByCategory(_selectedCategory);
    }

    if (news.isEmpty) {
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
              'No hay noticias disponibles',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: news.length,
      itemBuilder: (context, index) {
        final article = news[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.goldPrimary, width: 0.5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              article.title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  article.content,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getSentimentColor(article.sentiment),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        article.sentiment,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      article.source,
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.goldPrimary,
              size: 16,
            ),
            onTap: () {
              // Abrir detalle de la noticia
              _showNewsDetail(context, article);
            },
          ),
        );
      },
    );
  }

  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return AppColors.bullish;
      case 'negative':
        return AppColors.bearish;
      case 'neutral':
      default:
        return AppColors.neutral;
    }
  }

  void _analyzeCrypto(BuildContext context) {
    final crypto = _cryptoSearchController.text.trim().toUpperCase();
    if (crypto.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CryptoDetailScreen(cryptoSymbol: crypto),
        ),
      );
    }
  }

  void _selectCrypto(BuildContext context, String crypto) {
    context.read<AINewsController>().setSelectedCrypto(crypto);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CryptoDetailScreen(cryptoSymbol: crypto),
      ),
    );
  }

  void _showNewsDetail(BuildContext context, article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(
          article.title,
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          article.content,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cerrar',
              style: TextStyle(color: AppColors.goldPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

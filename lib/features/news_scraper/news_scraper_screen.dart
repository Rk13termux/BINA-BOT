import 'package:flutter/material.dart';

class NewsScraperScreen extends StatefulWidget {
  const NewsScraperScreen({Key? key}) : super(key: key);

  @override
  State<NewsScraperScreen> createState() => _NewsScraperScreenState();
}

class _NewsScraperScreenState extends State<NewsScraperScreen> {
  List<NewsHeadline> _headlines = [
    NewsHeadline(
        title: 'Bitcoin alcanza nuevo máximo anual',
        source: 'Cointelegraph',
        sentiment: 'bullish'),
    NewsHeadline(
        title: 'SEC retrasa decisión sobre ETF de Ethereum',
        source: 'CryptoPanic',
        sentiment: 'bearish'),
    NewsHeadline(
        title: 'El Salvador anuncia bonos Bitcoin',
        source: 'Decrypt',
        sentiment: 'bullish'),
  ];

  bool _isLoading = false;

  Future<void> _fetchNews() async {
    setState(() {
      _isLoading = true;
    });
    // Aquí iría la lógica real de scraping y análisis AI
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  Color _sentimentColor(String sentiment) {
    switch (sentiment) {
      case 'bullish':
        return Colors.greenAccent;
      case 'bearish':
        return Colors.redAccent;
      default:
        return Colors.amber;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Scraper'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _fetchNews,
            tooltip: 'Actualizar noticias',
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _headlines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final news = _headlines[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _sentimentColor(news.sentiment), width: 2),
                  ),
                  child: ListTile(
                    leading: Icon(
                      news.sentiment == 'bullish'
                          ? Icons.trending_up
                          : news.sentiment == 'bearish'
                              ? Icons.trending_down
                              : Icons.info_outline,
                      color: _sentimentColor(news.sentiment),
                    ),
                    title: Text(news.title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(news.source,
                        style: const TextStyle(color: Colors.white70)),
                    trailing: Text(news.sentiment.toUpperCase(),
                        style: TextStyle(
                            color: _sentimentColor(news.sentiment),
                            fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.bolt, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Impacto reciente:',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _headlines.isNotEmpty
                    ? _headlines.first.title
                    : 'Sin noticias relevantes',
                style: const TextStyle(
                    color: Colors.amber, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsHeadline {
  final String title;
  final String source;
  final String sentiment;
  NewsHeadline(
      {required this.title, required this.source, required this.sentiment});
}

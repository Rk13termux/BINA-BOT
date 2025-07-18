import 'package:flutter/material.dart';
import '../../../ui/theme/quantix_theme.dart';

/// 📰 Widget de Feed de Noticias - QUANTIX AI CORE
/// Scraping de noticias crypto sin APIs externas
class NewsFeedWidget extends StatefulWidget {
  const NewsFeedWidget({super.key});

  @override
  State<NewsFeedWidget> createState() => _NewsFeedWidgetState();
}

class _NewsFeedWidgetState extends State<NewsFeedWidget> {
  // Noticias simuladas (en producción vendrían del scraper)
  final List<Map<String, dynamic>> _news = [
    {
      'title': 'Bitcoin alcanza nuevo máximo histórico en adopción institucional',
      'source': 'CoinDesk',
      'time': '2h',
      'sentiment': 'positive',
      'impact': 'high',
      'summary': 'Grandes corporaciones continúan añadiendo BTC a sus reservas',
    },
    {
      'title': 'Ethereum 2.0 supera expectativas en eficiencia energética',
      'source': 'CoinTelegraph',
      'time': '4h',
      'sentiment': 'positive',
      'impact': 'medium',
      'summary': 'La red consume 99.95% menos energía que antes',
    },
    {
      'title': 'Regulación crypto en Europa: nuevas directrices MiCA',
      'source': 'CryptoNews',
      'time': '6h',
      'sentiment': 'neutral',
      'impact': 'high',
      'summary': 'Marco regulatorio clarifica el futuro de las criptomonedas',
    },
    {
      'title': 'Mercado DeFi experimenta corrección tras rally',
      'source': 'The Block',
      'time': '8h',
      'sentiment': 'negative',
      'impact': 'medium',
      'summary': 'Tokens DeFi caen 15% en promedio tras subidas',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: QuantixTheme.eliteCardDecoration,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  QuantixTheme.neutralGray.withOpacity(0.8),
                  QuantixTheme.cardBlack,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.article,
                  color: QuantixTheme.lightGold,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'News Feed Crypto',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: QuantixTheme.lightGold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: QuantixTheme.bullishGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'LIVE',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: QuantixTheme.primaryBlack,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Lista de noticias
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _news.map((article) => _buildNewsCard(article)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Card de noticia individual
  Widget _buildNewsCard(Map<String, dynamic> article) {
    final Color sentimentColor = _getSentimentColor(article['sentiment']);
    final Color impactColor = _getImpactColor(article['impact']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: QuantixTheme.cardBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: sentimentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con fuente y tiempo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                article['source'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: QuantixTheme.electricBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  // Indicador de impacto
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: impactColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    article['time'],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: QuantixTheme.neutralGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Título
          Text(
            article['title'],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: QuantixTheme.lightGold,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Resumen
          Text(
            article['summary'],
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: QuantixTheme.neutralGray,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Footer con sentimiento e impacto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Sentimiento
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: sentimentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  article['sentiment'].toString().toUpperCase(),
                  style: const TextStyle(
                    color: QuantixTheme.primaryBlack,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              
              // Impacto
              Text(
                'Impacto: ${article['impact'].toString().toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: impactColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Obtener color del sentimiento
  Color _getSentimentColor(String sentiment) {
    switch (sentiment.toLowerCase()) {
      case 'positive':
        return QuantixTheme.bullishGreen;
      case 'negative':
        return QuantixTheme.bearishRed;
      case 'neutral':
        return QuantixTheme.neutralGray;
      default:
        return QuantixTheme.neutralGray;
    }
  }

  /// Obtener color del impacto
  Color _getImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'high':
        return QuantixTheme.bearishRed;
      case 'medium':
        return QuantixTheme.hold;
      case 'low':
        return QuantixTheme.bullishGreen;
      default:
        return QuantixTheme.neutralGray;
    }
  }
}

import 'package:flutter/material.dart';
import '../../../services/binance_service.dart';

/// Selector de pares de Binance con búsqueda y selección
class BinancePairsSelector extends StatefulWidget {
  final Function(String) onPairSelected;
  const BinancePairsSelector({super.key, required this.onPairSelected});

  @override
  State<BinancePairsSelector> createState() => _BinancePairsSelectorState();
}

class _BinancePairsSelectorState extends State<BinancePairsSelector> {
  List<String> _pairs = [];
  List<String> _filteredPairs = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fetchPairs();
  }

  Future<void> _fetchPairs() async {
    setState(() => _loading = true);
    try {
      final binance = BinanceService();
      final pairsData = await binance.getTradingPairs();
      setState(() {
        _pairs = pairsData.map((e) => e['symbol'] as String).toList();
        _filteredPairs = _pairs;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _onSearch(String value) {
    setState(() {
      _search = value;
      _filteredPairs = _pairs.where((p) => p.toLowerCase().contains(_search.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar par (ej: BTCUSDT)',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: _onSearch,
        ),
        const SizedBox(height: 10),
        _loading
            ? const Center(child: CircularProgressIndicator())
            : Expanded(
                child: ListView.builder(
                  itemCount: _filteredPairs.length,
                  itemBuilder: (context, i) {
                    final pair = _filteredPairs[i];
                    return ListTile(
                      title: Text(pair, style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () => widget.onPairSelected(pair),
                    );
                  },
                ),
              ),
      ],
    );
  }
}

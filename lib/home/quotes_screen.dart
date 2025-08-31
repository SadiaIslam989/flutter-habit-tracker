import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../quotes/quotes_provider.dart';
import 'favorites_quotes_screen.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  Future<void> _loadQuotes() async {
    await context.read<QuotesProvider>().loadQuotes();
  }

  final List<Color> bgColors = [
    Colors.deepPurple,
    Colors.pinkAccent,
    Colors.lightBlue,
  ]; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Quotes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              _loadQuotes();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshing quotes...'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Refresh Quotes',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromRGBO(156, 39, 176, 1), 
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FavoritesQuotesScreen(),
            ),
          );
        },
        icon: const Icon(Icons.favorite_rounded, color: Colors.white),
        label: const Text(
          'Favorites',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadQuotes,
        child: Consumer<QuotesProvider>(
          builder: (context, quotesProvider, child) {
            if (quotesProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (quotesProvider.quotes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.format_quote,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Pull to refresh for new quotes',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromRGBO(156, 39, 176, 1),
                      ),
                      onPressed: _loadQuotes,
                      child: const Text('Load Quotes'),
                    ),
                  ],
                ),
              );
            }

            return PageView.builder(
              itemCount: quotesProvider.quotes.length,
              controller: PageController(viewportFraction: 0.9),
              itemBuilder: (context, index) {
                final quote = quotesProvider.quotes[index];
                final color = bgColors[index % bgColors.length];

                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.format_quote,
                              size: 40, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            quote.content,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "- ${quote.author}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(156, 39, 176, 1),
                            ),
                            onPressed: () async {
                              await context
                                  .read<QuotesProvider>()
                                  .addFavorite(quote);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to favorites!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.favorite_rounded),
                            label: const Text('Add to Favorites'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

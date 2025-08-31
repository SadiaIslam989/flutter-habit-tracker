import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for Clipboard
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../quotes/quotes_provider.dart';
import '../quotes/quote_model.dart';

class FavoritesQuotesScreen extends StatefulWidget {
  const FavoritesQuotesScreen({super.key});

  @override
  State<FavoritesQuotesScreen> createState() => _FavoritesQuotesScreenState();
}

class _FavoritesQuotesScreenState extends State<FavoritesQuotesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Color> bgColors = [
    Colors.deepPurple,
    Colors.pinkAccent,
    Colors.lightBlue,
  ]; // cycle colors for cards

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Quotes',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<QuotesProvider>(
        builder: (context, quotesProvider, child) {
          if (quotesProvider.userId == null) {
            return const Center(child: Text('Please sign in to view favorites'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(quotesProvider.userId)
                .collection('favorites')
                .doc('quotes')
                .collection('list')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final quotes = snapshot.data!.docs
                  .map((doc) {
                    final quote = Quote.fromJson(doc.data() as Map<String, dynamic>);
                    return Quote(
                      id: doc.id,
                      content: quote.content,
                      author: quote.author,
                    );
                  })
                  .toList();

              if (quotes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 64,
                        color: Theme.of(context).primaryColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorite quotes yet',
                        style: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add quotes to your favorites from the quotes screen',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return PageView.builder(
                itemCount: quotes.length,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (context, index) {
                  final quote = quotes[index];
                  final color = bgColors[index % bgColors.length];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
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
                            ),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // COPY BUTTON
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded),
                                  onPressed: () {
                                    final textToCopy =
                                        '"${quote.content}" - ${quote.author}';
                                    Clipboard.setData(ClipboardData(text: textToCopy))
                                        .then((_) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Quote copied to clipboard'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    });
                                  },
                                  tooltip: 'Copy Quote',
                                ),
                                // DELETE BUTTON
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    try {
                                      await quotesProvider.removeFavorite(
                                          quote.id, content: quote.content);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Quote removed from favorites'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Error removing quote: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  tooltip: 'Remove from Favorites',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

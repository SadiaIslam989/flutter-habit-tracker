import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../quotes/quotes_provider.dart';
import '../quotes/quote_model.dart';

class QuoteListItem extends StatelessWidget {
  final Quote quote;
  final bool showFavoriteButton;
  final bool showRemoveButton; 
  final String? documentId; 

  const QuoteListItem({
    super.key,
    required this.quote,
    this.showFavoriteButton = true,
    this.showRemoveButton = false, 
    this.documentId, 
  });

  @override
  Widget build(BuildContext context) {
    final quotesProvider = Provider.of<QuotesProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isDark ? 2 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(isDark ? 0.2 : 0.1),
              Theme.of(context).cardColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote,
                    size: 32,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quote.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '- ${quote.author}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () async {
                          final textToCopy = '"${quote.content}" - ${quote.author}';
                          await Clipboard.setData(ClipboardData(text: textToCopy));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Quote copied to clipboard'),
                                duration: Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        tooltip: 'Copy Quote',
                      ),
                      if (showFavoriteButton) ...[
                        StreamBuilder<DocumentSnapshot>(
                          key: ObjectKey('fav_stream_${quote.id}'),
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(quotesProvider.userId)
                              .collection('favorites')
                              .doc('quotes')
                              .collection('list')
                              .where('content', isEqualTo: quote.content)
                              .where('author', isEqualTo: quote.author)
                              .limit(1)
                              .snapshots()
                              .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null)
                              .where((doc) => doc != null)
                              .cast<DocumentSnapshot>(),
                          builder: (context, snapshot) {
                            final isFavorite = snapshot.hasData && snapshot.data?.exists == true;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                    color: isFavorite ? Colors.red : null,
                                  ),
                                  onPressed: quotesProvider.isFavoriteOperationFor(quote.id)
                                      ? null
                                      : () async {
                                          try {
                                            if (isFavorite) {
                                              
                                              final docToDelete = snapshot.data!;
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(quotesProvider.userId)
                                                  .collection('favorites')
                                                  .doc('quotes')
                                                  .collection('list')
                                                  .doc(docToDelete.id)
                                                  .delete();
                                              
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Quote removed from favorites'),
                                                    duration: Duration(seconds: 2),
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              }
                                            } else {
                                              await quotesProvider.addFavorite(quote);
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Quote added to favorites'),
                                                    duration: Duration(seconds: 2),
                                                    behavior: SnackBarBehavior.floating,
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $e'),
                                                  backgroundColor: Colors.red,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                  tooltip: isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                                ),
                                if (quotesProvider.isFavoriteOperationFor(quote.id))
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                      // Added remove button section
                      if (showRemoveButton) ...[
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.delete_rounded,
                                color: Colors.red,
                              ),
                              onPressed: quotesProvider.isFavoriteOperationFor(quote.id)
                                  ? null
                                  : () async {
                                      final idToRemove = documentId ?? quote.id;
                                      print('Attempting to remove quote with doc ID: $idToRemove'); 
                                      print('User ID: ${quotesProvider.userId}'); 
                                      try {
                                        
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(quotesProvider.userId)
                                            .collection('favorites')
                                            .doc('quotes')
                                            .collection('list')
                                            .doc(idToRemove)
                                            .delete();
                                            
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Quote removed from favorites'),
                                              duration: Duration(seconds: 2),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        print('Remove favorite error: $e');
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Error removing quote: $e'),
                                              backgroundColor: Colors.red,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              tooltip: 'Remove from Favorites',
                            ),
                            if (quotesProvider.isFavoriteOperationFor(quote.id))
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
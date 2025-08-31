// quotes_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quote_model.dart';
import '../service/quotes_service.dart';

class QuotesProvider with ChangeNotifier {
  List<Quote> _quotes = [];
  bool _isLoading = false;
  String? _operatingQuoteId;
  Set<String> _favoriteQuoteContents = {}; 
  bool _favoritesLoaded = false;

  List<Quote> get quotes => _quotes;
  bool get isLoading => _isLoading;
  bool isFavoriteOperationFor(String quoteId) => _operatingQuoteId == quoteId;
  Set<String> get favoriteQuoteContents => _favoriteQuoteContents;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  
  Future<void> loadFavoriteQuotes() async {
    if (userId == null || _favoritesLoaded) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('list')
          .get();

      _favoriteQuoteContents = snapshot.docs
          .map((doc) {
            try {
              final quote = Quote.fromJson(doc.data());
              return quote.content;
            } catch (e) {
              print('Error parsing favorite quote: $e');
              return null;
            }
          })
          .where((content) => content != null)
          .cast<String>()
          .toSet();

      _favoritesLoaded = true;
      print('Loaded ${_favoriteQuoteContents.length} favorite quotes');
      notifyListeners();
    } catch (e) {
      print('Error loading favorite quotes: $e');
    }
  }

  
  bool isQuoteFavorite(Quote quote) {
    return _favoriteQuoteContents.contains(quote.content);
  }

  // Fetch quotes 
  Future<void> loadQuotes() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      
      if (!_favoritesLoaded) {
        await loadFavoriteQuotes();
      }

      final fetchedQuotes = await QuotesService.fetchQuotes(limit: 30);

      final uniqueQuotes = <Quote>[];
      final seenContents = <String>{};

      for (var quote in fetchedQuotes) {
        if (!seenContents.contains(quote.content)) {
          uniqueQuotes.add(quote);
          seenContents.add(quote.content);
        }
      }

      if (uniqueQuotes.isNotEmpty) {
        _quotes = uniqueQuotes;
      } else if (_quotes.isEmpty) {
        _quotes = await QuotesService.fetchQuotes(limit: 5);
      }
    } catch (e) {
      print("Error fetching quotes: $e");
      
      if (_quotes.isEmpty) {
        _quotes = await QuotesService.fetchQuotes(limit: 5);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add favorite to Firestore
  Future<void> addFavorite(Quote quote) async {
    if (userId == null) {
      print('Error: User not authenticated');
      throw Exception('User not authenticated');
    }
        
    _operatingQuoteId = quote.id;
    notifyListeners();

    try {
      print('Adding favorite: ${quote.id} for user: $userId');
      
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('list')
          .doc(quote.id);

      await docRef.set(quote.toMap());

      
      _favoriteQuoteContents.add(quote.content);
      
      print('Successfully added favorite: ${quote.id}');
    } catch (e) {
      print('Error adding favorite: $e');
      rethrow;
    } finally {
      _operatingQuoteId = null;
      notifyListeners();
    }
  }

  // Remove favorite from Firestore
  Future<void> removeFavorite(String quoteId, {String? content}) async {
    if (userId == null) {
      print('Error: User not authenticated');
      throw Exception('User not authenticated');
    }

    _operatingQuoteId = quoteId;
    notifyListeners();

    try {
      print('Removing favorite: $quoteId for user: $userId');
      
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('list')
          .doc(quoteId);

      await docRef.delete();
      
      if (content != null) {
        _favoriteQuoteContents.remove(content);
      }
      
      print('Successfully removed favorite: $quoteId');
      
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    } finally {
      _operatingQuoteId = null;
      notifyListeners();
  }
}

  
  Stream<List<Quote>> getFavoriteQuotes() {
    if (userId == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('quotes')
        .collection('list')
        .snapshots()
        .map((snapshot) {
          print('Favorites snapshot received: ${snapshot.docs.length} quotes');
          return snapshot.docs
              .map((doc) {
                try {
                  return Quote.fromJson(doc.data());
                } catch (e) {
                  print('Error parsing quote from document ${doc.id}: $e');
                  return null;
                }
              })
              .where((quote) => quote != null)
              .cast<Quote>()
              .toList();
        });
  }

  
  Future<void> refreshFavorites() async {
    _favoritesLoaded = false;
    await loadFavoriteQuotes();
  }
}
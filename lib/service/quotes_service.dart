import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../quotes/quote_model.dart';

class QuotesService {
  static const _fallbackQuotes = [
    {
      'id': 'default1',
      'content': 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'author': 'Winston Churchill',
      'tags': ['success', 'failure', 'courage']
    },
    {
      'id': 'default2',
      'content': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
      'tags': ['work', 'love']
    },
    {
      'id': 'default3',
      'content': 'Believe you can and you\'re halfway there.',
      'author': 'Theodore Roosevelt',
      'tags': ['believe', 'inspirational']
    },
    {
      'id': 'default4',
      'content': 'What you get by achieving your goals is not as important as what you become by achieving your goals.',
      'author': 'Zig Ziglar',
      'tags': ['goals', 'inspirational']
    },
    {
      'id': 'default5',
      'content': 'The future belongs to those who believe in the beauty of their dreams.',
      'author': 'Eleanor Roosevelt',
      'tags': ['future', 'dreams', 'inspirational']
    }
  ];

  static Future<List<Quote>> fetchQuotes({int limit = 10, List<String>? tags}) async {
    final client = http.Client();
    try {
      String url = 'https://api.quotable.io/quotes?limit=$limit';
      if (tags != null && tags.isNotEmpty) {
        url += '&tags=${tags.join(',') }';
      }
      final uri = Uri.parse(url);

      int retries = 3;
      http.Response? response;

      while (retries > 0) {
        try {
          response = await client.get(
            uri,
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'HabitTracker/1.0',
              'Cache-Control': 'no-cache',
            },
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );

          if (response.statusCode == 200) {
            break;
          }

          retries--;
          if (retries > 0) {
            await Future.delayed(Duration(seconds: 2));
          }
        } catch (e) {
          retries--;
          if (retries == 0) rethrow;
          await Future.delayed(Duration(seconds: 2));
        }
      }

      if (response == null) {
        return _getRandomFallbackQuotes();
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['results'] != null) {
          final List quotesJson = data['results'];
          final quotes = quotesJson
              .map((json) => Quote.fromJson(json))
              .toList();

          if (quotes.isNotEmpty) {
            quotes.shuffle();
            return quotes.take(limit).toList();
          }
        }
        return _getRandomFallbackQuotes();
      } else {
        print('Failed to fetch quotes: ${response.statusCode}');
        return _getRandomFallbackQuotes();
      }
    } catch (e) {
      print('Error fetching quotes: $e');
      return _getRandomFallbackQuotes();
    } finally {
      client.close();
    }
  }

  static Future<List<String>> fetchTags() async {
    final client = http.Client();
    try {
      final uri = Uri.parse('https://api.quotable.io/tags');
      final response = await client.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((tag) => tag['name'] as String).toList();
      }
      else {
        return [];
      }
    } catch (e) {
      print('Error fetching tags: $e');
      return [];
    } finally {
      client.close();
    }
  }

  static List<Quote> _getRandomFallbackQuotes() {
    final quotes = _fallbackQuotes
        .map((json) => Quote.fromJson(json))
        .toList();
    quotes.shuffle();
    return quotes.take(3).toList();
  }
}

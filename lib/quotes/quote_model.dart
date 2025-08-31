class Quote {
  final String id;
  final String content;
  final String author;

  Quote({
    required this.id,
    required this.content,
    required this.author,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['_id'] ?? DateTime.now().toIso8601String(),
      content: json['content'] ?? '',
      author: json['author'] ?? 'Unknown',
    );
  }

// Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'author': author,
    };
  }
}

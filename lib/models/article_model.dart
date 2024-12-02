class ArticleModel {
  final String title;
  final String? description; // Nullable for cases with no description
  final String url;
  final String? imageUrl; // Nullable for cases with no image
  final DateTime? publishedAt;
  final String sourceName;

  ArticleModel({
    required this.title,
    this.description,
    required this.url,
    this.imageUrl,
    this.publishedAt,
    required this.sourceName,
  });

  // Factory constructor to create an ArticleModel from Json
  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'],
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'])
          : null,
      sourceName: json['source']?['name'] ?? 'Unknown Source',
    );
  }

  // Method to convert an ArticleModel into Json
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': imageUrl,
      'publishedAt': publishedAt?.toIso8601String(),
      'source': {'name': sourceName},
    };
  }
}

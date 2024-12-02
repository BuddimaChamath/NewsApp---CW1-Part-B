import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';
import '../utils/constants.dart';

class ApiService {
  static Future<List<ArticleModel>> fetchArticles({String? category}) async {
    try {
      String url =
          '${Constants.baseUrl}/top-headlines?country=us&apiKey=${Constants.apiKey}';

      if (category != null &&
          category.isNotEmpty &&
          category.toLowerCase() != 'general') {
        url += '&category=${category.toLowerCase()}';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);

        if (responseBody.containsKey('articles') &&
            responseBody['articles'] != null) {
          final List<dynamic> data = responseBody['articles'];
          return data
              .map((json) => ArticleModel.fromJson(json))
              .where((article) =>
                  article.title.isNotEmpty &&
                  article.description != null &&
                  article.description!.isNotEmpty &&
                  !article.sourceName.toLowerCase().contains('removed'))
              .toList();
        } else {
          // No articles found
          return [];
        }
      } else {
        // Failed API call
        throw Exception(
            'Failed to load articles. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log or handle errors meaningfully
      throw Exception('Error fetching articles: $e');
    }
  }
}

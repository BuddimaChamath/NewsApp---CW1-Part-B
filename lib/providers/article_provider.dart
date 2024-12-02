import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';

class ArticleProvider with ChangeNotifier {
  List<ArticleModel> _articles = [];
  List<ArticleModel> _filteredArticles = [];
  List<ArticleModel> _bookmarkedArticles = [];
  String _selectedCategory = 'General';
  bool _isLoading = false;
  String? _error;
  String _sortBy = 'newest';

  List<ArticleModel> get articles =>
      _filteredArticles.isEmpty ? _articles : _filteredArticles;
  List<ArticleModel> get bookmarkedArticles => _bookmarkedArticles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get sortBy => _sortBy;

  ArticleProvider() {
    _loadBookmarkedArticles();
  }

  Future<void> fetchArticles({String? category}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articles = await ApiService.fetchArticles(
          category: category ?? _selectedCategory);

      _filteredArticles.clear();
      _applySorting();

      if (_articles.isEmpty) {
        _error = 'No articles found';
      }
    } catch (error) {
      _error = 'Failed to load articles. Please try again later.';
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void sortArticles(String sortBy) {
    _sortBy = sortBy;
    _applySorting();
    notifyListeners();
  }

  void _applySorting() {
    final articlesToSort =
        _filteredArticles.isEmpty ? _articles : _filteredArticles;

    switch (_sortBy) {
      case 'newest':
        articlesToSort.sort((a, b) =>
            b.publishedAt?.compareTo(a.publishedAt ?? DateTime(0)) ?? 0);
        break;
      case 'oldest':
        articlesToSort.sort((a, b) =>
            a.publishedAt?.compareTo(b.publishedAt ?? DateTime(0)) ?? 0);
        break;
      case 'titleAZ':
        articlesToSort.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case 'titleZA':
        articlesToSort.sort(
            (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case 'source':
        articlesToSort.sort((a, b) =>
            a.sourceName.toLowerCase().compareTo(b.sourceName.toLowerCase()));
        break;
    }

    if (_filteredArticles.isEmpty) {
      _articles = List.from(articlesToSort);
    } else {
      _filteredArticles = List.from(articlesToSort);
    }
  }

  void searchArticles(String query) {
    if (query.isEmpty) {
      _filteredArticles.clear();
    } else {
      _filteredArticles = _articles
          .where((article) =>
              article.title.toLowerCase().contains(query.toLowerCase()) ||
              (article.description
                      ?.toLowerCase()
                      .contains(query.toLowerCase()) ??
                  false))
          .toList();
      _applySorting();
    }
    notifyListeners();
  }

  void toggleBookmark(ArticleModel article) {
    final index = _bookmarkedArticles.indexWhere((a) => a.url == article.url);

    if (index != -1) {
      _bookmarkedArticles.removeAt(index);
    } else {
      _bookmarkedArticles.add(article);
    }

    _saveBookmarkedArticles();
    notifyListeners();
  }

  bool isBookmarked(ArticleModel article) {
    return _bookmarkedArticles
        .any((bookmarkedArticle) => bookmarkedArticle.url == article.url);
  }

  void _saveBookmarkedArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> bookmarkedJson = _bookmarkedArticles
        .map((article) => jsonEncode(article.toJson()))
        .toList();
    prefs.setStringList('bookmarkedArticles', bookmarkedJson);
  }

  void _loadBookmarkedArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? bookmarkedJson = prefs.getStringList('bookmarkedArticles');
    if (bookmarkedJson != null) {
      _bookmarkedArticles = bookmarkedJson
          .map((json) => ArticleModel.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _filteredArticles.clear();
    fetchArticles(category: category);
  }
}

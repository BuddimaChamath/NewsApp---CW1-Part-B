import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import '../widgets/article_tile.dart';

class BookmarkedScreen extends StatelessWidget {
  const BookmarkedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Articles'),
      ),
      body: articleProvider.bookmarkedArticles.isEmpty
          ? const Center(child: Text('No articles bookmarked yet'))
          : ListView.builder(
              itemCount: articleProvider.bookmarkedArticles.length,
              itemBuilder: (context, index) {
                return ArticleTile(
                    article: articleProvider.bookmarkedArticles[index]);
              },
            ),
    );
  }
}

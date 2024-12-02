import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:news_app/providers/article_provider.dart';
import 'package:provider/provider.dart';
import '../models/article_model.dart';
import '../screens/article_detail_screen.dart';

class ArticleTile extends StatelessWidget {
  final ArticleModel article;

  const ArticleTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle nullable image URL
            if ((article.imageUrl ?? '').isNotEmpty)
              CachedNetworkImage(
                imageUrl: article.imageUrl!,
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200.0,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200.0,
                  color: Colors.grey[300],
                  child: const Center(
                      child: Icon(Icons.broken_image,
                          size: 50.0, color: Colors.grey)),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Provider.of<ArticleProvider>(context)
                              .isBookmarked(article)
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                    ),
                    onPressed: () {
                      Provider.of<ArticleProvider>(context, listen: false)
                          .toggleBookmark(article);
                    },
                  ),
                ],
              ),
            ),
            if ((article.description ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  article.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70 // Light color for dark mode
                          : Colors.black87 // Dark color for light mode
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

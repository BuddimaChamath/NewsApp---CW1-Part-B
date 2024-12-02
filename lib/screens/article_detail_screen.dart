import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/article_model.dart';

class ArticleDetailScreen extends StatelessWidget {
  final ArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  // Method to launch article url
  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(article.url);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  // Method to share article
  void _shareArticle(BuildContext context) {
    Share.share(
      '${article.title}\n\nRead more: ${article.url}',
      subject: 'Check out this article',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareArticle(context),
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _launchUrl,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  _buildTitleSection(theme, isDarkMode),

                  const SizedBox(height: 8.0),

                  // Source
                  _buildSourceSection(theme, isDarkMode),

                  const SizedBox(height: 16.0),

                  // Description
                  _buildDescriptionSection(theme, isDarkMode),

                  const SizedBox(height: 16.0),

                  // Published Date
                  _buildPublishedDateSection(theme, isDarkMode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return (article.imageUrl ?? '').isNotEmpty
        ? CachedNetworkImage(
            imageUrl: article.imageUrl!,
            height: 250.0,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholderImage(),
            errorWidget: (context, url, error) => _buildPlaceholderImage(),
          )
        : _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 250.0,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 50.0, color: Colors.grey),
      ),
    );
  }

  Widget _buildTitleSection(ThemeData theme, bool isDarkMode) {
    return Text(
      article.title,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildSourceSection(ThemeData theme, bool isDarkMode) {
    return (article.sourceName).isNotEmpty
        ? Text(
            'Source: ${article.sourceName}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildDescriptionSection(ThemeData theme, bool isDarkMode) {
    return (article.description ?? '').isNotEmpty
        ? Text(
            article.description!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          )
        : const Text('No description available');
  }

  Widget _buildPublishedDateSection(ThemeData theme, bool isDarkMode) {
    return Text(
      'Published at: ${_formatDateTime(article.publishedAt)}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: isDarkMode ? Colors.white54 : Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }

  // Helper method to format date
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown Date';
    return DateFormat('MMMM d, yyyy - hh:mm a').format(dateTime);
  }
}

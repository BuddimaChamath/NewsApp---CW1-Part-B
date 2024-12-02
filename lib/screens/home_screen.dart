import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/bookmarked_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/category_chips.dart';
import '../widgets/article_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _setupScrollController();
    _setupAnimationController();
    _initializeData();
  }

  void _setupScrollController() {
    _scrollController.addListener(() {
      setState(() {
        _showScrollToTop = _scrollController.offset > 200;
      });
    });
  }

  void _setupAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _initializeData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ArticleProvider>(context, listen: false).fetchArticles();
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _animationController.forward();
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _animationController.reverse();
      Provider.of<ArticleProvider>(context, listen: false).searchArticles("");
    });
  }

  Future<void> _refreshArticles() async {
    final articleProvider =
        Provider.of<ArticleProvider>(context, listen: false);
    await articleProvider.fetchArticles(
        category: articleProvider.selectedCategory);
  }

  void _showSortOptions() {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final articleProvider =
        Provider.of<ArticleProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sort Articles',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _buildSortOption(
                context: context,
                icon: Icons.access_time,
                title: 'Newest First',
                selected: articleProvider.sortBy == 'newest',
                onTap: () => _handleSort('newest'),
              ),
              _buildSortOption(
                context: context,
                icon: Icons.access_time_filled,
                title: 'Oldest First',
                selected: articleProvider.sortBy == 'oldest',
                onTap: () => _handleSort('oldest'),
              ),
              _buildSortOption(
                context: context,
                icon: Icons.sort_by_alpha,
                title: 'Title A-Z',
                selected: articleProvider.sortBy == 'titleAZ',
                onTap: () => _handleSort('titleAZ'),
              ),
              _buildSortOption(
                context: context,
                icon: Icons.sort_by_alpha,
                title: 'Title Z-A',
                selected: articleProvider.sortBy == 'titleZA',
                onTap: () => _handleSort('titleZA'),
              ),
              _buildSortOption(
                context: context,
                icon: Icons.source,
                title: 'By Source',
                selected: articleProvider.sortBy == 'source',
                onTap: () => _handleSort('source'),
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final theme = Theme.of(context);

    return Column(
      children: [
        ListTile(
          leading: Icon(
            icon,
            color: selected
                ? theme.primaryColor
                : isDarkMode
                    ? Colors.white70
                    : Colors.black87,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: selected,
          selectedTileColor: isDarkMode
              ? theme.primaryColor
                  .withOpacity(0.2) // Dark mode selected background
              : theme.primaryColor
                  .withOpacity(0.1), // Light mode selected background
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 70,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
          ),
      ],
    );
  }

  void _handleSort(String sortType) {
    Provider.of<ArticleProvider>(context, listen: false).sortArticles(sortType);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final articleProvider = Provider.of<ArticleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Top Headlines',
        isSearching: _isSearching,
        onSearchChanged: (value) => articleProvider.searchArticles(value),
        onSearchClose: _stopSearch,
        onSearchOpen: _startSearch,
        onShowSortOptions: _showSortOptions,
        onBookmarksOpen: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookmarkedScreen()),
          );
        },
        toggleTheme: () => themeProvider.toggleTheme(),
        isDarkMode: themeProvider.isDarkMode,
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: _isSearching ? 0 : null,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: CategoryChips(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshArticles,
              child: Stack(
                children: [
                  articleProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : articleProvider.articles.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: articleProvider.articles.length,
                              itemBuilder: (context, index) {
                                return ArticleTile(
                                  article: articleProvider.articles[index],
                                );
                              },
                            ),
                  if (_showScrollToTop)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _scrollToTop,
                        child: const Icon(Icons.arrow_upward),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No articles found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _refreshArticles,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

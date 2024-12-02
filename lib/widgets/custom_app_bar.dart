import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final Function(String) onSearchChanged;
  final VoidCallback onSearchClose;
  final VoidCallback onSearchOpen;
  final VoidCallback onShowSortOptions;
  final VoidCallback onBookmarksOpen;
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.isSearching,
    required this.onSearchChanged,
    required this.onSearchClose,
    required this.onSearchOpen,
    required this.onShowSortOptions,
    required this.onBookmarksOpen,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: isSearching
          ? TextField(
              decoration: const InputDecoration(
                hintText: 'Search articles...',
                border: InputBorder.none,
              ),
              onChanged: onSearchChanged,
              autofocus: true,
            )
          : Text(title),
      actions: [
        if (isSearching)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onSearchClose,
          )
        else ...[
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: onShowSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchOpen,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: onBookmarksOpen,
          ),
        ],
        IconButton(
          icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          onPressed: toggleTheme,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

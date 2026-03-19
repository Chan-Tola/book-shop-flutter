import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onStartSearch;
  final VoidCallback onStopSearch;
  final ValueChanged<String> onSubmitSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClearSearch;

  const HeaderWidget({
    super.key,
    required this.title,
    required this.isSearching,
    required this.searchController,
    required this.searchFocusNode,
    required this.onStartSearch,
    required this.onStopSearch,
    required this.onSubmitSearch,
    this.onChanged,
    this.onClearSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      titleSpacing: 30,
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: isSearching
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: onStopSearch,
            )
          : null,
      title: isSearching
          ? Container(
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search books, author:name, category:name...",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            size: 20,
                            color: Colors.grey,
                          ),
                          onPressed: onClearSearch,
                        )
                      : null,
                ),
                onChanged: onChanged,
                onSubmitted: onSubmitSearch,
              ),
            )
          : Text(
              title,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
      actions: [
        if (!isSearching)
          IconButton(
            icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface),
            onPressed: onStartSearch,
          ),
      ],
    );
  }
}

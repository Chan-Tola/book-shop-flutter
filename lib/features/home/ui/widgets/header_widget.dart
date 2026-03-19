import 'package:flutter/material.dart';

class HeaderWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final VoidCallback onStartSearch;
  final VoidCallback onStopSearch;
  final ValueChanged<String> onSubmitSearch;

  const HeaderWidget({
    super.key,
    required this.title,
    required this.isSearching,
    required this.searchController,
    required this.searchFocusNode,
    required this.onStartSearch,
    required this.onStopSearch,
    required this.onSubmitSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 30,
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: onStopSearch,
            )
          : null,
      title: isSearching
          ? Container(
              height: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: searchController,
                focusNode: searchFocusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: "Search books",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onSubmitted: onSubmitSearch,
              ),
            )
          : Text(title, style: const TextStyle(color: Color(0xFF1E2A3A))),
      actions: [
        if (!isSearching)
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.black),
            onPressed: onStartSearch,
          ),
      ],
    );
  }
}

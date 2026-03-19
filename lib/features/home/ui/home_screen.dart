import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../book/logic/book_provider.dart';
import '../../book/ui/book_detail_screen.dart';
import 'widgets/header_widget.dart';
import 'widgets/promo_banner.dart';
import 'widgets/section_header_widget.dart';
import 'widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final booksProvider = context.read<BookProvider>();
      if (booksProvider.books.isEmpty && !booksProvider.isLoading) {
        booksProvider.fetchBooks();
      }
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    Future.microtask(() => _searchFocusNode.requestFocus());
  }

  void _stopSearch(BookProvider provider) {
    if (!mounted) return;
    _searchTimer?.cancel();
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    provider.fetchBooks();
  }

  void _onSearchChanged(BookProvider provider, String value) {
    _searchTimer?.cancel();
    if (mounted) {
      setState(() {});
    }
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _performSearch(provider);
      }
    });
  }

  void _performSearch(BookProvider provider) {
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      // When search is empty, show all books
      provider.fetchBooks(forceRefresh: true);
      return;
    }

    // Parse unified search query - check if it looks like author or category search
    String? title, author, category;

    // Simple heuristics for unified search
    if (searchQuery.toLowerCase().startsWith('author:')) {
      author = searchQuery.substring(7).trim();
    } else if (searchQuery.toLowerCase().startsWith('category:')) {
      category = searchQuery.substring(9).trim();
    } else {
      // Default to title search (backend will also search in author/category if needed)
      title = searchQuery;
    }

    provider.fetchBooks(title: title, author: author, category: category);
  }

  void _submitSearch(BookProvider provider, String value) {
    _searchTimer?.cancel();
    _performSearch(provider);
  }

  void _clearSearch(BookProvider provider) {
    _searchTimer?.cancel();
    _searchController.clear();
    if (mounted) {
      setState(() {});
    }
    // Force refresh to get all books back
    provider.fetchBooks(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BookProvider>();

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: HeaderWidget(
        title: "Digital-Book",
        isSearching: _isSearching,
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onStartSearch: _startSearch,
        onStopSearch: () => _stopSearch(booksProvider),
        onSubmitSearch: (value) => _submitSearch(booksProvider, value),
        onChanged: (value) => _onSearchChanged(booksProvider, value),
        onClearSearch: () => _clearSearch(booksProvider),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, _isSearching ? 0 : 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isSearching) const SizedBox(height: 4),
                    if (!_isSearching)
                      PromoBanner(
                        title: 'Special Offer!',
                        subtitle: 'Get 20% off on selected books',
                        onTap: () {
                          // TODO: Navigate to promo page
                        },
                      ),
                    if (!_isSearching)
                      SectionHeaderWidget(
                        title: 'Popular Books',
                        actionText: 'See all',
                        onActionPressed: () {
                          // TODO: Navigate to all books
                        },
                      ),
                    if (!_isSearching) const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            if (booksProvider.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF1B6EF3)),
                ),
              )
            else if (booksProvider.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    booksProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else if (booksProvider.books.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No books found')),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, _isSearching ? 0 : 16, 20, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 300,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final book = booksProvider.books[index];
                    return ProductCard(
                      title: book.title,
                      author: null,
                      price: book.price,
                      rating: book.rating,
                      imageUrl: book.imageUrl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailScreen(bookId: book.id),
                          ),
                        );
                      },
                    );
                  }, childCount: booksProvider.books.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

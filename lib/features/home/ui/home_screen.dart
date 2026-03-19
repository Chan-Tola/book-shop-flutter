import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../book/logic/book_provider.dart';
import '../../book/ui/book_detail_screen.dart';
import 'widgets/header_widget.dart';
import 'widgets/location_card_widget.dart';
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
    _searchController.text = "";
    setState(() {
      _isSearching = false;
    });
    provider.fetchBooks();
  }

  void _submitSearch(BookProvider provider, String value) {
    provider.fetchBooks(title: value);
  }

  @override
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BookProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: HeaderWidget(
        title: "Digital-Book",
        isSearching: _isSearching,
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onStartSearch: _startSearch,
        onStopSearch: () => _stopSearch(booksProvider),
        onSubmitSearch: (value) => _submitSearch(booksProvider, value),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LocationCardWidget(
              //   location: 'Phnom Penh',
              //   address: 'Phnom Penh, Cambodia',
              //   onChangeLocation: () {
              //     // TODO: Implement location change functionality
              //   },
              // ),
              const SizedBox(height: 4),
              PromoBanner(
                title: 'Special Offer!',
                subtitle: 'Get 20% off on selected books',
                onTap: () {
                  // TODO: Navigate to promo page
                },
              ),
              SectionHeaderWidget(
                title: 'Popular Books',
                actionText: 'See all',
                onActionPressed: () {
                  // TODO: Navigate to all books
                },
              ),
              const SizedBox(height: 12),
              if (booksProvider.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: CircularProgressIndicator(color: Color(0xFF1B6EF3)),
                  ),
                )
              else if (booksProvider.error != null)
                Center(
                  child: Text(
                    booksProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              else if (booksProvider.books.isEmpty)
                const Center(child: Text('No books found'))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: booksProvider.books.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 300,
                  ),
                  itemBuilder: (context, index) {
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
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

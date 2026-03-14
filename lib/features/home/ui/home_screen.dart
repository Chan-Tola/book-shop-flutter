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
  Widget build(BuildContext context) {
    final booksProvider = context.watch<BookProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              title: 'Digital-Book',
              onSearchPressed: () {
                // TODO: Implement search functionality
              },
              onNotificationPressed: () {
                // TODO: Implement notification functionality
              },
            ),
            const SizedBox(height: 16),
            LocationCardWidget(
              location: 'Phnom Penh',
              address: 'Phnom Penh, Cambodia',
              onChangeLocation: () {
                // TODO: Implement location change functionality
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome back',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E2A3A),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Browse your next read',
              style: TextStyle(fontSize: 12, color: Color(0xFF7A8699)),
            ),
            const SizedBox(height: 20),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/book_provider.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().fetchBookById(widget.bookId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final book = bookProvider.selectedBook;

    return Scaffold(
      appBar: AppBar(title: const Text('Book Detail')),
      body: bookProvider.isLoading
          ? const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Color(0xFF1B6EF3),
                  strokeWidth: 2.5,
                ),
              ),
            )
          : bookProvider.error != null
          ? Center(
              child: Text(
                bookProvider.error!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : book == null
          ? const Center(child: Text('Book not found'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (book.imageUrl != null && book.imageUrl!.isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          book.imageUrl!,
                          height: 260,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 260,
                              width: double.infinity,
                              color: const Color(0xFFEFF4FF),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Color(0xFF1B6EF3),
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2A3A),
                    ),
                  ),
                  if (book.author != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          if (book.authorPhoto != null &&
                              book.authorPhoto!.isNotEmpty)
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFFEFF4FF),
                              backgroundImage: NetworkImage(book.authorPhoto!),
                            )
                          else
                            const CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(0xFFEFF4FF),
                              child: Icon(
                                Icons.person,
                                size: 16,
                                color: Color(0xFF1B6EF3),
                              ),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Author: ${book.author!}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF7A8699),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (book.category != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Category: ${book.category!}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF7A8699),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (book.price != null)
                    Text(
                      '\$${book.price!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1B6EF3),
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (book.description != null)
                    Text(
                      book.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E2A3A),
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: null, // TODO: Implement purchase
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B6EF3),
                        disabledBackgroundColor: const Color(0xFF1B6EF3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

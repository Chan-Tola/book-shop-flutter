import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';

class BookPriceWidget extends StatelessWidget {
  final BookModel book;

  const BookPriceWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    if (book.price == null) {
      return const SizedBox.shrink();
    }

    return Text(
      '\$${book.price!.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1B6EF3),
      ),
    );
  }
}

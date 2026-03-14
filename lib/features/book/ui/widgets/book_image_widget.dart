import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';

class BookImageWidget extends StatelessWidget {
  final BookModel book;

  const BookImageWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    if (book.imageUrl == null || book.imageUrl!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
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
    );
  }
}

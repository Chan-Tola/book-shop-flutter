import 'package:flutter/material.dart';
import '../../data/models/book_model.dart';

class BookInfoWidget extends StatelessWidget {
  final BookModel book;

  const BookInfoWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                if (book.authorPhoto != null && book.authorPhoto!.isNotEmpty)
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
              style: const TextStyle(fontSize: 14, color: Color(0xFF7A8699)),
            ),
          ),
        const SizedBox(height: 12),
        if (book.description != null)
          Text(
            book.description!,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E2A3A),
              height: 1.5,
            ),
          ),
      ],
    );
  }
}

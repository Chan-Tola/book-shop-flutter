import 'package:flutter/material.dart';

class BookInfoWidget extends StatelessWidget {
  final String title;
  final String? author;
  final String? authorPhoto;
  final String? authorWebsite;
  final String? description;

  const BookInfoWidget({
    super.key,
    required this.title,
    this.author,
    this.authorPhoto,
    this.authorWebsite,
    this.description,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return "";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily:
                  'Serif', // Fallback to serif if custom font not available
              color: Color(0xFF1E2A3A),
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Author Profile
        if (author != null)
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFE5E7EB),
                    backgroundImage: authorPhoto != null
                        ? NetworkImage(authorPhoto!)
                        : null,
                    child: authorPhoto == null
                        ? Text(
                            _initials(author!),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        author!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF111827),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (authorWebsite != null)
                        Text(
                          authorWebsite!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),

        // Stock Indicator
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'In Stock',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Description
        if (description != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              description!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
                height: 1.6,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final double? price;
  final double? oldPrice;
  final double? rating;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? author;

  const ProductCard({
    super.key,
    required this.title,
    this.price,
    this.oldPrice,
    this.rating,
    this.imageUrl,
    this.onTap,
    this.author,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProductImage(imageUrl: imageUrl),
            const SizedBox(height: 10),
            _ProductInfo(
              title: title,
              price: price,
              oldPrice: oldPrice,
              rating: rating,
              author: author,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFF1F3F6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl == null || imageUrl!.isEmpty
              ? _buildPlaceholder(Icons.menu_book_rounded)
              : CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: const Color(0xFF1B6EF3),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return _buildPlaceholder(Icons.broken_image_outlined);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(IconData icon) {
    return Center(
      child: Icon(
        icon,
        color: const Color(0xFF1B6EF3),
        size: 36, // Slightly larger icon
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final String title;
  final double? price;
  final double? oldPrice;
  final double? rating;
  final String? author;

  const _ProductInfo({
    required this.title,
    this.price,
    this.oldPrice,
    this.rating,
    this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E2A3A),
                  height: 1.25,
                ),
              ),
            ),
            if (rating != null) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: Color(0xFFF4B400),
              ),
              Text(
                rating!.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E2A3A),
                ),
              ),
            ],
          ],
        ),
        if (author != null && author!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            author!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF7A8699),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (price != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '\$${price!.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E2A3A),
                ),
              ),
              if (oldPrice != null) ...[
                const SizedBox(width: 6),
                Text(
                  '\$${oldPrice!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9AA6B2),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

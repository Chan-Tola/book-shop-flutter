import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookImageWidget extends StatefulWidget {
  final String? imageUrl;
  final List<String>? galleryImages;

  const BookImageWidget({
    super.key,
    required this.imageUrl,
    this.galleryImages,
  });

  @override
  State<BookImageWidget> createState() => _BookImageWidgetState();
}

class _BookImageWidgetState extends State<BookImageWidget> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.7);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _buildImageList();

    return Column(
      children: [
        const SizedBox(height: 20),
        // Horizontal Scrollable Gallery
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final image = images[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Shadow/Shelf effect
                    Container(
                      height: 20,
                      width: 200,
                      margin: const EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                    ),
                    // Shelf base
                    Container(
                      height: 12,
                      width: 240,
                      margin: const EdgeInsets.only(top: 280),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    // Book Cover
                    Transform.translate(
                      offset: const Offset(0, -15),
                      child: Hero(
                        tag: 'book_image_${image}_${index}',
                        child: Container(
                          height: 300,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(5, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: _buildImageWidget(image),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Page Indicator Dots
        if (images.length > 1) _buildPageIndicator(images.length),
      ],
    );
  }

  List<String> _buildImageList() {
    final List<String> images = [];

    // Add main image if available
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      images.add(widget.imageUrl!);
    }

    // Add gallery images if available
    if (widget.galleryImages != null) {
      for (final image in widget.galleryImages!) {
        if (image.isNotEmpty && !images.contains(image)) {
          images.add(image);
        }
      }
    }

    // If no images, add placeholder
    if (images.isEmpty) {
      images.add('placeholder');
    }

    // Limit to 5 images max for performance
    return images.take(5).toList();
  }

  Widget _buildImageWidget(String imageUrl) {
    if (imageUrl == 'placeholder') {
      return Container(
        color: const Color(0xFF2D3436),
        child: const Center(
          child: Icon(Icons.book, color: Colors.white54, size: 50),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: const Color(0xFF2D3436),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
            strokeWidth: 2,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        return Container(
          color: const Color(0xFF2D3436),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 50),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: _currentIndex == index ? 24 : 8,
            decoration: BoxDecoration(
              color: _currentIndex == index
                  ? const Color(0xFF1B6EF3)
                  : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

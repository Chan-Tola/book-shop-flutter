import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/book_provider.dart';
import '../../cart/logic/cart_provider.dart';
import '../../auth/logic/auth_provider.dart';
import '../../../shared/widgets/global_toast.dart';
import 'widgets/book_image_widget.dart';
import 'widgets/book_info_widget.dart';
import 'widgets/book_price_widget.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().fetchBookById(widget.bookId);
      // Initialize cart with user token
      final authProvider = context.read<AuthProvider>();
      final cartProvider = context.read<CartProvider>();
      if (authProvider.user?.token != null) {
        cartProvider.setToken(authProvider.user!.token!);
        cartProvider.fetchCart();
      }
    });
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;

    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.read<CartProvider>();

    // Check if user is authenticated
    if (authProvider.user?.token == null) {
      context.showWarningToast('Please login to add items to cart');
      return;
    }

    setState(() {
      _isAddingToCart = true;
    });

    try {
      await cartProvider.addToCart(widget.bookId, 1, context: context);

      if (mounted) {
        context.showSuccessToast('Book added to cart successfully!');
        setState(() {}); // Rebuild to update button state
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Failed to add to cart: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final cartProvider = context.watch<CartProvider>();
    final book = bookProvider.selectedBook;
    final isBookInCart = cartProvider.isItemInCart(widget.bookId);

    return Scaffold(
      backgroundColor: const Color(
        0xFFF8F9FA,
      ), // Light background like screenshot
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
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
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // 1. Book Image Gallery
                          BookImageWidget(
                            imageUrl: book.imageUrl,
                            galleryImages: book.images,
                          ),

                          const SizedBox(height: 40),

                          // 2. Book Info (Title, Author, Stock, Description)
                          BookInfoWidget(
                            title: book.title,
                            author: book.author,
                            authorPhoto: book.authorPhoto,
                            authorWebsite: book.authorWebsite,
                            description: book.description,
                          ),

                          const SizedBox(height: 20),

                          // 3. Price (Optional, kept subtle)
                          if (book.price != null)
                            BookPriceWidget(price: book.price),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // 4. Action Button "Get the Book"
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 34),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: (_isAddingToCart || isBookInCart)
                            ? null
                            : _addToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B6EF3),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade400,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isAddingToCart
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                isBookInCart ? 'In Your Cart' : 'Get the Book',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/cart_provider.dart';
import '../../auth/logic/auth_provider.dart';
import 'widgets/cart_item_widget.dart';
import 'widgets/cart_summary_widget.dart';
import '../../../shared/widgets/global_toast.dart';
import '../../order/ui/order_checkout_screen.dart';
import '../../../shared/layouts/main_layout.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Set token from AuthProvider to CartProvider
      if (authProvider.user?.token != null) {
        cartProvider.setToken(authProvider.user!.token!);
        cartProvider.fetchCart();
      } else {
        cartProvider.clearError();
        cartProvider.clearLocalCart();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light background
      appBar: _buildAppBar(),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading && cartProvider.cart.items.isEmpty) {
            return _buildLoadingState();
          }

          if (cartProvider.error != null && cartProvider.cart.items.isEmpty) {
            return _buildErrorState(cartProvider);
          }

          if (cartProvider.isEmpty) {
            return _buildEmptyCartState();
          }

          return _buildCartContent(cartProvider);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'My Cart',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black,
        ),
      ),
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: Colors.black,
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainLayout()),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(CartProvider cartProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading cart',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              cartProvider.error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                cartProvider.clearError();
                cartProvider.fetchCart();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add some books to get started!',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _navigateToBooks(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: const Color(0xFF1B6EF3), // 👈 your color
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Browse Books',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(CartProvider cartProvider) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => cartProvider.fetchCart(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: cartProvider.cart.items.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cart.items[index];
                return CartItemWidget(
                  item: item,
                  onQuantityChanged: (bookId, quantity) {
                    cartProvider.updateCartItem(
                      bookId,
                      quantity,
                      context: context,
                    );
                  },
                  onRemove: (bookId) {
                    cartProvider.removeFromCart(bookId, context: context);
                  },
                  isLoading: cartProvider.isLoading,
                );
              },
            ),
          ),
        ),
        CartSummaryWidget(
          totalAmount: cartProvider.totalAmount,
          totalItems: cartProvider.itemCount,
          onCheckout: () => _navigateToCheckout(),
          isLoading: cartProvider.isLoading,
        ),
      ],
    );
  }

  void _navigateToBooks() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> _navigateToCheckout() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OrderCheckoutScreen()));

    if (result != null && mounted) {
      context.showSuccessToast('Order created. Proceed to payment.');
    }
  }

  void _showRemoveItemDialog(CartProvider cartProvider, String bookId) {
    final item = cartProvider.getItemById(bookId);
    if (item == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: Text(
            'Are you sure you want to remove "${item.title}" from your cart?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                cartProvider.removeFromCart(bookId, context: context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }
}

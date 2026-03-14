import 'package:flutter/material.dart';
import '../data/models/cart_model.dart';
import '../data/services/cart_service.dart';
import '../../../shared/widgets/global_loading.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  CartModel _cart = CartModel(items: [], totalAmount: 0.0, totalItems: 0);
  bool _isLoading = false;
  String? _error;
  String? _token;

  CartModel get cart => _cart;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _cart.isEmpty;
  bool get isNotEmpty => _cart.isNotEmpty;
  int get itemCount => _cart.totalItems;
  double get totalAmount => _cart.totalAmount;

  void setToken(String token) {
    _token = token;
  }

  Future<void> fetchCart() async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cart = await _cartService.getCart(_token!);
    } catch (e) {
      _error = e.toString();
      _cart = CartModel(items: [], totalAmount: 0.0, totalItems: 0);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(
    String bookId,
    int quantity, {
    BuildContext? context,
  }) async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Show global loading
    if (context != null) {
      GlobalLoading.show(context, message: 'Adding to cart...');
    }

    try {
      _cart = await _cartService.addToCart(_token!, bookId, quantity);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Hide global loading
      if (context != null) {
        GlobalLoading.hide();
      }
      notifyListeners();
    }
  }

  Future<void> updateCartItem(
    String bookId,
    int quantity, {
    BuildContext? context,
  }) async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return;
    }

    if (quantity <= 0) {
      await removeFromCart(bookId, context: context);
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Show global loading
    if (context != null) {
      GlobalLoading.show(context, message: 'Updating cart...');
    }

    try {
      final updatedCart = await _cartService.updateCartItem(
        _token!,
        bookId,
        quantity,
      );

      // Preserve existing item data if response doesn't include full book objects
      final List<CartItemModel> mergedItems = updatedCart.items.map((
        updatedItem,
      ) {
        final existingItem = _cart.items.firstWhere(
          (item) => item.bookId == updatedItem.bookId,
          orElse: () => updatedItem,
        );

        // Use updated quantity but preserve other data from existing item if needed
        return CartItemModel(
          bookId: updatedItem.bookId,
          title: updatedItem.title.isNotEmpty
              ? updatedItem.title
              : existingItem.title,
          author: updatedItem.author ?? existingItem.author,
          imageUrl: updatedItem.imageUrl ?? existingItem.imageUrl,
          price: updatedItem.price > 0 ? updatedItem.price : existingItem.price,
          quantity: updatedItem.quantity,
          book: updatedItem.book ?? existingItem.book,
        );
      }).toList();

      _cart = updatedCart.copyWith(items: mergedItems);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Hide global loading
      if (context != null) {
        GlobalLoading.hide();
      }
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String bookId, {BuildContext? context}) async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Show global loading
    if (context != null) {
      GlobalLoading.show(context, message: 'Removing item...');
    }

    try {
      final updatedCart = await _cartService.removeFromCart(_token!, bookId);

      // Preserve existing item data for remaining items if response doesn't include full book objects
      final List<CartItemModel> mergedItems = updatedCart.items.map((
        updatedItem,
      ) {
        final existingItem = _cart.items.firstWhere(
          (item) => item.bookId == updatedItem.bookId,
          orElse: () => updatedItem,
        );

        // Use updated data but preserve existing data if needed
        return CartItemModel(
          bookId: updatedItem.bookId,
          title: updatedItem.title.isNotEmpty
              ? updatedItem.title
              : existingItem.title,
          author: updatedItem.author ?? existingItem.author,
          imageUrl: updatedItem.imageUrl ?? existingItem.imageUrl,
          price: updatedItem.price > 0 ? updatedItem.price : existingItem.price,
          quantity: updatedItem.quantity,
          book: updatedItem.book ?? existingItem.book,
        );
      }).toList();

      _cart = updatedCart.copyWith(items: mergedItems);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Hide global loading
      if (context != null) {
        GlobalLoading.hide();
      }
      notifyListeners();
    }
  }

  Future<void> clearCart({BuildContext? context}) async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // Show global loading
    if (context != null) {
      GlobalLoading.show(context, message: 'Clearing cart...');
    }

    try {
      final updatedCart = await _cartService.clearCart(_token!);

      // For clear cart, we typically get an empty cart, but handle any remaining items
      final List<CartItemModel> mergedItems = updatedCart.items.map((
        updatedItem,
      ) {
        final existingItem = _cart.items.firstWhere(
          (item) => item.bookId == updatedItem.bookId,
          orElse: () => updatedItem,
        );

        // Use updated data but preserve existing data if needed
        return CartItemModel(
          bookId: updatedItem.bookId,
          title: updatedItem.title.isNotEmpty
              ? updatedItem.title
              : existingItem.title,
          author: updatedItem.author ?? existingItem.author,
          imageUrl: updatedItem.imageUrl ?? existingItem.imageUrl,
          price: updatedItem.price > 0 ? updatedItem.price : existingItem.price,
          quantity: updatedItem.quantity,
          book: updatedItem.book ?? existingItem.book,
        );
      }).toList();

      _cart = updatedCart.copyWith(items: mergedItems);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      // Hide global loading
      if (context != null) {
        GlobalLoading.hide();
      }
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearLocalCart() {
    _cart = CartModel(items: [], totalAmount: 0.0, totalItems: 0);
    _error = null;
    notifyListeners();
  }

  CartItemModel? getItemById(String bookId) {
    try {
      return _cart.items.firstWhere((item) => item.bookId == bookId);
    } catch (e) {
      return null;
    }
  }

  bool isItemInCart(String bookId) {
    return getItemById(bookId) != null;
  }

  int getItemQuantity(String bookId) {
    final item = getItemById(bookId);
    return item?.quantity ?? 0;
  }
}

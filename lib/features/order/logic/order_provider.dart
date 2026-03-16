import 'package:flutter/material.dart';
import '../data/models/order_model.dart';
import '../data/services/order_service.dart';
import '../../../shared/widgets/global_loading.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  String? _token;

  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrders => _orders.isNotEmpty;

  void setToken(String token) {
    _token = token;
  }

  Future<void> fetchMyOrders({
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _orderService.getMyOrders(
        _token!,
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );
      _orders = result.orders;
    } catch (e) {
      _error = e.toString();
      _orders = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderById(String orderId) async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrder = await _orderService.getOrderById(_token!, orderId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel?> createOrder(
    ShippingAddressModel shippingAddress, {
    BuildContext? context,
  }) async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    if (context != null) {
      GlobalLoading.show(context, message: 'Creating order...');
    }

    try {
      final order = await _orderService.createOrder(_token!, shippingAddress);
      _selectedOrder = order;
      _orders = [order, ..._orders.where((o) => o.id != order.id)];
      return order;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      if (context != null) {
        GlobalLoading.hide();
      }
      notifyListeners();
    }
  }

  Future<OrderModel?> cancelOrder(
    String orderId, {
    BuildContext? context,
  }) async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    if (context != null) {
      GlobalLoading.show(context, message: 'Canceling order...');
    }

    try {
      final order = await _orderService.cancelOrder(_token!, orderId);
      _selectedOrder = order;
      _orders = _orders.map((o) => o.id == order.id ? order : o).toList();
      return order;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
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

  void clearLocalOrders() {
    _orders = [];
    _selectedOrder = null;
    _error = null;
    notifyListeners();
  }
}

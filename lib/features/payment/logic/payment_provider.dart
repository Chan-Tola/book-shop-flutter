import 'package:flutter/material.dart';
import '../data/models/payment_model.dart';
import '../data/services/payment_service.dart';
import '../../../shared/widgets/global_loading.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  PaymentIntentInfo? _paymentIntentInfo;
  bool _isLoading = false;
  String? _error;
  String? _token;

  PaymentIntentInfo? get paymentIntentInfo => _paymentIntentInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setToken(String token) {
    _token = token;
  }

  Future<PaymentIntentInfo?> createPaymentIntent(
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
      GlobalLoading.show(context, message: 'Preparing payment...');
    }

    try {
      _paymentIntentInfo = await _paymentService.createPaymentIntent(
        _token!,
        orderId,
      );
      return _paymentIntentInfo;
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

  Future<bool> confirmPayment(
    String paymentIntentId, {
    BuildContext? context,
  }) async {
    if (_token == null) {
      _error = 'Authentication required';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    if (context != null) {
      GlobalLoading.show(context, message: 'Confirming payment...');
    }

    try {
      await _paymentService.confirmPayment(_token!, paymentIntentId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
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
}

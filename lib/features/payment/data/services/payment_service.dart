import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/payment_model.dart';

class PaymentService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<PaymentIntentInfo> createPaymentIntent(
    String token,
    String orderId,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.payment}/intent',
        data: {'orderId': orderId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dataNode = response.data['data'] ?? response.data;
        return PaymentIntentInfo.fromJson(Map<String, dynamic>.from(dataNode));
      }
    } on DioException catch (e) {
      print(
        "Create Payment Intent Error: ${e.response?.data['message'] ?? e.message}",
      );
      rethrow;
    }
    throw Exception('Failed to create payment intent');
  }

  Future<void> confirmPayment(String token, String paymentIntentId) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.payment}/confirm',
        data: {'paymentIntentId': paymentIntentId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return;
      }
    } on DioException catch (e) {
      print(
        "Confirm Payment Error: ${e.response?.data['message'] ?? e.message}",
      );
      rethrow;
    }
    throw Exception('Failed to confirm payment');
  }
}

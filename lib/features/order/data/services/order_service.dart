import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/api/dio_client.dart';
import '../models/order_model.dart';

class OrderService {
  final Dio _dio = DioClient.instance;

  OrderModel _parseOrder(dynamic root) {
    if (root is! Map) {
      throw Exception('Unexpected response: ${root.runtimeType}');
    }

    dynamic dataNode = root['data'] ?? root['order'] ?? root;
    if (dataNode is Map && dataNode['order'] is Map) {
      dataNode = dataNode['order'];
    }

    if (dataNode is! Map) {
      throw Exception(
        'Unexpected order response shape: ${dataNode.runtimeType}',
      );
    }

    return OrderModel.fromJson(Map<String, dynamic>.from(dataNode));
  }

  OrderListModel _parseOrderList(dynamic root) {
    if (root is! Map) {
      throw Exception('Unexpected response: ${root.runtimeType}');
    }

    final dataNode = root['data'] ?? root;
    if (dataNode is Map && dataNode['orders'] != null) {
      return OrderListModel.fromJson(Map<String, dynamic>.from(dataNode));
    }

    if (dataNode is List) {
      return OrderListModel.fromJson({'orders': dataNode});
    }

    if (dataNode is Map) {
      return OrderListModel.fromJson(Map<String, dynamic>.from(dataNode));
    }

    throw Exception('Unexpected order list response shape');
  }

  Future<OrderModel> createOrder(
    String token,
    ShippingAddressModel shippingAddress,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.order}/checkout',
        data: {'shippingAddress': shippingAddress.toJson()},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return _parseOrder(response.data);
      }
    } on DioException catch (e) {
      print("Create Order Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    throw Exception('Failed to create order');
  }

  Future<OrderListModel> getMyOrders(
    String token, {
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.order}/my-orders',
        queryParameters: {
          'page': page,
          'limit': limit,
          'sortBy': sortBy,
          'sortOrder': sortOrder,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return _parseOrderList(response.data);
      }
    } on DioException catch (e) {
      print("Get My Orders Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    throw Exception('Failed to fetch orders');
  }

  Future<OrderModel> getOrderById(String token, String orderId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.order}/my-orders/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return _parseOrder(response.data);
      }
    } on DioException catch (e) {
      print("Get Order Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    throw Exception('Failed to fetch order');
  }

  Future<OrderModel> cancelOrder(String token, String orderId) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.order}/my-orders/$orderId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return _parseOrder(response.data);
      }
    } on DioException catch (e) {
      print("Cancel Order Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    throw Exception('Failed to cancel order');
  }
}

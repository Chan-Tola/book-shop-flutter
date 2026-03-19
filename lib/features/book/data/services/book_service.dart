import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/book_model.dart';

class BookService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  List<BookModel> _parseBooks(dynamic root) {
    if (root is! Map && root is! List) {
      throw Exception('Unexpected response: ${root.runtimeType}');
    }

    dynamic dataNode = root;
    if (root is Map) {
      dataNode = root['data'] ?? root['books'] ?? root;
    }

    if (dataNode is Map && dataNode['books'] is List) {
      dataNode = dataNode['books'];
    }

    if (dataNode is! List) {
      throw Exception(
        'Unexpected books response shape: ${dataNode.runtimeType}',
      );
    }

    return dataNode
        .whereType<Map>()
        .map((e) => BookModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  BookModel _parseBook(dynamic root) {
    if (root is! Map) {
      throw Exception('Unexpected response: ${root.runtimeType}');
    }

    dynamic dataNode = root['data'] ?? root['book'] ?? root;
    if (dataNode is Map && dataNode['book'] is Map) {
      dataNode = dataNode['book'];
    }

    if (dataNode is! Map) {
      throw Exception(
        'Unexpected book response shape: ${dataNode.runtimeType}',
      );
    }

    return BookModel.fromJson(Map<String, dynamic>.from(dataNode));
  }

  Future<List<BookModel>> getBooks({
    String? title,
    String? author,
    String? category,
  }) async {
    try {
      final query = <String, String>{};
      if (title != null && title.trim().isNotEmpty) {
        query["title"] = title.trim();
      }
      if (author != null && author.trim().isNotEmpty) {
        query["author"] = author.trim();
      }
      if (category != null && category.trim().isNotEmpty) {
        query["category"] = category.trim();
      }

      final response = await _dio.get(
        ApiConstants.books,
        queryParameters: query.isEmpty ? null : query,
      );
      if (response.statusCode == 200) {
        return _parseBooks(response.data);
      }
    } on DioException catch (e) {
      print("Get Books Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    return [];
  }

  Future<BookModel> getBookById(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.books}/$id');
      if (response.statusCode == 200) {
        return _parseBook(response.data);
      }
    } on DioException catch (e) {
      print("Get Book Error: ${e.response?.data['message'] ?? e.message}");
      rethrow;
    }
    throw Exception('Book not found');
  }
}

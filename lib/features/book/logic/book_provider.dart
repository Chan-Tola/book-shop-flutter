import 'package:flutter/material.dart';
import '../data/models/book_model.dart';
import '../data/services/book_service.dart';

class BookProvider extends ChangeNotifier {
  final BookService _bookService = BookService();

  List<BookModel> _books = [];
  BookModel? _selectedBook;
  bool _isLoading = false;
  String? _error;

  List<BookModel> get books => _books;
  BookModel? get selectedBook => _selectedBook;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBooks({
    String? title,
    String? author,
    String? category,
    bool forceRefresh = false,
  }) async {
    // Skip if already loading
    if (_isLoading) return;
    // Only skip if we have data AND not forcing refresh AND no search parameters
    if (!forceRefresh &&
        _books.isNotEmpty &&
        title == null &&
        author == null &&
        category == null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _bookService.getBooks(
        title: title,
        author: author,
        category: category,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookById(String id, {bool forceRefresh = false}) async {
    // Skip if already loading or if we already have this book loaded
    if (_isLoading) return;
    if (!forceRefresh && _selectedBook != null && _selectedBook!.id == id) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedBook = await _bookService.getBookById(id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

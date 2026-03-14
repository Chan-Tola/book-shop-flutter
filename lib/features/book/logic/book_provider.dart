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

  Future<void> fetchBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _bookService.getBooks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBookById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedBook = await _bookService.getBookById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

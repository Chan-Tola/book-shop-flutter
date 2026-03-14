class CartItemModel {
  final String bookId;
  final String title;
  final String? author;
  final String? imageUrl;
  final double price;
  final int quantity;
  final String? book;

  CartItemModel({
    required this.bookId,
    required this.title,
    this.author,
    this.imageUrl,
    required this.price,
    required this.quantity,
    this.book,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? _toInt(dynamic v) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    String? _authorName(dynamic v) {
      if (v is Map && v['name'] != null) return v['name'].toString();
      if (v is String) return v;
      return null;
    }

    String? _firstImage(dynamic v) {
      if (v is List && v.isNotEmpty) return v.first.toString();
      return v?.toString();
    }

    // Handle backend response where bookId contains full book object
    final bookData = json['bookId'] ?? json['book'];
    final bookId = bookData is Map
        ? bookData['_id']?.toString() ?? ''
        : json['bookId']?.toString() ?? '';

    return CartItemModel(
      bookId: bookId.isNotEmpty ? bookId : '',
      title: bookData is Map
          ? (bookData['title']?.toString() ?? json['title']?.toString() ?? '')
          : (json['title']?.toString() ?? ''),
      author: bookData is Map
          ? _authorName(bookData['author'])
          : json['author']?.toString(),
      imageUrl: bookData is Map
          ? _firstImage(bookData['images'])
          : json['imageUrl']?.toString(),
      price:
          _toDouble(
            json['priceAtAddition'] ?? json['price'] ?? bookData?['price'],
          ) ??
          0.0,
      quantity: _toInt(json['quantity']) ?? 1,
      book: bookData?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'price': price,
      'quantity': quantity,
      if (book != null) 'book': book,
    };
  }

  CartItemModel copyWith({
    String? bookId,
    String? title,
    String? author,
    String? imageUrl,
    double? price,
    int? quantity,
    String? book,
  }) {
    return CartItemModel(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      book: book ?? this.book,
    );
  }

  double get subtotal => price * quantity;
}

class CartModel {
  final List<CartItemModel> items;
  final double totalAmount;
  final int totalItems;

  CartModel({
    required this.items,
    required this.totalAmount,
    required this.totalItems,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    int? _toInt(dynamic v) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    List<CartItemModel> _parseItems(dynamic itemsNode) {
      if (itemsNode is List) {
        return itemsNode
            .whereType<Map>()
            .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    final dynamic itemsNode = json['items'] ?? json['cartItems'] ?? [];
    final items = _parseItems(itemsNode);

    double calculateTotal() {
      return items.fold(0.0, (sum, item) => sum + item.subtotal);
    }

    int calculateTotalItems() {
      return items.fold(0, (sum, item) => sum + item.quantity);
    }

    return CartModel(
      items: items,
      totalAmount:
          _toDouble(
            json['totalPrice'] ?? json['totalAmount'] ?? json['total'],
          ) ??
          calculateTotal(),
      totalItems:
          _toInt(json['totalItems'] ?? json['itemCount']) ??
          calculateTotalItems(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'totalItems': totalItems,
    };
  }

  CartModel copyWith({
    List<CartItemModel>? items,
    double? totalAmount,
    int? totalItems,
  }) {
    return CartModel(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
}

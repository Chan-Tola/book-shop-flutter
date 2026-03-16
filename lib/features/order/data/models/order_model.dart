class OrderItemModel {
  final String bookId;
  final String title;
  final String? author;
  final String? imageUrl;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.bookId,
    required this.title,
    this.author,
    this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
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

    final bookData = json['bookId'];
    final bookId = bookData is Map
        ? bookData['_id']?.toString() ?? ''
        : json['bookId']?.toString() ?? '';

    return OrderItemModel(
      bookId: bookId,
      title: bookData is Map
          ? (bookData['title']?.toString() ?? json['title']?.toString() ?? '')
          : (json['title']?.toString() ?? ''),
      author: bookData is Map
          ? _authorName(bookData['author'])
          : json['author']?.toString(),
      imageUrl: bookData is Map
          ? _firstImage(bookData['images'])
          : json['imageUrl']?.toString(),
      price: _toDouble(json['price']) ?? 0.0,
      quantity: _toInt(json['quantity']) ?? 1,
    );
  }

  double get subtotal => price * quantity;
}

class ShippingAddressModel {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  ShippingAddressModel({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      zipCode: json['zipCode']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final List<OrderItemModel> items;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final ShippingAddressModel shippingAddress;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.shippingAddress,
    this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    List<OrderItemModel> _parseItems(dynamic node) {
      if (node is List) {
        return node
            .whereType<Map>()
            .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    final shippingNode = json['shippingAddress'];
    final shippingAddress = shippingNode is Map
        ? ShippingAddressModel.fromJson(Map<String, dynamic>.from(shippingNode))
        : ShippingAddressModel(
            street: '',
            city: '',
            state: '',
            zipCode: '',
            country: '',
          );

    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt'].toString());
    }

    return OrderModel(
      id: json['_id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      items: _parseItems(json['items']),
      totalPrice: _toDouble(json['totalPrice']) ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      paymentMethod: json['paymentMethod']?.toString() ?? 'stripe',
      shippingAddress: shippingAddress,
      createdAt: createdAt,
    );
  }
}

class OrderListModel {
  final List<OrderModel> orders;
  final int total;
  final int page;
  final int totalPages;

  OrderListModel({
    required this.orders,
    required this.total,
    required this.page,
    required this.totalPages,
  });

  factory OrderListModel.fromJson(Map<String, dynamic> json) {
    List<OrderModel> _parseOrders(dynamic node) {
      if (node is List) {
        return node
            .whereType<Map>()
            .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    int _toInt(dynamic v, int fallback) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    final orders = _parseOrders(json['orders'] ?? json['data'] ?? []);

    return OrderListModel(
      orders: orders,
      total: _toInt(json['total'], orders.length),
      page: _toInt(json['page'], 1),
      totalPages: _toInt(json['totalPages'], 1),
    );
  }
}

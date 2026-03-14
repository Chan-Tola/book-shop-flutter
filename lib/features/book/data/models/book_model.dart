class BookModel {
  final String id;
  final String title;
  final String? author;
  final String? authorPhoto;
  final String? category;
  final double? price;
  final String? imageUrl;
  final List<String> images;
  final double? rating;
  final String? description;

  BookModel({
    required this.id,
    required this.title,
    this.author,
    this.authorPhoto,
    this.category,
    this.price,
    this.imageUrl,
    this.images = const [],
    this.rating,
    this.description,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    double? _toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    String? _authorName(dynamic v) {
      if (v is Map && v['name'] != null) return v['name'].toString();
      if (v is String) return v;
      return null;
    }

    String? _authorPhoto(dynamic v) {
      if (v is Map && v['photo'] != null) return v['photo'].toString();
      return null;
    }

    String? _categoryName(dynamic v) {
      if (v is Map && v['name'] != null) return v['name'].toString();
      if (v is String) return v;
      return null;
    }

    String? _firstImage(dynamic v) {
      if (v is List && v.isNotEmpty) return v.first.toString();
      return null;
    }

    List<String> _images(dynamic v) {
      if (v is List) {
        return v.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return BookModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      author: _authorName(json['author']),
      authorPhoto: _authorPhoto(json['author']),
      category: _categoryName(json['category']),
      price: _toDouble(json['price']),
      imageUrl:
          json['imageUrl']?.toString() ??
          json['coverUrl']?.toString() ??
          json['image']?.toString() ??
          _firstImage(json['images']),
      images: _images(json['images']),
      rating: _toDouble(json['rating']),
      description: json['description']?.toString(),
    );
  }
}

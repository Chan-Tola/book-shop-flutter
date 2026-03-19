class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final String? createdAt;
  final String? updatedAt;
  final String? token;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String? token) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name']?.toString(),
      role: json['role']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      token: token,
    );
  }
}

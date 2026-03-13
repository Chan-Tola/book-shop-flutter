class UserModel {
  final String id;
  final String email;
  final String? token;

  UserModel({required this.id, required this.email, this.token});

  factory UserModel.fromJson(Map<String, dynamic> json, String? token) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      token: token,
    );
  }
}

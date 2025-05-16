class UserModel {
  final String? id;
  final String username;
  final String email;
  final String? role;
  final String? profilePicture;
  final String? bio;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.role = 'user',
    this.profilePicture,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      profilePicture: json['profilePicture']?.toString(),
      bio: json['bio']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'profilePicture': profilePicture,
      'bio': bio,
    }..removeWhere((key, value) => value == null);
  }
}
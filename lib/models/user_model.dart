class UserModel {
  final String id;
  final String username;
  final String email;
  final String role; // Added role field
  final String? profilePicture;
  final String? bio;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.profilePicture,
    this.bio,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'] ?? 'user', // Default to 'user' if not provided
      profilePicture: json['profilePicture'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
        'email': email,
        'role': role,
        'profilePicture': profilePicture,
        'bio': bio,
      };
}

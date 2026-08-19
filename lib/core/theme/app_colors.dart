class UserModel {
  final String id;
  final String email;
  final String username;
  final String? phone;
  final String? governorate;
  final String? profileImage;
  final bool isVerified;
  final bool isVip;
  final bool isStore;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
    this.governorate,
    this.profileImage,
    this.isVerified = false,
    this.isVip = false,
    this.isStore = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      phone: map['phone'],
      governorate: map['governorate'],
      profileImage: map['profile_image'],
      isVerified: map['is_verified'] ?? false,
      isVip: map['is_vip'] ?? false,
      isStore: map['is_store'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'phone': phone,
      'governorate': governorate,
      'profile_image': profileImage,
      'is_verified': isVerified,
      'is_vip': isVip,
      'is_store': isStore,
    };
  }
}
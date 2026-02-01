class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  
  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar': avatar,
    };
  }
  
  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
    );
  }
}

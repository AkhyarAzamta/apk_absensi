// lib/models/user_model.dart
class User {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final String division;
  final String role;
  final String position;
  final DateTime joinDate;
  final String? phone;
  final String? address;
  final String? photo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.division,
    required this.role,
    required this.position,
    required this.joinDate,
    this.phone,
    this.address,
    this.photo,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      employeeId: json['employeeId'],
      name: json['name'],
      email: json['email'],
      division: json['division'],
      role: json['role'],
      position: json['position'],
      joinDate: DateTime.parse(json['joinDate']),
      phone: json['phone'],
      address: json['address'],
      photo: json['photo'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
      'email': email,
      'division': division,
      'position': position,
      'joinDate': joinDate.toIso8601String().split('T')[0],
      'phone': phone,
      'address': address,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? division,
    String? position,
    String? phone,
    String? address,
  }) {
    return User(
      id: id,
      employeeId: employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      division: division ?? this.division,
      role: role,
      position: position ?? this.position,
      joinDate: joinDate,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photo: photo,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
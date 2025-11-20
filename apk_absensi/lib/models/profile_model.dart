class Profile {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final String division;
  final String role;
  final String position;
  final DateTime joinDate;
  final String phone;
  final String address;
  final String? photo;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.division,
    required this.role,
    required this.position,
    required this.joinDate,
    required this.phone,
    required this.address,
    this.photo,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
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
      'id': id,
      'employeeId': employeeId,
      'name': name,
      'email': email,
      'division': division,
      'role': role,
      'position': position,
      'joinDate': joinDate.toIso8601String(),
      'phone': phone,
      'address': address,
      'photo': photo,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

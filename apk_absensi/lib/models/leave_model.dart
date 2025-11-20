class LeaveRequest {
  final int? id;
  final int userId;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String reason;
  final String status;
  final String? approvedBy;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveRequest({
    this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.reason,
    this.status = 'PENDING',
    this.approvedBy,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      userId: json['userId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      type: json['type'],
      reason: json['reason'],
      status: json['status'],
      approvedBy: json['approvedBy'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'type': type,
      'reason': reason,
    };
  }
}

class LeaveType {
  final String value;
  final String label;

  const LeaveType(this.value, this.label);
}

class LeaveData {
  static final List<LeaveType> types = [
    LeaveType('CUTI_TAHUNAN', 'Cuti Tahunan'),
    LeaveType('CUTI_SAKIT', 'Cuti Sakit'),
    LeaveType('CUTI_MELAHIRKAN', 'Cuti Melahirkan'),
    LeaveType('CUTI_ALASAN_PENTING', 'Cuti Alasan Penting'),
  ];

  static String getLabel(String value) {
    return types.firstWhere((type) => type.value == value, orElse: () => LeaveType(value, value)).label;
  }
}
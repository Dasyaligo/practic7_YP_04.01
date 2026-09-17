class Employee {
  final int id;
  final String fullName;
  final String position;
  final String email;
  final double salary;
  final DateTime hiredAt;
  final DateTime? deletedAt;

  const Employee({
    required this.id,
    required this.fullName,
    required this.position,
    required this.email,
    required this.salary,
    required this.hiredAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Employee copyWith({
    String? fullName,
    String? position,
    String? email,
    double? salary,
    DateTime? hiredAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Employee(
      id: id,
      fullName: fullName ?? this.fullName,
      position: position ?? this.position,
      email: email ?? this.email,
      salary: salary ?? this.salary,
      hiredAt: hiredAt ?? this.hiredAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'position': position,
        'email': email,
        'salary': salary,
        'hiredAt': hiredAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'] as int? ?? 0,
        fullName: (json['full_name'] ?? json['fullName']) as String? ?? '',
        position: json['position'] as String? ?? '',
        email: json['email'] as String? ?? '',
        salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
        hiredAt: (json['hired_at'] ?? json['hiredAt']) != null
            ? DateTime.parse((json['hired_at'] ?? json['hiredAt']) as String)
            : DateTime.now(),
        deletedAt: (json['deleted_at'] ?? json['deletedAt']) != null
            ? DateTime.parse((json['deleted_at'] ?? json['deletedAt']) as String)
            : null,
      );
}
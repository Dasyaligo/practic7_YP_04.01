enum Role {
  customer(1),
  manager(2),
  admin(3);

  final int level;
  const Role(this.level);

  /// Парсит строку из API. Приводит к нижнему регистру и убирает пробелы.
  static Role fromString(String value) {
    final v = value.trim().toLowerCase();
    return switch (v) {
      'admin' => Role.admin,
      'manager' => Role.manager,
      'customer' => Role.customer,
      _ => Role.customer,
    };
  }

  String get displayName => switch (this) {
        Role.customer => 'Покупатель',
        Role.manager => 'Менеджер',
        Role.admin => 'Администратор',
      };
}

class AppUser {
  final int id;
  final String username;
  final String fullName;
  final Role role;

  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as int? ?? 0,
        username: json['username'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        role: Role.fromString(json['role'] as String? ?? 'customer'),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'role': role.name,
      };
}
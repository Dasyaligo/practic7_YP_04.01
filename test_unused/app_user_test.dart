import 'package:flutter_test/flutter_test.dart';
import 'package:onlyphones_shop/models/app_user.dart';

void main() {
  group('Role', () {
    test('уровни ролей строго возрастают', () {
      expect(Role.customer.level, lessThan(Role.manager.level));
      expect(Role.manager.level, lessThan(Role.admin.level));
    });

    test('Role.fromString парсит корректные значения', () {
      expect(Role.fromString('admin'), Role.admin);
      expect(Role.fromString('manager'), Role.manager);
      expect(Role.fromString('customer'), Role.customer);
    });

    test('Role.fromString регистронезависим', () {
      expect(Role.fromString('ADMIN'), Role.admin);
      expect(Role.fromString('Manager'), Role.manager);
    });

    test('Role.fromString неизвестного значения → customer', () {
      expect(Role.fromString('unknown'), Role.customer);
      expect(Role.fromString(''), Role.customer);
    });
  });

  group('AppUser.fromJson', () {
    test('корректно разбирает полный JSON', () {
      final user = AppUser.fromJson({
        'id': 1,
        'username': 'admin',
        'fullName': 'Администратор',
        'role': 'admin',
      });
      expect(user.id, 1);
      expect(user.username, 'admin');
      expect(user.fullName, 'Администратор');
      expect(user.role, Role.admin);
    });

    test('устойчив к отсутствующим полям', () {
      final user = AppUser.fromJson({});
      expect(user.id, 0);
      expect(user.username, '');
      expect(user.fullName, '');
      expect(user.role, Role.customer);
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import 'package:onlyphones_shop/models/app_user.dart';

void main() {
  group('Разграничение прав по ролям', () {
    test('customer не имеет доступа к manager-функциям', () {
      final user = AppUser(
        id: 1,
        username: 'customer',
        fullName: 'Покупатель',
        role: Role.customer,
      );
      expect(user.role.level >= Role.manager.level, isFalse);
    });

    test('customer не имеет доступа к admin-функциям', () {
      final user = AppUser(
        id: 1,
        username: 'customer',
        fullName: 'Покупатель',
        role: Role.customer,
      );
      expect(user.role.level >= Role.admin.level, isFalse);
    });

    test('manager имеет доступ к manager-функциям', () {
      final user = AppUser(
        id: 2,
        username: 'manager',
        fullName: 'Менеджер',
        role: Role.manager,
      );
      expect(user.role.level >= Role.manager.level, isTrue);
    });

    test('manager НЕ имеет доступа к admin-функциям', () {
      final user = AppUser(
        id: 2,
        username: 'manager',
        fullName: 'Менеджер',
        role: Role.manager,
      );
      expect(user.role.level >= Role.admin.level, isFalse);
    });

    test('admin имеет доступ ко всем функциям', () {
      final user = AppUser(
        id: 3,
        username: 'admin',
        fullName: 'Администратор',
        role: Role.admin,
      );
      expect(user.role.level >= Role.manager.level, isTrue);
      expect(user.role.level >= Role.admin.level, isTrue);
    });

    test('Role.fromString парсит все роли', () {
      expect(Role.fromString('admin'), Role.admin);
      expect(Role.fromString('manager'), Role.manager);
      expect(Role.fromString('customer'), Role.customer);
      expect(Role.fromString('unknown'), Role.customer);
      expect(Role.fromString(''), Role.customer);
    });

    test('уровни ролей строго возрастают', () {
      expect(Role.customer.level, lessThan(Role.manager.level));
      expect(Role.manager.level, lessThan(Role.admin.level));
    });

    test('AppUser.fromJson корректно разбирает JSON', () {
      final user = AppUser.fromJson({
        'id': 1,
        'username': 'test',
        'fullName': 'Test User',
        'role': 'manager',
      });
      expect(user.id, 1);
      expect(user.username, 'test');
      expect(user.fullName, 'Test User');
      expect(user.role, Role.manager);
    });

    test('AppUser.fromJson устойчив к отсутствующим полям', () {
      final user = AppUser.fromJson({});
      expect(user.id, 0);
      expect(user.username, '');
      expect(user.fullName, '');
      expect(user.role, Role.customer);
    });
  });
}
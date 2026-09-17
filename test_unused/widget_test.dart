import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:onlyphones_shop/models/app_user.dart';
import 'package:onlyphones_shop/screens/forbidden_screen.dart';
import 'package:onlyphones_shop/screens/not_found_screen.dart';
import 'package:onlyphones_shop/screens/login_screen.dart';
import 'package:onlyphones_shop/screens/home_screen.dart';
import 'package:onlyphones_shop/state/auth_notifier.dart';


class FakeAuthNotifier extends ChangeNotifier implements AuthNotifier {
  AppUser? _user;
  String? _accessToken;
  DateTime? _sessionStart;

  FakeAuthNotifier({AppUser? user}) : _user = user;

  @override
  AppUser? get user => _user;

  @override
  String? get accessToken => _accessToken;

  @override
  bool get isAuthenticated => _user != null;

  @override
  DateTime? get sessionStart => _sessionStart;

  @override
  bool get isSessionExpired => false;

  @override
  bool has(Role role) {
    if (_user == null) return false;
    return _user!.role.level >= role.level;
  }

  @override
  Future<void> restore() async {}

  @override
  Future<void> login(String username, String password) async {
    _user = AppUser(
      id: 1,
      username: username,
      fullName: 'Тестовый пользователь',
      role: Role.customer,
    );
    notifyListeners();
  }

  @override
  Future<void> register({
    required String username,
    required String password,
    required String fullName,
    required String email,
  }) async {}

  @override
  Future<void> refreshTokens() async {}

  @override
  Future<void> logout() async {
    _user = null;
    notifyListeners();
  }

  @override
  Future<void> checkSessionDuration() async {}
}


Widget buildTestApp(Widget child, {FakeAuthNotifier? auth}) {
  return ChangeNotifierProvider<AuthNotifier>.value(
    value: auth ?? FakeAuthNotifier(),
    child: MaterialApp(home: child),
  );
}


void main() {
  
  group('Виджет NotFoundScreen', () {
testWidgets('показывает переданный адрес и кнопку', (tester) async {
  await tester.pumpWidget(buildTestApp(
    const NotFoundScreen(location: '/qwerty'),
  ));

  // Текст встречается 2 раза: в AppBar и в теле — поэтому findsNWidgets(2)
  expect(find.text('Страница не найдена'), findsNWidgets(2));
  expect(find.textContaining('/qwerty'), findsOneWidget);
  expect(find.text('На главную'), findsOneWidget);
});
  });


  group('Виджет ForbiddenScreen', () {
    testWidgets('показывает сообщение о недостатке прав', (tester) async {
      final auth = FakeAuthNotifier(
        user: const AppUser(
          id: 1,
          username: 'customer',
          fullName: 'Тест',
          role: Role.customer,
        ),
      );

      await tester.pumpWidget(buildTestApp(
        const ForbiddenScreen(),
        auth: auth,
      ));

      expect(
        find.text('У вас нет прав для этой операции'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });


  group('Виджет LoginScreen', () {
    testWidgets('валидация: пустые поля не пропускаются', (tester) async {
      await tester.pumpWidget(buildTestApp(const LoginScreen()));

      // Нажимаем «Войти» без заполнения полей
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите логин'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
    });

    testWidgets('отображает поля ввода и кнопку', (tester) async {
      await tester.pumpWidget(buildTestApp(const LoginScreen()));

      expect(find.text('Логин'), findsOneWidget);
      expect(find.text('Пароль'), findsOneWidget);
      expect(find.text('Войти'), findsOneWidget);
    });
  });


  group('Виджет HomeScreen — разграничение прав', () {
    testWidgets('customer НЕ видит кнопки «Покупатели» и «Администрирование»',
        (tester) async {
      final auth = FakeAuthNotifier(
        user: const AppUser(
          id: 1,
          username: 'customer',
          fullName: 'Покупатель',
          role: Role.customer,
        ),
      );

      await tester.pumpWidget(buildTestApp(const HomeScreen(), auth: auth));

      expect(find.textContaining('Каталог телефонов'), findsOneWidget);
      expect(find.textContaining('Бренды'), findsOneWidget);
      expect(find.textContaining('Покупатели'), findsNothing);
      expect(find.textContaining('Администрирование'), findsNothing);
    });

    testWidgets('manager видит «Покупатели», но НЕ «Администрирование»',
        (tester) async {
      final auth = FakeAuthNotifier(
        user: const AppUser(
          id: 2,
          username: 'manager',
          fullName: 'Менеджер',
          role: Role.manager,
        ),
      );

      await tester.pumpWidget(buildTestApp(const HomeScreen(), auth: auth));

      expect(find.textContaining('Покупатели'), findsOneWidget);
      expect(find.textContaining('Администрирование'), findsNothing);
    });

    testWidgets('admin видит все кнопки', (tester) async {
      final auth = FakeAuthNotifier(
        user: const AppUser(
          id: 3,
          username: 'admin',
          fullName: 'Администратор',
          role: Role.admin,
        ),
      );

      await tester.pumpWidget(buildTestApp(const HomeScreen(), auth: auth));

      expect(find.textContaining('Покупатели'), findsOneWidget);
      expect(find.textContaining('Администрирование'), findsOneWidget);
    });
  });
}
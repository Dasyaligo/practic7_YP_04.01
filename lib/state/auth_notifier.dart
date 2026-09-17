import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';

class AuthNotifier extends ChangeNotifier {
  static const _kRole = 'auth_role';
  static const _kName = 'auth_name';
  static const _kUsername = 'auth_username';

  final SharedPreferences _prefs;

  AuthNotifier(this._prefs);

  AppUser? _user;
  DateTime? _sessionStart;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  DateTime? get sessionStart => _sessionStart;

  bool has(Role role) {
    final u = _user;
    if (u == null) return false;
    return u.role.level >= role.level;
  }

  bool get isSessionExpired {
    if (_sessionStart == null) return false;
    return DateTime.now().difference(_sessionStart!) > const Duration(hours: 8);
  }

  Future<void> restore() async {
    final role = _prefs.getString(_kRole);
    final name = _prefs.getString(_kName);
    final username = _prefs.getString(_kUsername);
    if (role == null || name == null || username == null) return;
    _user = AppUser(
      id: 0,
      username: username,
      fullName: name,
      role: Role.fromString(role),
    );
    _sessionStart = DateTime.now();
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    Role role;
    String fullName;
    if (username == 'admin' && password == 'admin123') {
      role = Role.admin;
      fullName = 'Администратор';
    } else if (username == 'manager' && password == 'manager123') {
      role = Role.manager;
      fullName = 'Менеджер Петров';
    } else if (username == 'customer' && password == 'customer123') {
      role = Role.customer;
      fullName = 'Иванов Иван';
    } else {
      throw Exception('Неверный логин или пароль');
    }

    _user = AppUser(id: 0, username: username, fullName: fullName, role: role);
    _sessionStart = DateTime.now();
    await _prefs.setString(_kRole, role.name);
    await _prefs.setString(_kName, fullName);
    await _prefs.setString(_kUsername, username);
    notifyListeners();
  }

  Future<void> register({
    required String username,
    required String password,
    required String fullName,
    required String email,
  }) async {
    _user = AppUser(id: 0, username: username, fullName: fullName, role: Role.customer);
    _sessionStart = DateTime.now();
    await _prefs.setString(_kRole, Role.customer.name);
    await _prefs.setString(_kName, fullName);
    await _prefs.setString(_kUsername, username);
    notifyListeners();
  }

  Future<void> refreshTokens() async {}

  Future<void> logout() async {
    _user = null;
    _sessionStart = null;
    await _prefs.remove(_kRole);
    await _prefs.remove(_kName);
    await _prefs.remove(_kUsername);
    notifyListeners();
  }
}
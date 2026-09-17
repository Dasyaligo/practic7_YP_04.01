import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/phone.dart';
import '../models/phone_query.dart';
import '../models/page_result.dart';
import 'phone_repository.dart';
import 'seed_data.dart';

class PersistentPhoneRepository implements PhoneRepository {
  static const String _key = 'onlyphones_phones_v4'; // 👈 НОВАЯ ВЕРСИЯ
  final SharedPreferences _prefs;
  List<Phone> _phones = [];
  int _nextId = 1;

  PersistentPhoneRepository(this._prefs) { _restore(); }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _phones = List.from(seedPhones);
      _nextId = _phones.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _phones = list.map((e) => Phone.fromJson(e as Map<String, dynamic>)).toList();
      _nextId = _phones.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
    } catch (e) {
      print('⚠️ Ошибка восстановления данных: $e');
      _phones = List.from(seedPhones);
      _nextId = _phones.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
      _persist();
    }
  }

  Future<void> _persist() async {
    final jsonData = jsonEncode(_phones.map((p) => p.toJson()).toList());
    await _prefs.setString(_key, jsonData);
  }

  @override
  Future<PageResult<Phone>> find(PhoneQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));
    var rows = _phones.where((p) => q.includeDeleted || !p.isDeleted).toList();
    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows.where((p) => p.model.toLowerCase().contains(needle)).toList();
    }
    if (q.brandId != null) rows = rows.where((p) => p.brandId == q.brandId).toList();
    if (q.priceFrom != null) rows = rows.where((p) => p.price >= q.priceFrom!).toList();
    if (q.priceTo != null) rows = rows.where((p) => p.price <= q.priceTo!).toList();
    if (q.storage != null) rows = rows.where((p) => p.storage == q.storage).toList();
    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'price' => a.price.compareTo(b.price),
        'storage' => (a.storage ?? 0).compareTo(b.storage ?? 0),
        _ => a.model.toLowerCase().compareTo(b.model.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });
    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Phone>[] : rows.sublist(from, to);
    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Phone?> findById(int id) async {
    try { return _phones.firstWhere((p) => p.id == id && !p.isDeleted); } catch (_) { return null; }
  }

  @override
  Future<Phone> create(Phone phone) async {
    final newPhone = Phone(
      id: _nextId++,
      model: phone.model,
      brandId: phone.brandId,
      price: phone.price,
      storage: phone.storage,
      ram: phone.ram,
      color: phone.color,
      screenSize: phone.screenSize,
      stock: phone.stock,
      createdAt: DateTime.now(),
    );
    _phones.add(newPhone);
    await _persist();
    return newPhone;
  }

  @override
  Future<Phone> update(Phone phone) async {
    final index = _phones.indexWhere((p) => p.id == phone.id);
    if (index == -1) throw StateError('Телефон не найден');
    _phones[index] = phone;
    await _persist();
    return phone;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _phones.indexWhere((p) => p.id == id);
    if (index == -1) throw StateError('Телефон не найден');
    _phones[index] = _phones[index].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    _phones.removeWhere((p) => p.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final index = _phones.indexWhere((p) => p.id == id);
    if (index == -1) throw StateError('Телефон не найден');
    _phones[index] = _phones[index].copyWith(clearDeletedAt: true);
    await _persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    int count = 0;
    for (final id in ids) {
      final index = _phones.indexWhere((p) => p.id == id && !p.isDeleted);
      if (index != -1) {
        _phones[index] = _phones[index].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await _persist();
    return count;
  }
}
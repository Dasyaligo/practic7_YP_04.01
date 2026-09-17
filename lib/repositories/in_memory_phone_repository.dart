import '../models/phone.dart';
import '../models/phone_query.dart';
import '../models/page_result.dart';
import 'phone_repository.dart';
import 'seed_data.dart';

class InMemoryPhoneRepository implements PhoneRepository {
  final List<Phone> _phones = [];
  int _nextId = 1;

  InMemoryPhoneRepository() {
    _phones.addAll(seedPhones);
    _nextId = seedPhones.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  Future<PageResult<Phone>> find(PhoneQuery q) async {
   //throw Exception('Тестовая ошибка: данные недоступны');
    await Future.delayed(const Duration(milliseconds: 250));

    var rows = _phones.where((p) => q.includeDeleted || !p.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows.where((p) =>
          p.model.toLowerCase().contains(needle) ||
          p.model.toLowerCase().contains(needle) 
      ).toList();
    }

    if (q.brandId != null) {
      rows = rows.where((p) => p.brandId == q.brandId).toList();
    }
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
  try {
    return _phones.firstWhere((p) => p.id == id && !p.isDeleted);
  } catch (_) {
    return null;
  }
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
    return newPhone;
  }

  @override
  Future<Phone> update(Phone phone) async {
    final index = _phones.indexWhere((p) => p.id == phone.id);
    if (index == -1) throw StateError('Телефон не найден');
    _phones[index] = phone;
    return phone;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _phones.indexWhere((p) => p.id == id);
    if (index == -1) throw StateError('Телефон не найден');
    _phones[index] = _phones[index].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _phones.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final index = _phones.indexWhere((p) => p.id == id);
    if (index == -1) throw StateError('Телефон не найден');
    _phones[index] = _phones[index].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    var count = 0;
    for (final id in ids) {
      // ИСПРАВЛЕНА ОШИБКА: было b[i], стало b
      final index = _phones.indexWhere((p) => p.id == id && !p.isDeleted);
      if (index != -1) {
        _phones[index] = _phones[index].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
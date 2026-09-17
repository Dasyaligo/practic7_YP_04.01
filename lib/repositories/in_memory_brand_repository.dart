import '../models/brand.dart';
import '../models/page_result.dart';
import 'brand_repository.dart';
import 'seed_data.dart';

class InMemoryBrandRepository implements BrandRepository {
  final List<Brand> _brands = [];
  int _nextId = 1;

  // Для проверки зависимостей (телефоны этого бренда)
  // В реальном проекте использовали бы Provider, но здесь для простоты
  // передаём список телефонов через конструктор или глобально
  // Для упрощения сделаем метод _hasPhones, который будет проверять через seedPhones

  InMemoryBrandRepository() {
    _brands.addAll(seedBrands);
    _nextId = _brands.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  // Вспомогательный метод: есть ли телефоны этого бренда?
  bool _hasPhones(int brandId) {
    return seedPhones.any((p) => p.brandId == brandId && !p.isDeleted);
  }

  // Подсчёт количества связанных телефонов
  int _countPhones(int brandId) {
    return seedPhones.where((p) => p.brandId == brandId && !p.isDeleted).length;
  }

  @override
  Future<PageResult<Brand>> find(BrandQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));

    var rows = _brands.where((b) => q.includeDeleted || !b.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows.where((b) =>
          b.name.toLowerCase().contains(needle) ||
          b.country.toLowerCase().contains(needle)
      ).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'country' => a.country.compareTo(b.country),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Brand>[] : rows.sublist(from, to);

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Brand?> findById(int id) async {
    try {
      return _brands.firstWhere((b) => b.id == id && !b.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Brand> create(Brand brand) async {
    final newBrand = Brand(
      id: _nextId++,
      name: brand.name,
      country: brand.country,
      foundedYear: brand.foundedYear,
    );
    _brands.add(newBrand);
    return newBrand;
  }

  @override
  Future<Brand> update(Brand brand) async {
    final index = _brands.indexWhere((b) => b.id == brand.id);
    if (index == -1) throw StateError('Бренд не найден');
    _brands[index] = brand;
    return brand;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _brands.indexWhere((b) => b.id == id);
    if (index == -1) throw StateError('Бренд с ID $id не найден');

    // Проверка: есть ли телефоны этого бренда?
    if (_hasPhones(id)) {
      final count = _countPhones(id);
      throw StateError('Невозможно удалить бренд: есть $count связанных телефон(ов)');
    }

    _brands[index] = _brands[index].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    // Проверка: есть ли телефоны этого бренда?
    if (_hasPhones(id)) {
      final count = _countPhones(id);
      throw StateError('Невозможно удалить бренд: есть $count связанных телефон(ов)');
    }
    _brands.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final index = _brands.indexWhere((b) => b.id == id);
    if (index == -1) throw StateError('Бренд с ID $id не найден');
    _brands[index] = _brands[index].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    int count = 0;
    for (final id in ids) {
      final index = _brands.indexWhere((b) => b.id == id && !b.isDeleted);
      if (index != -1) {
        // Проверка: есть ли телефоны этого бренда?
        if (_hasPhones(id)) {
          final phonesCount = _countPhones(id);
          throw StateError('Невозможно удалить бренд ID $id: есть $phonesCount связанных телефон(ов)');
        }
        _brands[index] = _brands[index].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    return count;
  }
}
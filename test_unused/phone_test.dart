import 'package:flutter_test/flutter_test.dart';
import 'package:onlyphones_shop/models/phone.dart';
import 'package:onlyphones_shop/models/brand.dart';

void main() {
  group('Phone.fromJson', () {
    test('корректно разбирает полный JSON', () {
      final phone = Phone.fromJson({
        'id': 1,
        'model': 'iPhone 15',
        'brandId': 1,
        'price': 999.0,
        'storage': 256,
        'ram': 8,
        'stock': 10,
        'createdAt': '2026-01-01T00:00:00.000Z',
      });
      expect(phone.model, 'iPhone 15');
      expect(phone.price, 999.0);
      expect(phone.storage, 256);
    });

    test('отсутствующие поля не приводят к исключению', () {
      final phone = Phone.fromJson({'id': 1});
      expect(phone.model, '');
      expect(phone.price, 0.0);
      expect(phone.stock, 0);
    });
  });

  group('Phone.toJson / fromJson', () {
    test('round-trip сохраняет данные', () {
      final original = Phone(
        id: 5,
        model: 'Pixel 8',
        brandId: 4,
        price: 699.0,
        storage: 128,
        ram: 8,
        color: 'Hazel',
        screenSize: 6.2,
        stock: 14,
        createdAt: DateTime(2026, 1, 1),
      );
      final json = original.toJson();
      final restored = Phone.fromJson(json);
      expect(restored.model, original.model);
      expect(restored.price, original.price);
      expect(restored.storage, original.storage);
    });
  });

  group('Brand.fromJson', () {
    test('корректно разбирает JSON', () {
      final brand = Brand.fromJson({
        'id': 1,
        'name': 'Apple',
        'country': 'USA',
        'foundedYear': 1976,
      });
      expect(brand.name, 'Apple');
      expect(brand.country, 'USA');
    });

    test('устойчив к отсутствующим полям', () {
      final brand = Brand.fromJson({});
      expect(brand.name, '');
      expect(brand.country, '');
    });
  });
}
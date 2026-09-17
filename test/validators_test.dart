import 'package:flutter_test/flutter_test.dart';
import 'package:onlyphones_shop/models/validators.dart';

void main() {
  group('Валидатор обязательного поля', () {
    test('пустая строка отклоняется', () {
      expect(requiredValidator(''), isNotNull);
      expect(requiredValidator('   '), isNotNull);
      expect(requiredValidator(null), isNotNull);
    });

    test('непустая строка принимается', () {
      expect(requiredValidator('iPhone 15'), isNull);
    });
  });

  group('Валидатор email', () {
    test('корректный email принимается', () {
      expect(emailValidator('user@example.com'), isNull);
    });

    test('некорректный email отклоняется', () {
      expect(emailValidator('not-an-email'), isNotNull);
      expect(emailValidator(''), isNotNull);
      expect(emailValidator(null), isNotNull);
    });
  });

  group('Валидатор положительного числа', () {
    test('положительное число принимается', () {
      expect(positiveNumberValidator('100'), isNull);
      expect(positiveNumberValidator('99.5'), isNull);
    });

    test('ноль и отрицательное отклоняются', () {
      expect(positiveNumberValidator('0'), isNotNull);
      expect(positiveNumberValidator('-5'), isNotNull);
    });

    test('нечисловое значение отклоняется', () {
      expect(positiveNumberValidator('abc'), isNotNull);
    });
  });

  group('Валидатор целого числа', () {
    test('целое число принимается', () {
      expect(integerValidator('42'), isNull);
    });

    test('отрицательное отклоняется', () {
      expect(integerValidator('-1'), isNotNull);
    });
  });
}
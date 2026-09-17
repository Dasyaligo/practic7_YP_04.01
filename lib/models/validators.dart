import '../models/customer.dart'; 

String? requiredValidator(String? value, {String fieldName = 'Поле'}) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName обязательно для заполнения';
  }
  return null;
}

String? minLengthValidator(String? value, int minLength, {String fieldName = 'Поле'}) {
  if (value != null && value.trim().length < minLength) {
    return '$fieldName должно содержать не менее $minLength символов';
  }
  return null;
}

String? maxLengthValidator(String? value, int maxLength, {String fieldName = 'Поле'}) {
  if (value != null && value.trim().length > maxLength) {
    return '$fieldName не должно превышать $maxLength символов';
  }
  return null;
}

String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Введите email';
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!regex.hasMatch(value.trim())) return 'Введите корректный email';
  return null;
}

String? phoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Введите номер телефона';
  final regex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
  if (!regex.hasMatch(value.trim())) return 'Введите корректный номер телефона';
  return null;
}

String? positiveNumberValidator(String? value, {String fieldName = 'Число'}) {
  if (value == null || value.trim().isEmpty) return '$fieldName обязательно для заполнения';
  final num = double.tryParse(value.trim().replaceAll(',', '.'));
  if (num == null) return 'Введите корректное число';
  if (num <= 0) return '$fieldName должно быть больше нуля';
  return null;
}

String? integerValidator(String? value, {String fieldName = 'Число'}) {
  if (value == null || value.trim().isEmpty) return '$fieldName обязательно для заполнения';
  final num = int.tryParse(value.trim());
  if (num == null) return 'Введите целое число';
  if (num < 0) return '$fieldName не может быть отрицательным';
  return null;
}

String? selectionValidator<T>(T? value, {String fieldName = 'Выбор'}) {
  if (value == null) return 'Выберите $fieldName';
  return null;
}

String? uniqueEmailValidator(String? value, List<Customer> customers, int? currentId) {
  if (value == null || value.trim().isEmpty) return null;
  final duplicate = customers.any((c) =>
      c.email.toLowerCase() == value.trim().toLowerCase() && c.id != currentId);
  if (duplicate) return 'Этот email уже зарегистрирован';
  return null;
}
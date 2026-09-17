import 'package:flutter/material.dart';

class FormFieldConfig {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool required;
  final bool isNumber;
  final bool isEmail;
  final bool isPhone;
  final int? minLength;
  final int? maxLength;
  final double? min;
  final double? max;
  final String? Function(String?)? customValidator;

  const FormFieldConfig({
    required this.label,
    this.hint,
    required this.controller,
    this.required = false,
    this.isNumber = false,
    this.isEmail = false,
    this.isPhone = false,
    this.minLength,
    this.maxLength,
    this.min,
    this.max,
    this.customValidator,
  });
}

class FormFieldBuilder extends StatelessWidget {
  final List<FormFieldConfig> fields;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final String submitLabel;
  final bool isLoading;

  const FormFieldBuilder({
    super.key,
    required this.fields,
    required this.formKey,
    required this.onSave,
    required this.submitLabel,
    this.isLoading = false,
  });

  // 👇 ИСПРАВЛЕНО: возвращаем функцию-валидатор
  String? Function(String?)? _buildValidator(FormFieldConfig field) {
    return (String? value) {
      // Обязательное поле
      if (field.required) {
        if (value == null || value.trim().isEmpty) {
          return '${field.label} обязательно для заполнения';
        }
      }

      // Проверка email
      if (field.isEmail && value != null && value.isNotEmpty) {
        final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        if (!regex.hasMatch(value.trim())) {
          return 'Введите корректный email';
        }
      }

      // Проверка телефона
      if (field.isPhone && value != null && value.isNotEmpty) {
        final regex = RegExp(r'^\+?[\d\s\-\(\)]{10,15}$');
        if (!regex.hasMatch(value.trim())) {
          return 'Введите корректный номер телефона';
        }
      }

      // Проверка числа
      if (field.isNumber && value != null && value.isNotEmpty) {
        final num = double.tryParse(value.trim().replaceAll(',', '.'));
        if (num == null) return 'Введите корректное число';
        if (field.min != null && num < field.min!) {
          return '${field.label} не может быть меньше ${field.min}';
        }
        if (field.max != null && num > field.max!) {
          return '${field.label} не может быть больше ${field.max}';
        }
      }

      // Минимальная длина строки
      if (field.minLength != null && value != null) {
        if (value.trim().length < field.minLength!) {
          return '${field.label} должно содержать не менее ${field.minLength} символов';
        }
      }

      // Максимальная длина строки
      if (field.maxLength != null && value != null) {
        if (value.trim().length > field.maxLength!) {
          return '${field.label} не должно превышать ${field.maxLength} символов';
        }
      }

      // Пользовательский валидатор
      if (field.customValidator != null) {
        return field.customValidator!(value);
      }

      return null;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          ...fields.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: field.controller,
                decoration: InputDecoration(
                  labelText: field.label,
                  hintText: field.hint,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: field.isNumber ? TextInputType.number : TextInputType.text,
                validator: _buildValidator(field), // теперь работает
              ),
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}
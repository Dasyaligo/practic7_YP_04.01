import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/phone.dart';
import '../models/brand.dart';
import '../models/validators.dart';
import '../repositories/phone_repository.dart';
import '../repositories/brand_repository.dart';

class PhoneFormScreen extends StatefulWidget {
  final int? id;
  const PhoneFormScreen({super.key, this.id});
  bool get isEditing => id != null;

  @override
  State<PhoneFormScreen> createState() => _PhoneFormScreenState();
}

class _PhoneFormScreenState extends State<PhoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;
  Phone? _phone;
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _storageController = TextEditingController();
  final _ramController = TextEditingController();
  final _colorController = TextEditingController();
  final _screenSizeController = TextEditingController();
  final _stockController = TextEditingController();
  int? _brandId;
  List<Brand> _brands = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _addListeners();
  }

  void _addListeners() {
    final controllers = [
      _modelController,
      _priceController,
      _storageController,
      _ramController,
      _colorController,
      _screenSizeController,
      _stockController,
    ];
    for (var c in controllers) {
      c.addListener(() {
        if (!_hasChanges) setState(() => _hasChanges = true);
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final brandRepo = context.read<BrandRepository>();
      final brandResult = await brandRepo.find(
        const BrandQuery(page: 1, size: 100, includeDeleted: false),
      );
      if (mounted) _brands = brandResult.items;

      if (widget.isEditing) {
        final phoneRepo = context.read<PhoneRepository>();
        final phone = await phoneRepo.findById(widget.id!);
        if (phone != null && mounted) {
          _phone = phone;
          _modelController.text = phone.model;
          _priceController.text = phone.price.toString();
          _storageController.text = phone.storage?.toString() ?? '';
          _ramController.text = phone.ram?.toString() ?? '';
          _colorController.text = phone.color ?? '';
          _screenSizeController.text = phone.screenSize?.toString() ?? '';
          _stockController.text = phone.stock.toString();
          _brandId = phone.brandId;
          _hasChanges = false;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_brandId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите бренд')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final phone = Phone(
      id: widget.id ?? 0,
      model: _modelController.text.trim(),
      brandId: _brandId!,
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
      storage: int.tryParse(_storageController.text.trim()),
      ram: int.tryParse(_ramController.text.trim()),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
      screenSize:
          double.tryParse(_screenSizeController.text.replaceAll(',', '.')),
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      createdAt: _phone?.createdAt ?? DateTime.now(),
    );

    try {
      final repo = context.read<PhoneRepository>();
      if (widget.isEditing) {
        await repo.update(phone);
      } else {
        await repo.create(phone);
      }
      if (!mounted) return;
      context.go('/phones');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Несохранённые изменения'),
        content: const Text(
            'Вы уверены, что хотите покинуть страницу? Все изменения будут потеряны.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(false),
              child: const Text('Нет')),
          TextButton(
              onPressed: () => Navigator.of(c).pop(true),
              child: const Text('Да, уйти')),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing
              ? 'Редактировать телефон'
              : 'Новый телефон 💗'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(labelText: 'Модель'),
                        validator: (v) =>
                            requiredValidator(v, fieldName: 'Модель'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _brandId,
                        decoration: const InputDecoration(
                          labelText: 'Бренд',
                          border: OutlineInputBorder(),
                        ),
                        items: _brands
                            .map((b) => DropdownMenuItem(
                                  value: b.id,
                                  child: Text(b.name),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _brandId = v;
                          _hasChanges = true;
                        }),
                        validator: (v) => v == null ? 'Выберите бренд' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration:
                            const InputDecoration(labelText: 'Цена (USD)'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            positiveNumberValidator(v, fieldName: 'Цена'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _storageController,
                        decoration:
                            const InputDecoration(labelText: 'Память (ГБ)'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            integerValidator(v, fieldName: 'Память'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ramController,
                        decoration:
                            const InputDecoration(labelText: 'ОЗУ (ГБ)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _colorController,
                        decoration: const InputDecoration(labelText: 'Цвет'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _screenSizeController,
                        decoration: const InputDecoration(
                            labelText: 'Экран (дюймы)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                            labelText: 'В наличии (шт.)'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            integerValidator(v, fieldName: 'Количество'),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(widget.isEditing
                                  ? 'Сохранить'
                                  : 'Создать'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
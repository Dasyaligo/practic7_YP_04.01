import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/accessory.dart';
import '../models/validators.dart';
import '../repositories/accessory_repository.dart';

class AccessoryFormScreen extends StatefulWidget {
  final int? id;
  const AccessoryFormScreen({super.key, this.id});
  bool get isEditing => id != null;

  @override
  State<AccessoryFormScreen> createState() => _AccessoryFormScreenState();
}

class _AccessoryFormScreenState extends State<AccessoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _addListeners();
  }

  void _addListeners() {
    final controllers = [
      _nameController,
      _categoryController,
      _priceController,
      _descriptionController,
    ];
    for (var c in controllers) {
      c.addListener(() {
        if (!_hasChanges) setState(() => _hasChanges = true);
      });
    }
  }

  Future<void> _loadData() async {
    if (widget.isEditing) {
      setState(() => _isLoading = true);
      try {
        final repo = context.read<AccessoryRepository>();
        final accessory = await repo.findById(widget.id!);
        if (accessory != null && mounted) {
          _nameController.text = accessory.name;
          _categoryController.text = accessory.category;
          _priceController.text = accessory.price.toString();
          _descriptionController.text = accessory.description ?? '';
          _hasChanges = false;
        }
      } catch (e) {
        debugPrint('Ошибка загрузки: $e');
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final accessory = Accessory(
      id: widget.id ?? 0,
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
    );

    try {
      final repo = context.read<AccessoryRepository>();
      if (widget.isEditing) {
        await repo.update(accessory);
      } else {
        await repo.create(accessory);
      }
      _hasChanges = false;
      if (!mounted) return;
      context.go('/accessories');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    }
  }

  Future<bool> _showLeaveConfirmation() async {
    if (!_hasChanges) return true;
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Несохранённые изменения'),
        content: const Text('Вы уверены, что хотите покинуть страницу?'),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final shouldPop = await _showLeaveConfirmation();
            if (shouldPop && mounted) Navigator.of(context).pop();
          },
          tooltip: 'Назад',
        ),
        title: Text(widget.isEditing
            ? 'Редактировать аксессуар'
            : 'Новый аксессуар 💗'),
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
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Название'),
                      validator: (v) =>
                          requiredValidator(v, fieldName: 'Название'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(labelText: 'Категория'),
                      validator: (v) =>
                          requiredValidator(v, fieldName: 'Категория'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Цена (USD)'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          positiveNumberValidator(v, fieldName: 'Цена'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Описание'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(widget.isEditing ? 'Сохранить' : 'Создать'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
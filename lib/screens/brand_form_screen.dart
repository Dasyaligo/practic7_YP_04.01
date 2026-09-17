import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/brand.dart';
import '../models/validators.dart';
import '../repositories/brand_repository.dart';

class BrandFormScreen extends StatefulWidget {
  final int? id;
  const BrandFormScreen({super.key, this.id});
  bool get isEditing => id != null;

  @override
  State<BrandFormScreen> createState() => _BrandFormScreenState();
}

class _BrandFormScreenState extends State<BrandFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;
  final _nameController = TextEditingController();
  final _countryController = TextEditingController();
  final _foundedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _addListeners();
  }

  void _addListeners() {
    final controllers = [_nameController, _countryController, _foundedController];
    for (var c in controllers) {
      c.addListener(() {
        if (!_hasChanges) {
          setState(() => _hasChanges = true);
        }
      });
    }
  }

  Future<void> _loadData() async {
    if (widget.isEditing) {
      setState(() => _isLoading = true);
      try {
        final repo = context.read<BrandRepository>();
        final brand = await repo.findById(widget.id!);
        if (brand != null && mounted) {
          _nameController.text = brand.name;
          _countryController.text = brand.country;
          _foundedController.text = brand.foundedYear?.toString() ?? '';
          _hasChanges = false;
        }
      } catch (e) {
        print('Ошибка загрузки: $e');
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final brand = Brand(
      id: widget.id ?? 0,
      name: _nameController.text.trim(),
      country: _countryController.text.trim(),
      foundedYear: int.tryParse(_foundedController.text.trim()),
    );

    try {
      final repo = context.read<BrandRepository>();
      if (widget.isEditing) {
        await repo.update(brand);
      } else {
        await repo.create(brand);
      }
      _hasChanges = false;
      if (!mounted) return;
      context.go('/brands');
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
        content: const Text('Вы уверены, что хотите покинуть страницу? Все изменения будут потеряны.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Нет')),
          TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Да, уйти')),
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
            if (shouldPop && mounted) {
              Navigator.of(context).pop();
            }
          },
          tooltip: 'Назад',
        ),
        title: Text(widget.isEditing ? 'Редактировать бренд' : 'Новый бренд 💗'),
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
                      validator: (v) => requiredValidator(v, fieldName: 'Название'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: 'Страна'),
                      validator: (v) => requiredValidator(v, fieldName: 'Страна'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _foundedController,
                      decoration: const InputDecoration(labelText: 'Год основания'),
                      keyboardType: TextInputType.number,
                      validator: (v) => integerValidator(v, fieldName: 'Год'),
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
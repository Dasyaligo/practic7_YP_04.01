import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/review.dart';
import '../models/customer.dart';
import '../models/phone.dart';
import '../models/phone_query.dart';
import '../repositories/review_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/phone_repository.dart';

class ReviewFormScreen extends StatefulWidget {
  final int? id;
  const ReviewFormScreen({super.key, this.id});
  bool get isEditing => id != null;

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;
  Review? _review;

  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();

  int? _customerId;
  int? _phoneId;

  List<Customer> _customers = [];
  List<Phone> _phones = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _addListeners();
  }

  void _addListeners() {
    final controllers = [_ratingController, _commentController];
    for (var c in controllers) {
      c.addListener(() {
        if (!_hasChanges) setState(() => _hasChanges = true);
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final customerRepo = context.read<CustomerRepository>();
      final phoneRepo = context.read<PhoneRepository>();

      final customersResult = await customerRepo.find(
        const CustomerQuery(page: 1, size: 100, includeDeleted: false),
      );
      if (mounted) _customers = customersResult.items;

      final phonesResult = await phoneRepo.find(
        const PhoneQuery(page: 1, size: 100, includeDeleted: false),
      );
      if (mounted) _phones = phonesResult.items;

      if (widget.isEditing) {
        final reviewRepo = context.read<ReviewRepository>();
        final review = await reviewRepo.findById(widget.id!);
        if (review != null && mounted) {
          _review = review;
          _customerId = review.customerId;
          _phoneId = review.phoneId;
          _ratingController.text = review.rating.toString();
          _commentController.text = review.comment;
          _hasChanges = false;
        }
      }
    } catch (e) {
      debugPrint('Ошибка загрузки: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите покупателя')),
      );
      return;
    }
    if (_phoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите телефон')),
      );
      return;
    }
    setState(() => _isLoading = true);

    final review = Review(
      id: widget.id ?? 0,
      customerId: _customerId!,
      phoneId: _phoneId!,
      rating: int.tryParse(_ratingController.text.trim()) ?? 0,
      comment: _commentController.text.trim(),
      date: _review?.date ?? DateTime.now(),
    );

    try {
      final repo = context.read<ReviewRepository>();
      if (widget.isEditing) {
        await repo.update(review);
      } else {
        await repo.create(review);
      }
      _hasChanges = false;
      if (!mounted) return;
      context.go('/reviews');
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

  String? _ratingValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Укажите оценку';
    final n = int.tryParse(value.trim());
    if (n == null) return 'Введите целое число';
    if (n < 1 || n > 5) return 'Оценка от 1 до 5';
    return null;
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
            ? 'Редактировать отзыв'
            : 'Новый отзыв 💗'),
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
                    DropdownButtonFormField<int>(
                      value: _customerId,
                      decoration: const InputDecoration(
                        labelText: 'Покупатель',
                        border: OutlineInputBorder(),
                      ),
                      items: _customers
                          .map((c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.fullName),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _customerId = v;
                        _hasChanges = true;
                      }),
                      validator: (v) =>
                          v == null ? 'Выберите покупателя' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _phoneId,
                      decoration: const InputDecoration(
                        labelText: 'Телефон',
                        border: OutlineInputBorder(),
                      ),
                      items: _phones
                          .map((p) => DropdownMenuItem(
                                value: p.id,
                                child: Text(p.model),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _phoneId = v;
                        _hasChanges = true;
                      }),
                      validator: (v) => v == null ? 'Выберите телефон' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ratingController,
                      decoration:
                          const InputDecoration(labelText: 'Оценка (1–5)'),
                      keyboardType: TextInputType.number,
                      validator: _ratingValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _commentController,
                      decoration:
                          const InputDecoration(labelText: 'Комментарий'),
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
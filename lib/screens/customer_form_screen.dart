import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/customer.dart';
import '../models/loyalty_card.dart';
import '../models/validators.dart';
import '../repositories/customer_repository.dart';
import '../repositories/loyalty_card_repository.dart';

class CustomerFormScreen extends StatefulWidget {
  final int? id;
  const CustomerFormScreen({super.key, this.id});
  bool get isEditing => id != null;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;
  Customer? _customer;
  List<Customer> _customers = [];

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _pointsController = TextEditingController();
  bool _hasLoyaltyCard = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _addListeners();
  }

  void _addListeners() {
    final controllers = [
      _nameController,
      _emailController,
      _phoneController,
      _cardNumberController,
      _pointsController,
    ];
    for (var c in controllers) {
      c.addListener(() {
        if (!_hasChanges) {
          setState(() => _hasChanges = true);
        }
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final customerRepo = context.read<CustomerRepository>();
      final allCustomers = await customerRepo.find(
        const CustomerQuery(page: 1, size: 100, includeDeleted: true),
      );
      if (mounted) _customers = allCustomers.items;

      if (widget.isEditing) {
        final customer = await customerRepo.findById(widget.id!);
        if (customer != null && mounted) {
          _customer = customer;
          _nameController.text = customer.fullName;
          _emailController.text = customer.email;
          _phoneController.text = customer.phone;
          _cardNumberController.text = 'LC-${customer.id.toString().padLeft(4, '0')}';
          _pointsController.text = customer.loyaltyPoints.toString();
          _hasLoyaltyCard = customer.loyaltyCardId != null;
          _hasChanges = false;
        }
      }
    } catch (e) {
      print('Ошибка загрузки: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  String? _validateEmail(String? value) {
    final baseError = emailValidator(value);
    if (baseError != null) return baseError;
    if (value == null || value.trim().isEmpty) return null;

    final duplicate = _customers.any((c) =>
        c.email.toLowerCase() == value.trim().toLowerCase() &&
        c.id != (widget.id ?? -1) &&
        !c.isDeleted);
    if (duplicate) return 'Этот email уже зарегистрирован';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final customerRepo = context.read<CustomerRepository>();
      final cardRepo = context.read<LoyaltyCardRepository>();

      Customer customer;
      if (widget.isEditing) {
        customer = _customer!.copyWith(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
        );
        await customerRepo.update(customer);
      } else {
        customer = Customer(
          id: 0,
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          createdAt: DateTime.now(),
        );
        customer = await customerRepo.create(customer);
      }

      if (_hasLoyaltyCard && _cardNumberController.text.trim().isNotEmpty) {
        final card = LoyaltyCard(
          id: 0,
          customerId: customer.id,
          cardNumber: _cardNumberController.text.trim(),
          points: int.tryParse(_pointsController.text.trim()) ?? 0,
          issuedAt: DateTime.now(),
        );
        await cardRepo.create(card);
      }

      _hasChanges = false;
      if (!mounted) return;
      context.go('/customers');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка сохранения: $e')),
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
        title: Text(widget.isEditing ? 'Редактировать покупателя' : 'Новый покупатель 💗'),
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
                      decoration: const InputDecoration(labelText: 'ФИО'),
                      validator: (v) => requiredValidator(v, fieldName: 'ФИО'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Телефон'),
                      keyboardType: TextInputType.phone,
                      validator: (v) => phoneValidator(v),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    Row(
                      children: [
                        Checkbox(
                          value: _hasLoyaltyCard,
                          onChanged: (v) => setState(() {
                            _hasLoyaltyCard = v ?? true;
                            _hasChanges = true;
                          }),
                        ),
                        const Text('Есть карта лояльности'),
                      ],
                    ),
                    if (_hasLoyaltyCard) ...[
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(labelText: 'Номер карты'),
                        validator: (v) => requiredValidator(v, fieldName: 'Номер карты'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _pointsController,
                        decoration: const InputDecoration(labelText: 'Баллы'),
                        keyboardType: TextInputType.number,
                        validator: (v) => integerValidator(v, fieldName: 'Баллы'),
                      ),
                    ],
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


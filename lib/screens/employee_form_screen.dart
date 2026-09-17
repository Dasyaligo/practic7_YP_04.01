import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/employee.dart';
import '../models/validators.dart';
import '../repositories/employee_repository.dart';

class EmployeeFormScreen extends StatefulWidget {
  final int? id;
  const EmployeeFormScreen({super.key, this.id});
  bool get isEditing => id != null;

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _hasChanges = false;
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final _emailController = TextEditingController();
  final _salaryController = TextEditingController();
  Employee? _employee;

  @override
  void initState() {
    super.initState();
    _loadData();
    _addListeners();
  }

  void _addListeners() {
    final controllers = [
      _nameController,
      _positionController,
      _emailController,
      _salaryController,
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
        final repo = context.read<EmployeeRepository>();
        final employee = await repo.findById(widget.id!);
        if (employee != null && mounted) {
          _employee = employee;
          _nameController.text = employee.fullName;
          _positionController.text = employee.position;
          _emailController.text = employee.email;
          _salaryController.text = employee.salary.toString();
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

    final employee = Employee(
      id: widget.id ?? 0,
      fullName: _nameController.text.trim(),
      position: _positionController.text.trim(),
      email: _emailController.text.trim(),
      salary: double.tryParse(_salaryController.text.replaceAll(',', '.')) ?? 0,
      hiredAt: _employee?.hiredAt ?? DateTime.now(),
    );

    try {
      final repo = context.read<EmployeeRepository>();
      if (widget.isEditing) {
        await repo.update(employee);
      } else {
        await repo.create(employee);
      }
      _hasChanges = false;
      if (!mounted) return;
      context.go('/employees');
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
            ? 'Редактировать сотрудника'
            : 'Новый сотрудник 💗'),
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
                      controller: _positionController,
                      decoration: const InputDecoration(labelText: 'Должность'),
                      validator: (v) =>
                          requiredValidator(v, fieldName: 'Должность'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => emailValidator(v),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _salaryController,
                      decoration: const InputDecoration(labelText: 'Зарплата'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          positiveNumberValidator(v, fieldName: 'Зарплата'),
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
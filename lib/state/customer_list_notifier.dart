import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/page_result.dart';
import '../repositories/customer_repository.dart';
import 'load_status.dart';

class CustomerListNotifier extends ChangeNotifier {
  final CustomerRepository _repository;

  CustomerListNotifier(this._repository) {
    _load();
  }

  CustomerQuery _query = const CustomerQuery();
  PageResult<Customer> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  CustomerQuery get query => _query;
  PageResult<Customer> get result => _result;
  LoadStatus get status => _status;
  String? get error => _error;
  Set<int> get selected => Set.unmodifiable(_selected);
  bool get hasSelection => _selected.isNotEmpty;

  Future<void> _load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _result = await _repository.find(_query);
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Не удалось загрузить список: $e';
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<void> applyQuery(CustomerQuery next) async {
    _query = next;
    _selected.clear();
    await _load();
  }

  void toggleSelection(int id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    if (_selected.isEmpty) return;
    await _repository.deleteMany(_selected.toList());
    _selected.clear();
    await _load();
  }

  Future<void> softDelete(int id) async {
    await _repository.softDelete(id);
    await _load();
  }

  Future<void> hardDelete(int id) async {
    await _repository.hardDelete(id);
    await _load();
  }

  Future<void> restore(int id) async {
    await _repository.restore(id);
    await _load();
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }
}
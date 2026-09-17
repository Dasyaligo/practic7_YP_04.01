import 'package:flutter/material.dart';
import '../models/phone.dart';
import '../models/phone_query.dart';
import '../models/page_result.dart';
import '../repositories/phone_repository.dart';
import 'load_status.dart';

class PhoneListNotifier extends ChangeNotifier {
  final PhoneRepository _repository;

  PhoneListNotifier(this._repository) {
    _load();
  }

  PhoneQuery _query = const PhoneQuery();
  PageResult<Phone> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  PhoneQuery get query => _query;
  PageResult<Phone> get result => _result;
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

  Future<void> applyQuery(PhoneQuery next) async {
    _query = next;
    _selected.clear();
    await _load();
  }

  void toggleSelection(int id) {
    _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
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
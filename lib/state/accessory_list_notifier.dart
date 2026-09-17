import 'package:flutter/material.dart';
import '../models/accessory.dart';
import '../models/page_result.dart';
import '../repositories/accessory_repository.dart';
import 'load_status.dart';

class AccessoryListNotifier extends ChangeNotifier {
  final AccessoryRepository _repository;

  AccessoryListNotifier(this._repository) {
    _load();
  }

  AccessoryQuery _query = const AccessoryQuery();
  PageResult<Accessory> _result = PageResult.empty();
  LoadStatus _status = LoadStatus.idle;
  String? _error;
  final Set<int> _selected = {};

  AccessoryQuery get query => _query;
  PageResult<Accessory> get result => _result;
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

  Future<void> applyQuery(AccessoryQuery next) async {
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
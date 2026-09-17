import '../models/employee.dart';
import '../models/page_result.dart';

class EmployeeQuery {
  final String search;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const EmployeeQuery({
    this.search = '',
    this.sortField = 'full_name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  EmployeeQuery copyWith({
    String? search,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return EmployeeQuery(
      search: search ?? this.search,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }
}

abstract interface class EmployeeRepository {
  Future<PageResult<Employee>> find(EmployeeQuery query);
  Future<Employee?> findById(int id);
  Future<Employee> create(Employee employee);
  Future<Employee> update(Employee employee);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
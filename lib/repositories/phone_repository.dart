import '../models/phone.dart';
import '../models/phone_query.dart';
import '../models/page_result.dart';

abstract interface class PhoneRepository {
  Future<PageResult<Phone>> find(PhoneQuery query);
  Future<Phone?> findById(int id);
  Future<Phone> create(Phone phone);
  Future<Phone> update(Phone phone);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> deleteMany(List<int> ids);
}
import '../models/page_result.dart';
import '../models/photographer.dart';
import '../models/photographer_query.dart';

abstract interface class PhotographerRepository {
  Future<PageResult<Photographer>> find(PhotographerQuery query);
  Future<Photographer?> findById(int id);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
  Future<int> softDeleteMany(List<int> ids);
  Future<int> hardDeleteMany(List<int> ids);
}

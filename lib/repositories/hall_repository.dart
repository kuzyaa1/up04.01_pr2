import '../models/hall_query.dart';
import '../models/page_result.dart';
import '../models/studio_hall.dart';
abstract interface class HallRepository {
  Future<PageResult<StudioHall>> find(HallQuery query);
  Future<StudioHall?> findById(int id);
  Future<void> softDelete(int id); Future<void> hardDelete(int id); Future<void> restore(int id);
  Future<int> softDeleteMany(List<int> ids); Future<int> hardDeleteMany(List<int> ids);
}

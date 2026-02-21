import 'package:hive_ce/hive.dart';
import 'sync_queue_item.dart';

/// Hive TypeAdapter for SyncQueueItem
/// Story 0.9: Implement Offline-First Sync Architecture Foundation
///
/// Allows SyncQueueItem to be stored in Hive database.
/// TypeId 8 is reserved for SyncQueueItem.
class SyncQueueItemAdapter extends TypeAdapter<SyncQueueItem> {
  @override
  final int typeId = 8; // Unique typeId for SyncQueueItem

  @override
  SyncQueueItem read(BinaryReader reader) {
    final json = reader.readMap().cast<String, dynamic>();
    return SyncQueueItem.fromJson(json);
  }

  @override
  void write(BinaryWriter writer, SyncQueueItem obj) {
    writer.writeMap(obj.toJson());
  }
}

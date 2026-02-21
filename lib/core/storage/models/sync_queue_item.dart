import 'package:hive_ce/hive.dart';

part 'sync_queue_item.g.dart';

/// SyncQueueItem - Modèle simple pour queue de sync
///
/// Stocké dans: sync_queue_box (non-chiffré)
/// Hive TypeId: 6
@HiveType(typeId: 6)
class SyncQueueItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String operation;

  @HiveField(2)
  final String collection;

  @HiveField(3)
  final Map<String, dynamic> data;

  @HiveField(4)
  final DateTime queuedAt;

  @HiveField(5)
  final int retryCount;

  SyncQueueItem({
    required this.id,
    required this.operation,
    required this.collection,
    required this.data,
    required this.queuedAt,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'operation': operation,
        'collection': collection,
        'data': data,
        'queuedAt': queuedAt.toIso8601String(),
        'retryCount': retryCount,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        id: json['id'] as String,
        operation: json['operation'] as String,
        collection: json['collection'] as String,
        data: Map<String, dynamic>.from(json['data'] as Map),
        queuedAt: DateTime.parse(json['queuedAt'] as String),
        retryCount: json['retryCount'] as int? ?? 0,
      );
}

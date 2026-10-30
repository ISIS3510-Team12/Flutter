import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_status.freezed.dart';

@freezed
abstract class SyncStatus with _$SyncStatus {
  const factory SyncStatus({
    @Default(0) int pendingCount,
    @Default(0) int failedCount,
    @Default(false) bool isSyncing,
    DateTime? lastSyncedAt,
    String? message,
  }) = _SyncStatus;
}

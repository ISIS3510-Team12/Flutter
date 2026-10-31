import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:team12_flutter_juggle/data/local/task_codec.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_location.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

part 'pending_op.freezed.dart';

enum PendingOpType { createTask, saveLocation }

enum PendingOpStatus { pending, failed }

@freezed
abstract class PendingOp with _$PendingOp {
  const PendingOp._();

  const factory PendingOp({
    required String id,
    required String userId,
    required PendingOpType type,
    required Map<String, dynamic> payload,
    required DateTime createdAt,
    @Default(0) int attempts,
    DateTime? nextAttemptAt,
    @Default(PendingOpStatus.pending) PendingOpStatus status,
    String? lastError,
    String? serverTaskId,
    String? photoPath,
    @Default(false) bool verifyFirst,
  }) = _PendingOp;

  factory PendingOp.fromJson(Map<String, dynamic> json) {
    final next = json['nextAttemptAt'] as String?;
    return PendingOp(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: PendingOpType.values.byName(json['type'] as String),
      payload: Map<String, dynamic>.from(json['payload'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      attempts: json['attempts'] as int? ?? 0,
      nextAttemptAt: next == null ? null : DateTime.parse(next).toLocal(),
      status: PendingOpStatus.values.byName(json['status'] as String),
      lastError: json['lastError'] as String?,
      serverTaskId: json['serverTaskId'] as String?,
      photoPath: json['photoPath'] as String?,
      verifyFirst: json['verifyFirst'] as bool? ?? false,
    );
  }

  bool get isTask => type == PendingOpType.createTask;

  Task get task => taskFromJson(payload);

  UserLocation get location => UserLocation.fromJson(payload);

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'payload': payload,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'attempts': attempts,
    'nextAttemptAt': nextAttemptAt?.toUtc().toIso8601String(),
    'status': status.name,
    'lastError': lastError,
    'serverTaskId': serverTaskId,
    'photoPath': photoPath,
    'verifyFirst': verifyFirst,
  };
}

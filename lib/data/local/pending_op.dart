import 'package:team12_flutter_juggle/data/local/task_codec.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

enum PendingOpType { createTask }

enum PendingOpStatus { pending, failed }

class PendingOp {
  const PendingOp({
    required this.id,
    required this.userId,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.nextAttemptAt,
    this.status = PendingOpStatus.pending,
    this.lastError,
    this.serverTaskId,
    this.photoPath,
    this.verifyFirst = false,
  });

  final String id;
  final String userId;
  final PendingOpType type;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final DateTime? nextAttemptAt;
  final PendingOpStatus status;
  final String? lastError;
  final String? serverTaskId;
  final String? photoPath;
  final bool verifyFirst;

  Task get task => taskFromJson(payload);

  PendingOp copyWith({
    int? attempts,
    DateTime? nextAttemptAt,
    PendingOpStatus? status,
    String? lastError,
    String? serverTaskId,
    String? photoPath,
    bool? verifyFirst,
    bool clearPhoto = false,
    bool clearNextAttempt = false,
  }) {
    return PendingOp(
      id: id,
      userId: userId,
      type: type,
      payload: payload,
      createdAt: createdAt,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: clearNextAttempt
          ? null
          : nextAttemptAt ?? this.nextAttemptAt,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      serverTaskId: serverTaskId ?? this.serverTaskId,
      photoPath: clearPhoto ? null : photoPath ?? this.photoPath,
      verifyFirst: verifyFirst ?? this.verifyFirst,
    );
  }

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
}

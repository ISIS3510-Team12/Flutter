import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/domain/models/tasks/task.dart';

extension BoardStatus on TaskStatus {
  String get boardLabel => switch (this) {
    TaskStatus.pending => 'Not started',
    TaskStatus.inProgress => 'In progress',
    TaskStatus.done => 'Completed',
  };

  Color boardColor(ColorScheme scheme) => switch (this) {
    TaskStatus.pending => scheme.outline,
    TaskStatus.inProgress => scheme.primaryContainer,
    TaskStatus.done => scheme.secondary,
  };
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/home/view_models/next_task_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/home/widgets/overview_tabs.dart';

class NextTaskSection extends ConsumerWidget {
  const NextTaskSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nextTaskViewModelProvider).value;
    if (state == null) return const SizedBox.shrink();
    final card = state.card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        const Text(
          'Up next',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        if (card != null)
          CardItem(
            title: card.title,
            icon: Icons.priority_high,
            description: card.subtitle ?? '',
            group: card.flagText,
          )
        else
          Text(
            state.message ?? '',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}

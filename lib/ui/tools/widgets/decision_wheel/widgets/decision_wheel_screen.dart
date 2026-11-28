
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/ui/offline_banner.dart';
import 'package:team12_flutter_juggle/data/db/app_database.dart';
import 'package:team12_flutter_juggle/ui/core/ui/custom_navigation_bar.dart';
import 'package:team12_flutter_juggle/ui/tools/widgets/decision_wheel/view_models/decision_wheel_view_model_provider.dart';
import 'package:team12_flutter_juggle/ui/tools/widgets/decision_wheel/widgets/wheel_editor_screen.dart';
import 'package:team12_flutter_juggle/ui/tools/widgets/decision_wheel/widgets/new_wheel_screen.dart';

class DecisionWheelScreen extends ConsumerWidget {
  const DecisionWheelScreen({super.key});

  static const Color indigo = Color(0xFF5455A9);

  Future<void> _openNewWheel(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NewWheelScreen(),
      ),
    );

    ref.invalidate(decisionWheelViewModelProvider);
  }

  Future<void> _openWheel(
    BuildContext context,
    WidgetRef ref,
    WheelRow wheel,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WheelEditorScreen(wheel: wheel),
      ),
    );

    ref.invalidate(decisionWheelViewModelProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wheelsState = ref.watch(decisionWheelViewModelProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        title: const Text(
          'Decision Wheel',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: wheelsState.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: indigo),
              ),
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Could not load your wheels.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          ref.invalidate(decisionWheelViewModelProvider);
                        },
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (state) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your wheels',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (state.wheels.isEmpty)
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                'Create your first wheel and let it decide for you.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            itemCount: state.wheels.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final wheel = state.wheels[index];

                              return _WheelCard(
                                key: ValueKey(wheel.id),
                                wheel: wheel,
                                onTap: () => _openWheel(
                                  context,
                                  ref,
                                  wheel,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 2,
        onPressed: () => _openNewWheel(context, ref),
        icon: const Icon(Icons.add),
        label: const Text(
          'Create wheel',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(),
    );
  }
}

class _WheelCard extends ConsumerStatefulWidget {
  final WheelRow wheel;
  final VoidCallback onTap;

  const _WheelCard({
    super.key,
    required this.wheel,
    required this.onTap,
  });

  @override
  ConsumerState<_WheelCard> createState() => _WheelCardState();
}

class _WheelCardState extends ConsumerState<_WheelCard> {
  late Future<List<WheelOptionRow>> _optionsFuture;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  void _loadOptions() {
    _optionsFuture = ref
        .read(decisionWheelViewModelProvider.notifier)
        .getOptions(widget.wheel.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 15,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF5455A9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.format_list_bulleted_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.wheel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FutureBuilder<List<WheelOptionRow>>(
                      future: _optionsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            'Loading options...',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Text(
                            'Could not load options',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          );
                        }

                        final count = snapshot.data?.length ?? 0;

                        return Text(
                          '$count ${count == 1 ? 'option' : 'options'}',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.primary,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

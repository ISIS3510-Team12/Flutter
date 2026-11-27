import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/domain/models/calendar/calendar_view_mode.dart';

class CalendarViewToggle extends StatelessWidget {
  const CalendarViewToggle({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CalendarViewMode selected;
  final ValueChanged<CalendarViewMode> onSelected;

  static String _label(CalendarViewMode mode) => switch (mode) {
    CalendarViewMode.week => 'Week',
    CalendarViewMode.month => 'Month',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 6, 20, 2),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final mode in CalendarViewMode.values)
              Semantics(
                button: true,
                selected: mode == selected,
                child: Material(
                  color: mode == selected ? colors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onSelected(mode),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 88,
                        minHeight: 36,
                      ),
                      child: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: Text(
                          _label(mode),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: mode == selected
                                ? colors.onPrimary
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

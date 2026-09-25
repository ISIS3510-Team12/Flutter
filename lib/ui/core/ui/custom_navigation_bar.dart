import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';

class CustomNavigationBar extends StatelessWidget {
  const CustomNavigationBar({super.key});

  static final items = [
    (Symbols.home, 'Home', Routes.home),
    (Symbols.checklist_rtl, 'Tasks', Routes.tasks),
    (Symbols.groups, 'Groups', null),
    (Symbols.calendar_today, 'Calendar', null),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocation = GoRouterState.of(context).matchedLocation;
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(80),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final route = item.$3;
            final isSelected = route != null && route == currentLocation;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (route != null) context.go(route);
                    },
                    child: Icon(
                      item.$1,
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                      fill: isSelected ? 1 : 0,
                      weight: 700,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  item.$2,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

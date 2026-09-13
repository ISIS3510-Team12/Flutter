import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int selectedIndex = 0;

  final items = [
    (Symbols.home, 'Home'),
    (Symbols.checklist_rtl, 'Tasks'),
    (Symbols.groups, 'Groups'),
    (Symbols.calendar_today, 'Calendar'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            children: List.generate(
              items.length,
              (index) => Column(
                mainAxisSize: .min,
                children: [
                  Container(
                    padding: const .symmetric(horizontal: 17, vertical: 4),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? theme.colorScheme.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Icon(
                        items[index].$1,
                        color: selectedIndex == index
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                        fill: index == selectedIndex ? 1 : 0,
                        weight: 700,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    items[index].$2,
                    style: theme.textTheme.labelSmall?.copyWith(
                          color: selectedIndex == index
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

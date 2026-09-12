import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class CustomNavigationBar extends StatefulWidget {
  const new({super.key});

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
    return Container(
        margin: EdgeInsets.only(left: 16, right: 16, bottom: 16),
        height: 80,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
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
                          ? Theme.of(context).colorScheme.secondaryContainer
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
                        fill: selectedIndex == index ? 1 : 0,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        weight: 700,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    items[index].$2,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }
}

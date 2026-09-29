import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';

class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet({super.key});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final bottomSheetIems = [
    (
      id: 1,
      icon: Symbols.list_alt,
      title: 'Add Task',
      description: 'Create a new task instantly',
    ),
    (
      id: 2,
      icon: Symbols.groups,
      title: 'Create new group',
      description: 'Create a group workspace',
    ),
  ];

  void _onPressed(BuildContext context, int id) {
    Navigator.of(context).pop();
    switch (id) {
      case 1:
        context.go('/home');
        break;
      case 2:
        context.go('/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          ...bottomSheetIems.map((item) {
            return bottomSheetItem(
              context,
              item.icon,
              item.title,
              item.description,
              () => _onPressed(context, item.id),
            );
          }),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget bottomSheetItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 30, left: 30),
      child: Row(
        spacing: 10,
        children: [
          Icon(
            icon,
            fill: 1,
            size: 28,
            color: Theme.of(context).colorScheme.primary,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: .bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: onPressed,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

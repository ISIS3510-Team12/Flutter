import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/domain/models/group/group.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.onClick,
  });

  final Group group;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: const Color(0xFFF5F0EE), // beige claro
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFCFCAC8), // borde gris fino
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onClick,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF3B7A7A), // verde azulado
                child: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                color: Color(0xFF1C1B1F),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
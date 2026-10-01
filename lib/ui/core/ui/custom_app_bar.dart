import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:team12_flutter_juggle/ui/auth/providers/auth_providers.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider);

    return AppBar(
      title: SvgPicture.asset('assets/juggle_logo.svg', height: 44),
      actionsPadding: EdgeInsets.only(right: 16),
      actions: [
        GestureDetector(
          //TODO: Update with @callmecris profile route 
          onTap: () => context.go('/home'),
          child: CircleAvatar(
            maxRadius: 16,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              currentUser.when(
                data: (user) =>
                    user!.firstName.isNotEmpty ? user.firstName[0] : '',
                loading: () => 'A',
                error: (error, stackTrace) => '',
              ),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/domain/models/profile/user_profile.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final UserProfile _profile = UserProfile(
    id: "a",
    firstName: 'Victoria',
    lastName: 'Doe',
    email: '',
    role: '',
    username: 'a',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: SvgPicture.asset('assets/juggle_logo.svg', height: 44),
      actionsPadding: EdgeInsets.only(right: 16),
      actions: [
        GestureDetector(
          onTap: () => context.go('/home'),
          child: CircleAvatar(
            maxRadius: 16,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              _profile.initial,
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

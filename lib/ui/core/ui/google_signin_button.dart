import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:team12_flutter_juggle/ui/core/ui/bottom_auth_options.dart';

class GoogleSigninButton extends StatelessWidget {
  const GoogleSigninButton({super.key, required this.onPressed});
  final GoogleSignInCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.onSurface, width: 0.5),
          ),
        ),
        icon: Image.asset(
          'assets/google_icon.png',
          fit: BoxFit.contain,
          height: 20,
          width: 20,
        ),
        label: Text(
          'Sign in with Google',
          style: theme.textTheme.labelMedium!.copyWith(
            fontFamily: GoogleFonts.googleSans().fontFamily,
            fontWeight: .bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

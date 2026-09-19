import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class GoogleSigninButton extends StatelessWidget {
  const GoogleSigninButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton.icon(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 0.5),
          ),
        ),
        icon: SvgPicture.asset(
          'assets/google_icon.svg',
          fit: BoxFit.contain,
        ),
        label: Text(
          'Sign in with Google',
          style: theme.textTheme.labelMedium!.copyWith(
            fontFamily: GoogleFonts.googleSans().fontFamily,
            fontWeight: .bold,
          )
        ),
      ),
    );
  }
}

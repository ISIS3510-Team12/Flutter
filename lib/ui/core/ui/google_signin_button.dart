import 'package:flutter/material.dart';

class GoogleSigninButton extends StatelessWidget {
  const GoogleSigninButton({super.key});

  @override
  Widget build(BuildContext context) {
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
        icon: Icon(Icons.star_outline, color: Colors.black),
        label: Text(
          'Sign in with Google',
          style: TextStyle(
            color: Colors.black,
            fontWeight: .bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

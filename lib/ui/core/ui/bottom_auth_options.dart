import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/google_signin_button.dart';

class BottomAuthOptions extends StatelessWidget {
  const BottomAuthOptions({super.key, required this.label, required this.buttonText});

  final String label;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: .only(right: 25, left: 25),
      child: Column(
        spacing: 12,
        children: [
          Column(
            children: [
              Divider(color: Colors.grey[400], thickness: 1),
              Text(
                'OR',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: .bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          GoogleSigninButton(),
          const SizedBox(height: 2),
          Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: .w500,
                fontSize: 14,
              ),
            ),
          ),
          Center(
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF585992),
                fixedSize: const Size(100, 40),
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: .bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/auth/signup/widgets/signup_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: theme.canvasColor,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Sign Up', style: theme.textTheme.titleMedium),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SignupForm(formKey: formKey),
    );
  }
}

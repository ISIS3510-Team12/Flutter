import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/bottom_auth_options.dart';
import 'package:team12_flutter_juggle/ui/core/ui/input_field.dart';

class SigninForm extends StatefulWidget {
  const new({super.key, required this.formKey});

  final GlobalKey<FormState> formKey;

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  String? username;
  String? password;

  void _submit() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    widget.formKey.currentState!.save();

    print('Username: $username');
    print('Password: $password');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: .only(left: 15, right: 15, top: 20),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 18,
            children: [
              InputField(
                labelText: 'Username',
                icon: Icons.mood_outlined,
                onSaved: (username) {
                  this.username = username;
                },
              ),
              InputField(
                labelText: 'Password',
                icon: Icons.lock_outline,
                onSaved: (password) {
                  this.password = password;
                },
              ),
              Center(
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF585992),
                    fixedSize: const Size(100, 40),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: .bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: .w500,
                    fontSize: 14,
                  ),
                ),
              ),
              BottomAuthOptions(
                label: 'Dont have an account?',
                buttonText: 'Sign up',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/input_field.dart';
import 'package:team12_flutter_juggle/ui/core/ui/bottom_auth_options.dart';

// TODO: Import Google Icon
// TODO: Refactor this component to make it more readable

class SignupForm extends StatefulWidget {
  const SignupForm({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  String? firstName;
  String? lastName;
  String? username;
  String? email;
  String? password;
  String? confirmPassword;

  void _submit() {
    if (!widget.formKey.currentState!.validate()) {
      return;
    }

    widget.formKey.currentState!.save();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 18,
            children: [
              InputField(
                labelText: 'First Name',
                icon: Icons.person_outline,
                onSaved: (firstName) {
                  this.firstName = firstName;
                },
              ),
              InputField(
                labelText: 'Last Name',
                icon: Icons.person_outline,
                onSaved: (lastName) {
                  this.lastName = lastName;
                },
              ),
              const SizedBox(height: 5),
              InputField(
                labelText: 'Username',
                icon: Icons.mood_outlined,
                onSaved: (username) {
                  this.username = username;
                },
              ),
              InputField(
                labelText: 'Email',
                icon: Icons.email_outlined,
                onSaved: (email) {
                  this.email = email;
                },
              ),
              InputField(
                labelText: 'Password',
                icon: Icons.lock_outline,
                onSaved: (password) {
                  this.password = password;
                },
              ),
              InputField(
                labelText: 'Confirm Password',
                icon: Icons.lock_outline,
                onSaved: (confirmPassword) {
                  this.confirmPassword = confirmPassword;
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
                    'Sign Up',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: .bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              BottomAuthOptions(
                label: 'Already have an account?',
                buttonText: 'Sign in',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

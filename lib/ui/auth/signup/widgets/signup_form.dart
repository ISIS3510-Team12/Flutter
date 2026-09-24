import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/input_field.dart';
import 'package:team12_flutter_juggle/ui/core/ui/bottom_auth_options.dart';
import 'package:go_router/go_router.dart';

typedef SignupCallback = Future<void> Function({
  required String firstName,
  required String lastName,
  required String email,
  required String password,
});

class SignupForm extends StatefulWidget {
  const SignupForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  final bool isLoading;
  final SignupCallback onSubmit;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final formKey = GlobalKey<FormState>();
  String? firstName;
  String? lastName;
  String? email;
  String? password;

  Future<void> _submit() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    form.save();

    await widget.onSubmit(
      firstName: firstName!,
      lastName: lastName!,
      email: email!,
      password: password!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
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
                  print('First Name: $firstName');
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
              Center(
                child: FilledButton(
                  onPressed: widget.isLoading ? null : _submit,
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
                onPressed: () => context.go('/signin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/input_field.dart';
import 'package:team12_flutter_juggle/ui/core/ui/bottom_auth_options.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/utils/validators.dart';
import 'package:flutter/services.dart';

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
    required this.onGoogleSignIn,
  });

  final bool isLoading;
  final SignupCallback onSubmit;
  final GoogleSignInCallback onGoogleSignIn;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final formKey = GlobalKey<FormState>();
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? confirmPassword;
  bool? obscurePassword = true;
  bool? obscureConfirmPassword = true;

  Future<void> _submit() async {
    final form = formKey.currentState;
    if (form == null) {
      return;
    }
    form.save();
    if (!form.validate()) return;

    await widget.onSubmit(
      firstName: firstName!,
      lastName: lastName!,
      email: email!,
      password: password!,
    );
  }

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword!;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      obscureConfirmPassword = !obscureConfirmPassword!;
    });
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
                },
                validator: Validators.name,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
              ),
              InputField(
                labelText: 'Last Name',
                icon: Icons.person_outline,
                onSaved: (lastName) {
                  this.lastName = lastName;
                },
                validator: Validators.name,
                keyboardType: TextInputType.name,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
              ),
              const SizedBox(height: 5),
              InputField(
                labelText: 'Email',
                icon: Icons.email_outlined,
                onSaved: (email) {
                  this.email = email;
                },
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
                ],
              ),
              InputField(
                labelText: 'Password',
                icon: Icons.lock_outline,
                onSaved: (password) {
                  this.password = password;
                },
                validator: Validators.password,
                obscureText: obscurePassword,
                onTogglePasswordVisibility: togglePasswordVisibility,
                keyboardType: TextInputType.visiblePassword,
              ),
              InputField(
                labelText: 'Confirm Password',
                icon: Icons.lock_outline,
                onSaved: (confirmPassword) {
                  this.confirmPassword = confirmPassword;
                },
                validator: (confirmPassword) => Validators.confirmPassword(confirmPassword, password),
                obscureText: obscureConfirmPassword,
                onTogglePasswordVisibility: toggleConfirmPasswordVisibility,
                keyboardType: TextInputType.visiblePassword,
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
                onGoogleSignIn: widget.onGoogleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

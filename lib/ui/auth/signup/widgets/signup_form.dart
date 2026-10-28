import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/input_field.dart';
import 'package:team12_flutter_juggle/ui/core/ui/bottom_auth_options.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/utils/validators.dart';

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
  final confirmKey = GlobalKey<FormFieldState<String>>();
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  Future<void> _submit() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) return;
    form.save();

    await widget.onSubmit(
      firstName: firstName!,
      lastName: lastName!,
      email: email!,
      password: password!,
    );
  }

  void _validateConfirmIfFilled() {
    final confirmField = confirmKey.currentState;
    if (confirmField == null) return;

    final hasConfirmText = confirmField.value?.isNotEmpty ?? false;
    if (hasConfirmText) confirmField.validate();
  }

  void togglePasswordVisibility() {
    setState(() {
      obscurePassword = !obscurePassword;
    });
  }

  void toggleConfirmPasswordVisibility() {
    setState(() {
      obscureConfirmPassword = !obscureConfirmPassword;
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
                onSaved: (value) {
                  firstName = value?.trim();
                },
                validator: Validators.personName,
                keyboardType: TextInputType.name,
                inputFormatters: [Validators.personNameTextInputFormatter],
                maxLength: Validators.maxPersonNameLength,
              ),
              InputField(
                labelText: 'Last Name',
                icon: Icons.person_outline,
                onSaved: (value) {
                  lastName = value?.trim();
                },
                validator: Validators.personName,
                keyboardType: TextInputType.name,
                inputFormatters: [Validators.personNameTextInputFormatter],
                maxLength: Validators.maxPersonNameLength,
              ),
              const SizedBox(height: 5),
              InputField(
                labelText: 'Email',
                icon: Icons.email_outlined,
                onSaved: (value) {
                  email = value?.trim();
                },
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [Validators.emailTextInputFormatter],
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              InputField(
                labelText: 'Password',
                icon: Icons.lock_outline,
                onSaved: (value) {
                  password = value;
                },
                onChanged: (value) {
                  password = value;
                  _validateConfirmIfFilled();
                },
                validator: Validators.password,
                inputFormatters: [Validators.passwordTextInputFormatter],
                obscureText: obscurePassword,
                onTogglePasswordVisibility: togglePasswordVisibility,
                keyboardType: TextInputType.visiblePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              InputField(
                fieldKey: confirmKey,
                labelText: 'Confirm Password',
                icon: Icons.lock_outline,
                validator: (value) =>
                    Validators.confirmPassword(value, password),
                inputFormatters: [Validators.passwordTextInputFormatter],
                obscureText: obscureConfirmPassword,
                onTogglePasswordVisibility: toggleConfirmPasswordVisibility,
                keyboardType: TextInputType.visiblePassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              Center(
                child: FilledButton(
                  onPressed: widget.isLoading ? null : _submit,
                  style: FilledButton.styleFrom(fixedSize: const Size(100, 40)),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: .bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              BottomAuthOptions(
                label: 'Already have an account?',
                buttonText: 'Sign in',
                onPressed: () => context.go(Routes.signin),
                isLoading: widget.isLoading,
                onGoogleSignIn: widget.onGoogleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

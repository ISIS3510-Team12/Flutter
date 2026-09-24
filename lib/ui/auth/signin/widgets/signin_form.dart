import 'package:flutter/material.dart';
import 'package:team12_flutter_juggle/ui/core/ui/bottom_auth_options.dart';
import 'package:team12_flutter_juggle/ui/core/ui/input_field.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/utils/validators.dart';

typedef SigninCallback = Future<void> Function({
  required String email,
  required String password,
});

class SigninForm extends StatefulWidget {
  const SigninForm({super.key, required this.isLoading, required this.onSubmit, required this.onGoogleSignIn});

  final bool isLoading;
  final SigninCallback onSubmit;
  final GoogleSignInCallback onGoogleSignIn;

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  
  final formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool? obscureText = true;
  

  Future<void> _submit() async {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    form.save();

    await widget.onSubmit(
      email: email!,
      password: password!,
    );
  }

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !(obscureText ?? true);
    });
  }


  @override
  Widget build(BuildContext context) {
    
    return Form(
      key: formKey,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: .only(left: 15, right: 15, top: 20),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 18,
            children: [
              InputField(
                labelText: 'Email',
                icon: Icons.mood_outlined,
                onSaved: (email) {
                  this.email = email;
                },
                validator: Validators.email,
              ),
              InputField(
                labelText: 'Password',
                icon: Icons.lock_outline,
                onSaved: (password) {
                  this.password = password;
                },
                obscureText: obscureText,
                validator: Validators.password,
                onTogglePasswordVisibility: togglePasswordVisibility,
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
                onPressed: () => context.go('/signup'),
                onGoogleSignIn: widget.onGoogleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

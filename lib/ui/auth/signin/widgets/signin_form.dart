import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:team12_flutter_juggle/ui/core/ui/shake_reset_dialog.dart';
import 'package:team12_flutter_juggle/ui/core/ui/shake_reset_mixin.dart';
import 'package:team12_flutter_juggle/ui/core/network/connectivity_provider.dart';
import 'package:team12_flutter_juggle/ui/core/ui/bottom_auth_options.dart';
import 'package:team12_flutter_juggle/ui/core/ui/input_field.dart';
import 'package:go_router/go_router.dart';
import 'package:team12_flutter_juggle/ui/core/routing/routes.dart';
import 'package:team12_flutter_juggle/ui/core/utils/validators.dart';

typedef SigninCallback = void Function({
  required String email,
  required String password,
});

class SigninForm extends ConsumerStatefulWidget {
  const SigninForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    required this.onGoogleSignIn,
  });

  final bool isLoading;
  final SigninCallback onSubmit;
  final GoogleSignInCallback onGoogleSignIn;

  @override
  ConsumerState<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends ConsumerState<SigninForm>
    with ShakeResetMixin<SigninForm> {
  final formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool? obscureText = true;


  @override
  void initState() {
    super.initState();

    startShakeDetector(_resetForm);
  }

  @override
  void dispose() {
    stopShakeDetector();
    super.dispose();
  }

  Future<void> _resetForm() async {
    if (!mounted) return;

    if (widget.isLoading) return;

    await runGuardedReset(() async {
      final shouldClear = await showShakeClearDialog(context: context);

      if (!mounted || shouldClear != true) return;

      formKey.currentState?.reset();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form cleared.'),
        ),
      );
    });
  }

  void _submit() {
    final form = formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    form.save();

    widget.onSubmit(email: email!, password: password!);
  }

  void togglePasswordVisibility() {
    setState(() {
      obscureText = !(obscureText ?? true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);
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
                onSaved: (email) {
                  this.email = email;
                },
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
              ),
              InputField(
                labelText: 'Password',
                onSaved: (password) {
                  this.password = password;
                },
                obscureText: obscureText,
                validator: Validators.password,
                inputFormatters: [Validators.passwordTextInputFormatter],
                onTogglePasswordVisibility: togglePasswordVisibility,
                keyboardType: TextInputType.visiblePassword,
              ),
              Center(
                child: FilledButton(
                  onPressed: widget.isLoading || !isOnline ? null : _submit,
                  style: FilledButton.styleFrom(fixedSize: const Size(100, 40)),
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: .bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              BottomAuthOptions(
                label: 'Dont have an account?',
                buttonText: 'Sign up',
                onPressed: () => context.go(Routes.signup),
                isLoading: widget.isLoading,
                onGoogleSignIn: widget.onGoogleSignIn,
                isOnline: isOnline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

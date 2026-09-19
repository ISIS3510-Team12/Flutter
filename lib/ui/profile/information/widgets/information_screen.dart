import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/profile/information/view_models/information_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/information/widgets/clearable_field.dart';
import 'package:team12_flutter_juggle/ui/profile/information/widgets/read_only_field.dart';

class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key, required this.viewModel});

  final InformationViewModel viewModel;

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  // The profile loads asynchronously, so the controllers start empty and
  // get filled in once, the first time build() runs after loading finishes.
  bool _controllersFilled = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Information')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!_controllersFilled) {
            _firstNameController.text = widget.viewModel.firstName;
            _lastNameController.text = widget.viewModel.lastName;
            _usernameController.text = widget.viewModel.username;
            _emailController.text = widget.viewModel.email;
            _controllersFilled = true;
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    widget.viewModel.initial,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ClearableField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Symbols.person,
                  onChanged: widget.viewModel.updateFirstName,
                ),
                const SizedBox(height: 12),
                ClearableField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Symbols.person,
                  onChanged: widget.viewModel.updateLastName,
                ),
                const SizedBox(height: 36),
                ReadOnlyField(
                  controller: _usernameController,
                  label: 'Username',
                  icon: Symbols.mood,
                ),
                const SizedBox(height: 12),
                ReadOnlyField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Symbols.mail,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

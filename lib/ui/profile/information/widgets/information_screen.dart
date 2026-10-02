import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:team12_flutter_juggle/ui/profile/information/view_models/information_viewmodel.dart';
import 'package:team12_flutter_juggle/ui/profile/information/view_models/information_viewmodel_provider.dart';
import 'package:team12_flutter_juggle/ui/profile/information/widgets/clearable_field.dart';
import 'package:team12_flutter_juggle/ui/profile/information/widgets/read_only_field.dart';

class InformationScreen extends ConsumerWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(informationViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Information')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        data: (info) => _InformationForm(info: info),
      ),
    );
  }
}

class _InformationForm extends ConsumerStatefulWidget {
  const _InformationForm({required this.info});

  final InformationState info;

  @override
  ConsumerState<_InformationForm> createState() => _InformationFormState();
}

class _InformationFormState extends ConsumerState<_InformationForm> {
  late final _firstNameController = TextEditingController(
    text: widget.info.firstName,
  );
  late final _lastNameController = TextEditingController(
    text: widget.info.lastName,
  );
  late final _emailController = TextEditingController(text: widget.info.email);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              widget.info.initial,
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
            onChanged: (value) => ref
                .read(informationViewModelProvider.notifier)
                .updateFirstName(value),
          ),
          const SizedBox(height: 12),
          ClearableField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Symbols.person,
            onChanged: (value) => ref
                .read(informationViewModelProvider.notifier)
                .updateLastName(value),
          ),
          const SizedBox(height: 36),
          ReadOnlyField(
            controller: _emailController,
            label: 'Email',
            icon: Symbols.mail,
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}

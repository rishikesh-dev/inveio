import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/gstin_text_field_widget.dart';
import 'package:inveio/shared/presentation/widgets/radio_selection_widget.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/extensions/extensions.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Screen that lets the user view and edit their business details and GST
/// registration. Only shown from the Settings screen.
class BusinessDetailsScreen extends StatefulWidget {
  /// Creates a [BusinessDetailsScreen].
  const BusinessDetailsScreen({super.key});

  @override
  State<BusinessDetailsScreen> createState() => _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends State<BusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstinController;

  GstinStatus? _gstinStatus;
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    final onboarding = context.read<OnboardingBloc>().state.onboarding;
    _nameController = TextEditingController(
      text: onboarding.businessName ?? '',
    );
    _addressController = TextEditingController(text: onboarding.address ?? '');
    _gstinController = TextEditingController(text: onboarding.gstin ?? '');
    _gstinStatus = onboarding.gstinStatus;
    _logoPath = onboarding.logoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bloc = context.read<OnboardingBloc>();
    bloc
      ..add(BusinessNameChanged(_nameController.text.trim()))
      ..add(BusinessAddressChanged(_addressController.text.trim()))
      ..add(BusinessLogoChanged(_logoPath))
      ..add(GstRegistrationStatusSet(_gstinStatus ?? GstinStatus.notYet));
    if (_gstinStatus == GstinStatus.yes) {
      bloc.add(GstinChanged(_gstinController.text.trim()));
    }
    bloc.add(const OnboardingSubmitted());
  }

  Future<void> _pickLogo() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file == null) return;
    setState(() => _logoPath = file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<OnboardingBloc, OnboardingState>(
          listenWhen: (previous, current) =>
              current is OnboardingSuccess || current is OnboardingFailure,
          listener: (context, state) {
            if (state is OnboardingSuccess) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Business details saved')),
                );
              context.pop();
            } else if (state is OnboardingFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: CustomScrollView(
            slivers: [
              const AppBarWidget(title: 'Business Details'),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 22, 15, 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Business information'),
                      const SizedBox(height: 12),
                      TextFieldWidget(
                        controller: _nameController,
                        hintText: 'Business name',
                        textFieldLabel: 'Business name',
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Business name is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFieldWidget(
                        controller: _addressController,
                        hintText: 'Business address',
                        textFieldLabel: 'Address',
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      const _FieldLabel('Business logo'),
                      const SizedBox(height: 12),
                      _LogoPicker(logoPath: _logoPath, onPick: _pickLogo),
                      const SizedBox(height: 24),
                      const _FieldLabel('GST registration'),
                      const SizedBox(height: 12),
                      RadioGroup<GstinStatus>(
                        groupValue: _gstinStatus,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _gstinStatus = value);
                        },
                        child: Column(
                          children: [
                            RadioSelectionWidget<GstinStatus>(
                              value: GstinStatus.yes,
                              label: 'Yes, I have a GSTIN',
                              padding: const EdgeInsets.only(left: 20),
                              bgColor: _gstinStatus == GstinStatus.yes
                                  ? AppColors.primary
                                  : null,
                              onTap: () => setState(
                                () => _gstinStatus = GstinStatus.yes,
                              ),
                            ),
                            RadioSelectionWidget<GstinStatus>(
                              value: GstinStatus.notYet,
                              label: 'Not yet',
                              padding: const EdgeInsets.only(left: 20),
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              bgColor: _gstinStatus == GstinStatus.notYet
                                  ? AppColors.primary
                                  : null,
                              onTap: () => setState(
                                () => _gstinStatus = GstinStatus.notYet,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_gstinStatus == GstinStatus.yes) ...[
                        const SizedBox(height: 12),
                        GstinTextField(
                          controller: _gstinController,
                          validator: GstinTextField.requiredValidator,
                          showStateDetection: true,
                        ),
                      ],
                      const SizedBox(height: 32),
                      _SaveButton(
                        onPressed: _save,
                        isLoading:
                            context.watch<OnboardingBloc>().state
                                is OnboardingLoading,
                      ),
                    ],
                  ),
                ),
              ).toSliver(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13.6, fontWeight: FontWeight.w600),
    );
  }
}

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({required this.logoPath, required this.onPick});

  final String? logoPath;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoPath != null && logoPath!.isNotEmpty;
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.darkInput,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.darkBorderSoft),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasLogo
              ? Image.file(
                  File(logoPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    LucideIcons.imageOff,
                    color: AppColors.darkTextMuted,
                  ),
                )
              : const Icon(LucideIcons.image, color: AppColors.darkTextMuted),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(LucideIcons.upload, size: 18),
            label: Text(hasLogo ? 'Change logo' : 'Upload logo'),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onPressed, required this.isLoading});

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Save Changes'),
      ),
    );
  }
}

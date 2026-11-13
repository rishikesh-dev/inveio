import 'dart:io';

import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/shared/notifications/widgets/bottom_sheet/info_bottom_sheet_widget.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/routes/route_data/delete_account_route_data.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/extensions/extensions.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/profile/presentation/widgets/danger_zone.dart';
import 'package:inveio/profile/presentation/widgets/profile_avatar.dart';
import 'package:inveio/profile/presentation/widgets/profile_section.dart';
import 'package:inveio/profile/presentation/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.userData,
    required this.onBoardingData,
  });
  final UserEntity userData;
  final OnboardingEntity onBoardingData;
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _gstController;
  String? _logoPath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _emailController = TextEditingController(text: widget.userData.email);
    _gstController = TextEditingController(
      text: widget.onBoardingData.gstin ?? '',
    );
    _logoPath = widget.onBoardingData.logoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bloc = context.read<OnboardingBloc>();
    bloc
      ..add(const GstRegistrationStatusSet(GstinStatus.yes))
      ..add(BusinessNameChanged(_nameController.text.trim()))
      ..add(GstinChanged(_gstController.text.trim()))
      ..add(BusinessLogoChanged(_logoPath))
      ..add(const OnboardingSubmitted());
  }

  Future<void> _pickAvatar() async {
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
                ..showSnackBar(const SnackBar(content: Text('Profile saved')));
            } else if (state is OnboardingFailure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: CustomScrollView(
            slivers: [
              const AppBarWidget(title: 'Edit Profile'),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ProfileAvatar(
                        image:
                            _logoPath != null && File(_logoPath!).existsSync()
                            ? FileImage(File(_logoPath!))
                            : null,
                        onTap: _pickAvatar,
                      ),

                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Profile Information',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ProfileSection(
                        nameController: _nameController,
                        emailController: _emailController,
                        gstController: _gstController,
                        nameValidator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                      ),

                      const SizedBox(height: 32),

                      SaveButton(
                        onPressed: _save,
                        isLoading:
                            context.watch<OnboardingBloc>().state
                                is OnboardingLoading,
                      ),

                      const SizedBox(height: 40),
                      const Divider(thickness: 1.2),
                      DangerZone(onDelete: _confirmDeleteAccount),

                      const SizedBox(height: 44),
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

  void _confirmDeleteAccount() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => InfoBottomSheetWidget(
        bottomSheetCrossAlignment: CrossAxisAlignment.start,
        iconAlignment: Alignment.topLeft,
        contentTextAlign: TextAlign.left,
        icon: const Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Icon(Icons.warning_rounded, color: AppColors.danger, size: 30),
        ),
        buttonColor: AppColors.danger,
        title: 'Delete your account?',
        content:
            "This will permanently delete your account and all associated data — expenses, invoices, and GST records. This action can't be undone.",
        buttonLabel: 'Continue',
        onPressed: () {
          Navigator.of(sheetContext).pop();
          context.pushNamed(
            RouterConstants.deleteAccountConfirmation,
            extra: DeleteAccountRouteData(userData: widget.userData),
          );
        },
      ),
    );
  }
}

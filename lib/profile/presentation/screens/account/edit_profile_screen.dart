import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/shared/notifications/widgets/bottom_sheet/info_bottom_sheet_widget.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/routes/route_data/delete_account_route_data.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/extensions/extensions.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/profile/presentation/widgets/danger_zone.dart';
import 'package:inveio/profile/presentation/widgets/profile_avatar.dart';
import 'package:inveio/profile/presentation/widgets/profile_section.dart';
import 'package:inveio/profile/presentation/widgets/save_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _gstController;
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData.name);
    _emailController = TextEditingController(text: widget.userData.email);
    _gstController = TextEditingController(
      text: widget.onBoardingData.gstin ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const AppBarWidget(title: 'Edit Profile'),
            Form(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const ProfileAvatar(),

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
                    ),

                    const SizedBox(height: 32),

                    SaveButton(onPressed: () {}),

                    const SizedBox(height: 40),
                    const Divider(thickness: 1.2),
                    DangerZone(
                      onDelete: _confirmDeleteAccount,
                    ),

                    const SizedBox(height: 44),
                  ],
                ),
              ),
            ).toSliver(),
          ],
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
          child: Icon(
            Icons.warning_rounded,
            color: AppColors.danger,
            size: 30,
          ),
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

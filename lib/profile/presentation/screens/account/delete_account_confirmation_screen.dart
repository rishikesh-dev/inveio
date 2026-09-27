import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/radio_selection_widget.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Screen that collects the user's reason for leaving and lets them choose
/// between deactivating and permanently deleting their account.
class DeleteAccountConfirmationScreen extends StatefulWidget {
  /// Creates a [DeleteAccountConfirmationScreen] for the given [userData].
  const DeleteAccountConfirmationScreen({
    super.key,
    required this.userData,
  });

  /// The user data of the account being deactivated or deleted.
  final UserEntity userData;

  @override
  State<DeleteAccountConfirmationScreen> createState() =>
      _DeleteAccountConfirmationScreenState();
}

class _DeleteAccountConfirmationScreenState
    extends State<DeleteAccountConfirmationScreen> {
  static const List<String> _reasons = [
    'Too expensive',
    'Not useful enough',
    'Switching to another app',
    'Privacy concerns',
    'Other',
  ];

  String? _selectedReason;
  final _otherReasonController = TextEditingController();

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _onDeactivate() {
    context.read<AuthBloc>().add(SignOut(uid: widget.userData.uid ?? ''));
  }

  void _onDelete() {
    context.read<AuthBloc>().add(const DeleteAccount());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAccountDeleted || state is AuthSignedOut) {
              context.goNamed(RouterConstants.signIn);
            }
            if (state is AuthErrorState) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: CustomScrollView(
            slivers: [
              const AppBarWidget(title: 'Delete Account'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sorry to see you go',
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ).toAnimatedEntrance(
                        delay: const Duration(milliseconds: 60),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tell us why you\'re leaving. Your feedback helps us improve.',
                        style: TextStyle(
                          color: AppColors.darkTextSecondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ).toAnimatedEntrance(
                        delay: const Duration(milliseconds: 110),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Why are you leaving?',
                        style: TextStyle(
                          color: AppColors.darkTextPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ).toAnimatedEntrance(
                        delay: const Duration(milliseconds: 160),
                      ),
                      const SizedBox(height: 12),
                      RadioGroup<String>(
                        groupValue: _selectedReason,
                        onChanged: (value) =>
                            setState(() => _selectedReason = value),
                        child: Column(
                          children: [
                            for (final reason in _reasons)
                              RadioSelectionWidget<String>(
                                value: reason,
                                label: reason,
                                onTap: () =>
                                    setState(() => _selectedReason = reason),
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(16),
                                bgColor: _selectedReason == reason
                                    ? AppColors.primary
                                    : null,
                              ),
                          ],
                        ),
                      ),
                      if (_selectedReason == 'Other') ...[
                        const SizedBox(height: 4),
                        TextFieldWidget(
                          controller: _otherReasonController,
                          hintText: 'Tell us more (optional)',
                          maxLines: 3,
                        ),
                      ],
                      const SizedBox(height: 30),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading = state is AuthLoading;
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed: isLoading ? null : _onDeactivate,
                                  icon: const Icon(LucideIcons.power),
                                  label: const Text('Deactivate Account'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.warning,
                                    side: const BorderSide(
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: FilledButton.icon(
                                  onPressed: isLoading ? null : _onDelete,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  label: const Text('Delete Account'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.danger,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Deactivating signs you out and keeps your data safe in the cloud. Deleting permanently removes your account and all associated data.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.darkTextMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

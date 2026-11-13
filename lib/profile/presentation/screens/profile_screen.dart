import 'dart:async';

import 'package:inveio/profile/domain/entities/user_entity.dart';
import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/routes/route_data/edit_profile_route_data.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/profile/presentation/widgets/empty_profile_state.dart';
import 'package:inveio/profile/presentation/widgets/footer_mark.dart';
import 'package:inveio/profile/presentation/widgets/profile_header.dart';
import 'package:inveio/profile/presentation/widgets/section_label.dart';
import 'package:inveio/profile/presentation/widgets/settings_group.dart';
import 'package:inveio/profile/presentation/widgets/settings_tile.dart';
import 'package:inveio/profile/presentation/dialogs/clear_history_dialog.dart';
import 'package:inveio/profile/presentation/buttons/logout_button_widget.dart';
import 'package:inveio/settings/domain/entities/app_settings.dart';
import 'package:inveio/settings/presentation/cubit/export_data_cubit.dart';
import 'package:inveio/settings/presentation/cubit/theme_cubit.dart';
import 'package:inveio/settings/presentation/widgets/appearance_bottom_sheet.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

/// The main settings/profile screen displaying user details, preferences, and app controls.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  /// Creates the mutable state for this screen.
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserEntity? _lastUser;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSignedOut || state is AuthAccountDeleted) {
          context.goNamed(RouterConstants.signIn);
        }
        if (state is AuthProfileUpdated || state is AuthProfilePhotoUpdated) {
          _lastUser = _userFromState(state);
          _showSnack('Profile updated');
          context.read<AuthBloc>().add(const ClearAuthEvent());
        }
        if (state is AuthErrorState) {
          _showSnack(state.message);
        }
      },
      builder: (context, state) {
        final user = _userFromState(state) ?? _lastUser;
        if (user != null) _lastUser = user;

        if (state is AuthLoading && user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (user == null) {
          return EmptyProfileState(
            onRetry: () =>
                context.read<AuthBloc>().add(const CheckAuthStatus()),
          );
        }

        return _buildContent(context, state, user);
      },
    );
  }

  Widget _buildContent(BuildContext context, AuthState state, UserEntity user) {
    final onboarding = context.watch<OnboardingBloc>().state.onboarding;
    return BlocListener<ExportDataCubit, ExportDataState>(
      listenWhen: (previous, current) =>
          current is ExportDataSuccess || current is ExportDataFailure,
      listener: (context, state) {
        if (state is ExportDataSuccess) {
          unawaited(_shareExportedFile(state.filePath));
        } else if (state is ExportDataFailure) {
          _showSnack(state.message);
        }
      },
      child: CustomScrollView(
        slivers: [
          const AppBarWidget(
            title: 'Settings',
            subTitle: 'Manage your account and preferences',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 22, 15, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProfileHeader(user: user),
                  const SizedBox(height: 20),
                  const SectionLabel('Account'),
                  SettingsGroup(
                    children: [
                      SettingsTile(
                        icon: LucideIcons.atSign,
                        title: 'Edit Profile',
                        subtitle: user.email,
                        onTap: () {
                          context.pushNamed(
                            RouterConstants.editProfile,
                            extra: EditProfileRouteData(
                              userData: user,
                              onboardingData: onboarding,
                            ),
                          );
                        },
                      ),
                      SettingsTile(
                        icon: LucideIcons.lockKeyhole,
                        title: 'Security',
                        subtitle: 'Password and app security',
                        onTap: () {
                          context.pushNamed(RouterConstants.securityScreen);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Business'),
                  SettingsGroup(
                    children: [
                      SettingsTile(
                        icon: LucideIcons.building2,
                        title: 'Business Details',
                        subtitle: (onboarding.businessName?.isNotEmpty ?? false)
                            ? onboarding.businessName!
                            : 'Business name, address and logo',
                        onTap: () {
                          context.pushNamed(RouterConstants.businessDetails);
                        },
                      ),
                      SettingsTile(
                        icon: LucideIcons.stamp,
                        title: 'GST Registration',
                        subtitle: onboarding.gstinStatus == GstinStatus.yes
                            ? 'Registered'
                            : (onboarding.gstinStatus == GstinStatus.notYet
                                  ? 'Not Registered'
                                  : '—'),
                        onTap: () {
                          context.pushNamed(RouterConstants.businessDetails);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Preferences'),
                  SettingsGroup(
                    children: [
                      BlocSelector<ThemeCubit, AppSettings, AppThemeMode>(
                        selector: (settings) => settings.themeMode,
                        builder: (context, themeMode) => SettingsTile(
                          icon: LucideIcons.palette,
                          title: 'Appearance',
                          subtitle: 'Theme: ${themeMode.label}',
                          onTap: () => AppearanceBottomSheet.show(context),
                        ),
                      ),
                      const SettingsTile(
                        icon: LucideIcons.refreshCcw,
                        title: 'Primary Currency',
                        subtitle: 'INR - Indian Rupee',
                        trailingWidget: SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SectionLabel('Data & Security'),
                  SettingsGroup(
                    children: [
                      SettingsTile(
                        icon: LucideIcons.download,
                        title: 'Export Data',
                        subtitle: 'Download expenses and invoices as CSV',
                        onTap: () =>
                            context.read<ExportDataCubit>().exportData(),
                      ),
                      SettingsTile(
                        icon: LucideIcons.trash2,
                        title: 'Clear History',
                        subtitle: 'Permanent deletion of records',
                        iconColor: AppColors.expense,
                        onTap: _confirmClearHistory,
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                  LogoutButtonWidget(
                    isLoading: state is AuthLoading,
                    uid: user.uid ?? '',
                  ),
                  const SizedBox(height: 34),
                  const FooterMark(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  UserEntity? _userFromState(AuthState state) {
    return switch (state) {
      AuthSignedIn(:final user) => user,
      AuthProfileUpdated(:final user) => user,
      AuthProfilePhotoUpdated(:final user) => user,
      _ => null,
    };
  }

  /// Opens the share sheet for the CSV file written by [ExportDataCubit].
  Future<void> _shareExportedFile(String path) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: 'text/csv')]),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmClearHistory() async {
    final dialog = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'This permanently deletes all your expenses and invoices. Your profile, business details and settings are not affected.',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (dialog != true || !mounted) return;

    final confirmation = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const ClearHistoryDialog(),
    );
    if (confirmation != 'DELETE' || !mounted) return;

    context.read<TransactionBloc>().add(
      ClearHistory(confirmation: confirmation!),
    );
    _showSnack('History cleared');
  }
}

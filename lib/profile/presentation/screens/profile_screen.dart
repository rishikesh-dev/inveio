import 'package:inveio/profile/presentation/widgets/banner/upgrade_banner.dart';
import 'package:inveio/shared/constants/app_constants.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    return CustomScrollView(
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
                const UpgradeBanner(),
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
                      // onTap: () => showEditProfileSheet(context, user),
                    ),
                    SettingsTile(
                      icon: LucideIcons.lockKeyhole,
                      title: 'Security',
                      subtitle: 'Password and app security',
                      onTap: () {
                        context.pushNamed(RouterConstants.securityScreen);
                      },
                      // onTap: () => showEditProfileSheet(context, user),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionLabel('Business'),
                SettingsGroup(
                  children: [
                    const SettingsTile(
                      icon: LucideIcons.building2,
                      title: 'Business Details',
                      subtitle: 'Business name, address and logo',
                    ),
                    SettingsTile(
                      icon: LucideIcons.stamp,
                      title: 'GST Registration',
                      subtitle: onboarding.gstinStatus == GstinStatus.yes
                          ? 'Registered'
                          : (onboarding.gstinStatus == GstinStatus.notYet
                                ? 'Not Registered'
                                : '—'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionLabel('Preferences'),
                SettingsGroup(
                  children: [
                    SettingsTile(
                      icon: LucideIcons.bell,
                      title: 'Appearance',
                      subtitle: 'Theme and language',
                      onTap: () =>
                          _showSnack('Notification settings are coming soon'),
                    ),
                    SettingsTile(
                      icon: LucideIcons.bell,
                      title: 'Notifications',
                      subtitle: 'Push, Email, and SMS alerts',
                      onTap: () =>
                          _showSnack('Notification settings are coming soon'),
                    ),
                    SettingsTile(
                      icon: LucideIcons.refreshCcw,
                      title: 'Primary Currency',
                      subtitle: 'INR - Indian Rupee',
                      onTap: () =>
                          _showSnack('Currency settings are coming soon'),
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
                      subtitle: 'Download as CSV or PDF',
                      onTap: () => _showSnack(
                        'Export will be available after sync setup',
                      ),
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
                _LogoutButton(
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

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmClearHistory() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text(
          'This action cannot be undone once data storage is connected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (shouldClear == true) {
      _showSnack('History cleanup is ready for the data layer');
    }
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.isLoading, required this.uid});
  final String uid;

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : () => _confirmLogout(context, uid),
      icon: const Icon(LucideIcons.logOut),
      label: Text(
        isLoading ? 'Please wait...' : 'Logout from ${AppConstants.appName}',
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkMutedPanel,
        foregroundColor: AppColors.darkTextPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, String uid) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('You can sign back in anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && context.mounted) {
      context.read<AuthBloc>().add(SignOut(uid: uid));
    }
  }
}

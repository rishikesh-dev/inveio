import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Widget for logging out from the app.
class LogoutButtonWidget extends StatelessWidget {
  const LogoutButtonWidget({
    super.key,
    required this.isLoading,
    required this.uid,
  });

  final bool isLoading;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : () => _confirmLogout(context, uid),
      icon: const Icon(LucideIcons.logOut),
      label: Text(_getLogoutLabel()),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkMutedPanel,
        foregroundColor: AppColors.darkTextPrimary,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  String _getLogoutLabel() {
    if (isLoading) return 'Please wait...';
    return 'Logout from ${AppConstants.appName}';
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

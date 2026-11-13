import 'package:inveio/auth/presentation/widgets/auth_button.dart';
import 'package:inveio/auth/presentation/widgets/or_divider.dart';
import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Footer section of the sign-up form with Google sign-in and sign-in redirect.
class SignUpFooter extends StatelessWidget {
  const SignUpFooter({
    super.key,
    required this.onGoogleSignIn,
    required this.isAuthLoading,
  });

  /// Callback when the user taps "Continue with Google".
  final VoidCallback onGoogleSignIn;

  /// Whether auth is currently loading.
  final bool isAuthLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const OrDivider(),
        const SizedBox(height: 16),
        AuthButton(
          onPressed: isAuthLoading ? null : onGoogleSignIn,
          icon: Image.asset(AppConstants.googleIcon, height: 22),
          label: 'Continue with Google',
        ).toAnimatedEntrance(delay: const Duration(milliseconds: 300)),
        const SizedBox(height: 24),
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(
                  color: AppColors.darkTextSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              InlineAuthLink(
                label: 'Sign in',
                onTap: () => context.pushNamed(RouterConstants.signIn),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// An inline tappable auth link (e.g. "Sign in").
class InlineAuthLink extends StatelessWidget {
  const InlineAuthLink({super.key, required this.label, required this.onTap});

  /// The link text.
  final String label;

  /// Callback when the link is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

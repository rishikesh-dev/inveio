import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/auth/presentation/widgets/sign_up_footer.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/presentation/widgets/password_checklist.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/theme/app_text_styles.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:inveio/shared/utils/password_validator.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// The sign-up form body extracted from [SignUpScreen] to keep file size under
/// the 300-line threshold.
class SignUpFormBody extends StatelessWidget {
  const SignUpFormBody({
    super.key,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.state,
    required this.onSignUp,
    required this.onGoogleSignIn,
  });

  /// The form key for validation.
  final GlobalKey<FormState> formKey;

  /// Controller for the full name field.
  final TextEditingController fullNameController;

  /// Controller for the email field.
  final TextEditingController emailController;

  /// Controller for the password field.
  final TextEditingController passwordController;

  /// Controller for the confirm password field.
  final TextEditingController confirmPasswordController;

  /// Notifier for password visibility toggle.
  final ValueNotifier<bool> obscurePassword;

  /// Notifier for confirm password visibility toggle.
  final ValueNotifier<bool> obscureConfirmPassword;

  /// Current auth state for error display and loading indicator.
  final dynamic state;

  /// Callback when the user taps "Create Account".
  final VoidCallback onSignUp;

  /// Callback when the user taps "Continue with Google".
  final VoidCallback onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create account',
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.darkTextPrimary,
              height: 1.1,
            ),
          ).toAnimatedEntrance(delay: const Duration(milliseconds: 60)),
          const SizedBox(height: 8),
          Text(
            'Start managing your money with Inveio.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.darkTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ).toAnimatedEntrance(delay: const Duration(milliseconds: 110)),
          const SizedBox(height: 32),
          _buildFullNameField().toAnimatedEntrance(
            delay: const Duration(milliseconds: 150),
          ),
          const SizedBox(height: 16),
          _buildEmailField().toAnimatedEntrance(
            delay: const Duration(milliseconds: 160),
          ),
          const SizedBox(height: 16),
          _buildPasswordField().toAnimatedEntrance(
            delay: const Duration(milliseconds: 170),
          ),
          const SizedBox(height: 8),
          PasswordChecklist(
            controller: passwordController,
          ).toAnimatedEntrance(delay: const Duration(milliseconds: 180)),
          const SizedBox(height: 16),
          _buildConfirmPasswordField().toAnimatedEntrance(
            delay: const Duration(milliseconds: 190),
          ),
          const SizedBox(height: 28),
          NeonButton(
            label: state is AuthLoading
                ? 'Creating account...'
                : 'Create account',
            onPressed: state is AuthLoading ? null : onSignUp,
          ).toAnimatedEntrance(delay: const Duration(milliseconds: 240)),
          SignUpFooter(
            onGoogleSignIn: onGoogleSignIn,
            isAuthLoading: state is AuthLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextFieldWidget(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your full name';
        }
        if (value.trim().length < 2) {
          return 'Name looks too short';
        }
        return null;
      },
      textFieldLabel: 'Full name',
      hintText: 'Enter your full name',
      prefix: const Icon(LucideIcons.user, size: 20),
      controller: fullNameController,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildEmailField() {
    return TextFieldWidget(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      errorText: state is AuthErrorState && state.message.contains('email')
          ? state.message
          : null,
      textFieldLabel: 'Email address',
      hintText: 'Enter your email',
      prefix: const Icon(LucideIcons.mail, size: 20),
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildPasswordField() {
    return ListenableBuilder(
      listenable: Listenable.merge([obscurePassword, passwordController]),
      builder: (context, _) => TextFieldWidget(
        validator: PasswordValidator.validate,
        errorText: state is AuthErrorState && state.message.contains('password')
            ? state.message
            : null,
        textFieldLabel: 'Password',
        hintText: 'Create a password',
        prefix: Icon(
          obscurePassword.value ? LucideIcons.lock : LucideIcons.lockOpen,
          size: 20,
        ),
        controller: passwordController,
        obscureText: obscurePassword.value,
        textInputAction: TextInputAction.next,
        suffix: GestureDetector(
          onTap: () => obscurePassword.value = !obscurePassword.value,
          child: passwordController.text.isNotEmpty
              ? Icon(
                  obscurePassword.value ? LucideIcons.eye : LucideIcons.eyeOff,
                  color: AppColors.darkTextMuted,
                  size: 20,
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        obscureConfirmPassword,
        confirmPasswordController,
      ]),
      builder: (context, _) => TextFieldWidget(
        validator: (value) =>
            PasswordValidator.validateConfirm(value, passwordController.text),
        errorText: state is AuthErrorState && state.message.contains('password')
            ? state.message
            : null,
        textFieldLabel: 'Confirm password',
        hintText: 'Confirm your password',
        prefix: Icon(
          obscureConfirmPassword.value
              ? LucideIcons.lock
              : LucideIcons.lockOpen,
          size: 20,
        ),
        controller: confirmPasswordController,
        obscureText: obscureConfirmPassword.value,
        textInputAction: TextInputAction.done,
        suffix: GestureDetector(
          onTap: () =>
              obscureConfirmPassword.value = !obscureConfirmPassword.value,
          child: confirmPasswordController.text.isNotEmpty
              ? Icon(
                  obscureConfirmPassword.value
                      ? LucideIcons.eye
                      : LucideIcons.eyeOff,
                  color: AppColors.darkTextMuted,
                  size: 20,
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}

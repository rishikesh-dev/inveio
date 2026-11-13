import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/presentation/widgets/password_checklist.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/utils/extensions/extensions.dart';
import 'package:inveio/shared/utils/password_validator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ChangePasswordEvent(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AuthPasswordChanged) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        child: CustomScrollView(
          slivers: [
            const AppBarWidget(),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(LucideIcons.keyRound, size: 40),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change Password',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Keep your account secure by using a strong password.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Form
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFieldWidget(
                              textFieldLabel: 'Current Password',
                              controller: _currentPasswordController,
                              obscureText: _obscureCurrent,
                              contentPaddingVertical: 18,
                              prefix: const Icon(LucideIcons.lockKeyhole),
                              suffix: IconButton(
                                onPressed: () => setState(
                                  () => _obscureCurrent = !_obscureCurrent,
                                ),
                                icon: Icon(
                                  _obscureCurrent
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                ),
                              ),
                              hintText: 'Enter your current password',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Enter your current password'
                                  : null,
                            ),

                            const SizedBox(height: 18),

                            TextFieldWidget(
                              textFieldLabel: 'New Password',
                              controller: _newPasswordController,
                              obscureText: _obscureNew,
                              contentPaddingVertical: 18,
                              prefix: const Icon(LucideIcons.lockKeyhole),
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _obscureNew = !_obscureNew),
                                icon: Icon(
                                  _obscureNew
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                ),
                              ),
                              hintText: 'Enter your new password',
                              validator: (value) => PasswordValidator.validate(
                                value,
                                emptyMessage: 'Enter a new password',
                              ),
                            ),

                            const SizedBox(height: 12),

                            PasswordChecklist(
                              controller: _newPasswordController,
                            ),

                            const SizedBox(height: 12),

                            TextFieldWidget(
                              textFieldLabel: 'Confirm New Password',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirm,
                              contentPaddingVertical: 18,
                              prefix: const Icon(LucideIcons.lockKeyhole),
                              suffix: IconButton(
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                                icon: Icon(
                                  _obscureConfirm
                                      ? LucideIcons.eyeOff
                                      : LucideIcons.eye,
                                ),
                              ),
                              hintText: 'Re-enter your new password',
                              validator: (value) =>
                                  PasswordValidator.validateConfirm(
                                    value,
                                    _newPasswordController.text,
                                    emptyMessage: 'Re-enter your new password',
                                  ),
                            ),

                            const SizedBox(height: 12),

                            PasswordChecklist(
                              controller: _confirmPasswordController,
                            ),

                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF151E13),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF263324),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.shieldCheck,
                                    size: 32,
                                    color: Color(0xFFB5FF45),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Your password stays private\n'
                                      'We never store your password and it\'s always encrypted.',
                                      style: TextStyle(
                                        color: theme.hintColor,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NeonButton(
        onPressed: _updatePassword,
        label: 'Update Password',
        icon: LucideIcons.arrowRight,
        iconAlignment: IconAlignment.end,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        borderRadius: BorderRadius.circular(15),
      ).withPadding(const EdgeInsets.fromLTRB(20, 0, 20, 40)),

      // Bottom button
    );
  }
}

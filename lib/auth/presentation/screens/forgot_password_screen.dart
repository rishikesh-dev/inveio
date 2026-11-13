import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/shared/notifications/widgets/bottom_sheet/info_bottom_sheet_widget.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Screen for requesting a password reset email.
class ForgotPasswordScreen extends StatefulWidget {
  /// Creates a [ForgotPasswordScreen].
  const ForgotPasswordScreen({super.key});

  /// Creates the mutable state for this widget.
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const ClearAuthEvent());
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthPasswordResetSent) {
              FocusManager.instance.primaryFocus?.unfocus();
              showModalBottomSheet<void>(
                context: context,
                useSafeArea: true,
                backgroundColor: AppColors.darkSurface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                sheetAnimationStyle: const AnimationStyle(
                  curve: Curves.easeInOutCirc,
                  duration: Duration(milliseconds: 500),
                ),
                builder: (sheetContext) => InfoBottomSheetWidget(
                  title: 'Almost done!',
                  content:
                      'We\'ve sent a password reset link to your email. It may take a few minutes to arrive. If you don\'t see it, check your Spam or Junk folder.',
                  buttonLabel: 'Go to login',
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    context.goNamed(RouterConstants.signIn);
                  },
                ),
              );
            }
            if (state is AuthErrorState) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: CustomScrollView(
            slivers: [
              const AppBarWidget(expandedHeight: 100),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reset password',
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
                          'Enter your email and we will send a reset link.',
                          style: TextStyle(
                            color: AppColors.darkTextSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ).toAnimatedEntrance(
                          delay: const Duration(milliseconds: 110),
                        ),
                        const SizedBox(height: 30),
                        TextFieldWidget(
                          prefix: const Icon(LucideIcons.mail, size: 20),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          controller: _emailTextController,
                          hintText: 'Enter your email ',
                        ).toAnimatedEntrance(
                          delay: const Duration(milliseconds: 150),
                        ),
                        const SizedBox(height: 20),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return NeonButton(
                              label: state is AuthLoading
                                  ? 'Sending link...'
                                  : 'Send link',
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      context.read<AuthBloc>().add(
                                        ResetPasswordEvent(
                                          email: _emailTextController.text
                                              .trim(),
                                        ),
                                      );
                                    },
                            ).toAnimatedEntrance(
                              delay: const Duration(milliseconds: 240),
                            );
                          },
                        ),
                      ],
                    ),
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

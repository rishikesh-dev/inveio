import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/auth/presentation/widgets/auth_button.dart';
import 'package:inveio/auth/presentation/widgets/or_divider.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/routes/app_router_config.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/shared/utils/effects/animated_entrance.dart';
import 'package:inveio/shared/utils/password_validator.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Screen for signing in with email/password or Google.
class SignInScreen extends StatefulWidget {
  /// Creates a [SignInScreen].
  const SignInScreen({super.key});

  /// Creates the mutable state for this widget.
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _mainTextController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const ClearAuthEvent());
  }

  @override
  void dispose() {
    _mainTextController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: CustomScrollView(
            slivers: [
              const AppBarWidget(),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthSignedIn) {
                    onboardingBloc.add(CheckOnboardingStatus(state.user.uid));
                  }
                  if (state is AuthErrorState) {
                    debugPrint('Auth error: ${state.code}');
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  return SliverFillRemaining(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Form(
                        key: _formKey,
                        autovalidateMode:
                            AutovalidateMode.onUserInteractionIfError,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Welcome back',
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
                              'Enter your details to access your account.',
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
                              controller: _mainTextController,
                              hintText: 'Enter your email ',
                              errorText:
                                  state is AuthErrorState &&
                                      state.message.contains('email')
                                  ? state.message
                                  : null,
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
                            ).toAnimatedEntrance(
                              delay: const Duration(milliseconds: 150),
                            ),
                            const SizedBox(height: 14),
                            ListenableBuilder(
                              listenable: Listenable.merge([
                                _obscurePassword,
                                _passwordController,
                              ]),
                              builder: (context, _) => TextFieldWidget(
                                hintText: 'Password',
                                errorText:
                                    state is AuthErrorState &&
                                        state.message.contains('password')
                                    ? state.message
                                    : null,
                                validator: PasswordValidator.validate,
                                prefix: Icon(
                                  _obscurePassword.value
                                      ? LucideIcons.lockKeyhole
                                      : LucideIcons.lockKeyholeOpen,
                                  size: 20,
                                ),
                                controller: _passwordController,
                                obscureText: _obscurePassword.value,
                                suffix: GestureDetector(
                                  onTap: () => _obscurePassword.value =
                                      !_obscurePassword.value,
                                  child: _passwordController.text.isNotEmpty
                                      ? Icon(
                                          _obscurePassword.value
                                              ? LucideIcons.eye
                                              : LucideIcons.eyeOff,
                                          color: AppColors.darkTextSecondary,
                                          size: 20,
                                        )
                                      : const SizedBox(),
                                ),
                              ),
                            ).toAnimatedEntrance(
                              delay: const Duration(milliseconds: 190),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  context.pushNamed(
                                    RouterConstants.forgotPassword,
                                  );
                                },
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: AppColors.darkTextSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            NeonButton(
                              label: state is AuthLoading
                                  ? 'Signing in...'
                                  : 'Sign In',
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      if (!_formKey.currentState!.validate()) {
                                        return;
                                      }
                                      context.read<AuthBloc>().add(
                                        SignInWithEmail(
                                          email: _mainTextController.text
                                              .trim(),
                                          password: _passwordController.text
                                              .trim(),
                                        ),
                                      );
                                    },
                            ).toAnimatedEntrance(
                              delay: const Duration(milliseconds: 240),
                            ),
                            const SizedBox(height: 34),
                            const OrDivider(),
                            const SizedBox(height: 28),
                            AuthButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                        const SignInWithGoogle(),
                                      );
                                    },
                              icon: Image.asset(
                                AppConstants.googleIcon,
                                height: 25,
                              ),
                              label: 'Continue with Google',
                            ).toAnimatedEntrance(
                              delay: const Duration(milliseconds: 300),
                            ),
                            const SizedBox(height: 34),
                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    'New here? ',
                                    style: TextStyle(
                                      color: AppColors.darkTextSecondary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.pushNamed(
                                      RouterConstants.signUp,
                                    ),
                                    child: const Text(
                                      'Create account',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
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
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

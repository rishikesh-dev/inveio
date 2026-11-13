import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/auth/presentation/widgets/sign_up_form_body.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/shared/presentation/widgets/app_bar_widget.dart';
import 'package:inveio/shared/routes/app_router_config.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Screen for creating a new user account.
class SignUpScreen extends StatefulWidget {
  /// Creates a [SignUpScreen].
  const SignUpScreen({super.key});

  /// Creates the mutable state for this widget.
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _obscurePassword = ValueNotifier<bool>(true);
  final _obscureConfirmPassword = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const ClearAuthEvent());
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            AppBarWidget(
              leading: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, size: 22),
                onPressed: () => Navigator.of(context).maybePop(),
                color: AppColors.darkTextPrimary,
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSignedIn) {
                      onboardingBloc.add(CheckOnboardingStatus(state.user.uid));
                    }
                    if (state is AuthErrorState) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text(state.message)));
                    }
                  },
                  builder: (context, state) {
                    return SignUpFormBody(
                      formKey: _formKey,
                      fullNameController: _fullNameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      obscurePassword: _obscurePassword,
                      obscureConfirmPassword: _obscureConfirmPassword,
                      state: state,
                      onSignUp: () {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        context.read<AuthBloc>().add(
                          SignUpWithEmail(
                            password: _passwordController.text.trim(),
                            name: _fullNameController.text.trim(),
                            email: _emailController.text.trim(),
                          ),
                        );
                      },
                      onGoogleSignIn: () {
                        context.read<AuthBloc>().add(const SignInWithGoogle());
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/presentation/widgets/text_field_widget.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Screen that collects the user's business name during onboarding.
class BusinessNameScreen extends StatefulWidget {
  /// Creates a [BusinessNameScreen].
  const BusinessNameScreen({super.key});

  @override
  State<BusinessNameScreen> createState() => _BusinessNameScreenState();
}

class _BusinessNameScreenState extends State<BusinessNameScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final name = context.read<OnboardingBloc>().state.onboarding.businessName;
    _controller = TextEditingController(text: name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const OnboardingProgressBar(currentStep: 1),
              const SizedBox(height: 24),
              const Text(
                "What's your business called?",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This appears on every invoice you send.',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).hintColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              TextFieldWidget(
                hintText: 'Business name',
                contentPaddingHorizontal: 10,
                controller: _controller,
              ),

              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  'Individual? Use your full name.',
                  style: TextStyle(fontSize: 13, color: Colors.white24),
                ),
              ),
              const Spacer(),

              NeonButton(
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 32,
                ),
                label: 'Continue',
                borderRadius: BorderRadius.circular(100),
                onPressed: () {
                  context.read<OnboardingBloc>().add(
                    BusinessNameChanged(_controller.text.trim()),
                  );
                  context.pushNamed(RouterConstants.onBoardingGstin);
                },
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.pushNamed(RouterConstants.onBoardingGstin);
                  },
                  child: const Text(
                    'Skip this step',
                    style: TextStyle(fontSize: 15, color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

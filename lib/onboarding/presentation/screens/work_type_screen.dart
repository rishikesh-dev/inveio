import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:inveio/onboarding/presentation/widgets/onboarding_row_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Screen that lets the user select their work type during onboarding.
class WorkTypeScreen extends StatelessWidget {
  /// Creates a [WorkTypeScreen].
  const WorkTypeScreen({super.key});

  static const _options = <MapEntry<String, WorkType>>[
    MapEntry("I'm a freelancer", WorkType.freelancer),
    MapEntry('I run a small business', WorkType.business),
    MapEntry("I'm a consultant", WorkType.consultant),
    MapEntry("I'm a contractor", WorkType.contractor),
  ];

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
              const OnboardingProgressBar(currentStep: 3),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.pop(),
                child: const Text(
                  '\u2190',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white60,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'How do you work?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the most relevant option.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white38,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  final selected = state.onboarding.workType;
                  return Column(
                    children: _options.map((entry) {
                      return OnboardingRowOption(
                        label: entry.key,
                        isSelected: selected == entry.value,
                        onTap: () => context.read<OnboardingBloc>().add(
                          WorkTypeSelected(entry.value),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const Spacer(),

              const SizedBox(height: 10),
              BlocConsumer<OnboardingBloc, OnboardingState>(
                listenWhen: (prev, curr) =>
                    curr is OnboardingSuccess || curr is OnboardingFailure,
                listener: (context, state) {
                  if (state is OnboardingSuccess) {
                    context.pushNamed(RouterConstants.onBoardingSuccess);
                  } else if (state is OnboardingFailure) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  final isLoading = state is OnboardingLoading;
                  return NeonButton(
                    borderRadius: BorderRadius.circular(100),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 32,
                    ),
                    label: isLoading ? 'Saving...' : 'Continue',
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<OnboardingBloc>().add(
                              const OnboardingSubmitted(),
                            );
                          },
                  );
                },
              ),
              const SizedBox(height: 15),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.pushNamed(RouterConstants.onBoardingSuccess);
                  },
                  child: const Text(
                    'Skip this step',
                    style: TextStyle(fontSize: 15, color: Colors.white30),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:inveio/shared/presentation/widgets/gstin_text_field_widget.dart';
import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/presentation/widgets/radio_selection_widget.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/shared/theme/app_colors.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/onboarding/presentation/widgets/onboarding_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Screen that collects the user's GSTIN during onboarding.
class GstinScreen extends StatefulWidget {
  /// Creates a [GstinScreen].
  const GstinScreen({super.key});

  @override
  State<GstinScreen> createState() => _GstinScreenState();
}

class _GstinScreenState extends State<GstinScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final gstin = context.read<OnboardingBloc>().state.onboarding.gstin ?? '';
    _controller = TextEditingController(text: gstin);
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    context.read<OnboardingBloc>().add(GstinChanged(_controller.text));
  }

  bool _canContinue(OnboardingEntity onboarding) {
    if (onboarding.gstinStatus == null) return false;
    if (onboarding.gstinStatus == GstinStatus.yes) {
      return GstinTextField.optionalValidator(_controller.text.trim()) == null;
    }
    return true;
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
              const OnboardingProgressBar(currentStep: 2),
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
                'Are you GST registered?',
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
                "Freelancers under the threshold usually aren't. That's fine.",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white38,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  final gstinStatus = state.onboarding.gstinStatus;
                  return RadioGroup<GstinStatus>(
                    groupValue: gstinStatus,
                    onChanged: (value) {
                      if (value == null) return;
                      context.read<OnboardingBloc>().add(
                        GstRegistrationStatusSet(value),
                      );
                    },
                    child: Column(
                      children: [
                        RadioSelectionWidget<GstinStatus>(
                          onTap: () => context.read<OnboardingBloc>().add(
                            const GstRegistrationStatusSet(GstinStatus.yes),
                          ),
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.only(left: 20),
                          value: GstinStatus.yes,
                          label: 'Yes, I have a GSTIN',
                          bgColor: gstinStatus == GstinStatus.yes
                              ? AppColors.primary
                              : null,
                        ),
                        RadioSelectionWidget<GstinStatus>(
                          onTap: () => context.read<OnboardingBloc>().add(
                            const GstRegistrationStatusSet(GstinStatus.notYet),
                          ),
                          padding: const EdgeInsets.only(left: 20),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          bgColor: gstinStatus == GstinStatus.notYet
                              ? AppColors.primary
                              : null,
                          value: GstinStatus.notYet,
                          label: 'Not yet',
                        ),
                        if (gstinStatus == GstinStatus.yes) ...[
                          const SizedBox(height: 4),
                          GstinTextField(
                            controller: _controller,
                            hintText: 'GSTIN',
                            showStateDetection: true,
                            onChanged: (_) => setState(
                              () {},
                            ), // refresh Continue enabled-state
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const Spacer(),
              BlocBuilder<OnboardingBloc, OnboardingState>(
                builder: (context, state) {
                  final enabled = _canContinue(state.onboarding);
                  return Opacity(
                    opacity: enabled ? 1 : 0.4,
                    child: NeonButton(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 32,
                      ),
                      label: 'Continue',
                      borderRadius: BorderRadius.circular(100),
                      onPressed: enabled
                          ? () {
                              context.read<OnboardingBloc>().add(
                                GstinChanged(_controller.text.trim()),
                              );
                              context.pushNamed(RouterConstants.onBoardingType);
                            }
                          : () {}, // no-op while disabled; swap for your Button's real disabled API if it has one
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

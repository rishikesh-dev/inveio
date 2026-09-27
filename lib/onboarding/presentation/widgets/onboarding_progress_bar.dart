import 'package:flutter/material.dart';

/// A horizontal progress bar that indicates the current step in the onboarding flow.
class OnboardingProgressBar extends StatelessWidget {
  /// The 1-indexed current step being displayed.
  final int currentStep;

  /// The total number of steps in the flow.
  final int totalSteps;

  /// Creates an [OnboardingProgressBar] with the given [currentStep] and [totalSteps].
  const OnboardingProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final step = i + 1;
        Color color;
        if (step < currentStep) {
          color = const Color(0xFF00D97E).withValues(alpha: 0.4);
        } else if (step == currentStep) {
          color = const Color(0xFF00D97E);
        } else {
          color = Colors.white10;
        }
        return Expanded(
          child: Container(
            height: 3,
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

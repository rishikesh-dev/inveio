import 'package:inveio/shared/presentation/widgets/neon_button.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/onboarding_bloc.dart';

/// Screen displayed after the user successfully completes onboarding.
class OnboardingSuccessScreen extends StatelessWidget {
  /// Creates an [OnboardingSuccessScreen].
  const OnboardingSuccessScreen({super.key});

  static const _stateNames = <String, String>{
    '01': 'Jammu & Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '13': 'Nagaland',
    '14': 'Manipur',
    '15': 'Mizoram',
    '16': 'Tripura',
    '17': 'Meghalaya',
    '18': 'Assam',
    '19': 'West Bengal',
    '20': 'Jharkhand',
    '21': 'Odisha',
    '22': 'Chhattisgarh',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '25': 'Daman & Diu',
    '26': 'Dadra & Nagar Haveli',
    '27': 'Maharashtra',
    '28': 'Andhra Pradesh',
    '29': 'Karnataka',
    '30': 'Goa',
    '31': 'Lakshadweep',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '34': 'Puducherry',
    '35': 'Andaman & Nicobar',
    '36': 'Telangana',
    '37': 'Andhra Pradesh (New)',
    '38': 'Ladakh',
  };

  @override
  Widget build(BuildContext context) {
    final onboarding = context.watch<OnboardingBloc>().state.onboarding;
    final businessName = onboarding.businessName ?? 'Your business';
    final stateCode = onboarding.stateCode;
    final stateName = stateCode != null && _stateNames.containsKey(stateCode)
        ? _stateNames[stateCode]!
        : 'Standard';

    return Scaffold(
      body: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) {
          if (state is OnboardingSuccess) {
            context.pushNamed(RouterConstants.mainScreen);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CustomPaint(painter: _CheckPainter()),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "You're in.",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$businessName is ready.\n$stateName GST applied automatically.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white38,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  NeonButton(
                    label: 'Go to dashboard',
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 32,
                    ),
                    borderRadius: BorderRadius.circular(100),
                    onPressed: () => context.read<OnboardingBloc>().add(
                      const OnboardingSubmitted(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFFAAFF4D).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paint1);

    final paint2 = Paint()
      ..color = const Color(0xFFAAFF4D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(size.center(Offset.zero), size.width * 0.37, paint2);

    final checkPaint = Paint()
      ..color = const Color(0xFFAAFF4D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path()
      ..moveTo(size.width * 0.32, size.height * 0.5)
      ..lineTo(size.width * 0.45, size.height * 0.63)
      ..lineTo(size.width * 0.68, size.height * 0.37);
    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:async';

import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/shared/routes/app_router_config.dart';

import '../widgets/background_circles.dart';
import '../widgets/bottom_dots.dart';
import '../widgets/center_content.dart';
import '../widgets/floating_coins.dart';
import '../widgets/logo_blob.dart';
import '../widgets/receipt_cards.dart';
import '../widgets/sparkle_dots.dart';
import '../widgets/splash_colors.dart';

/// The initial screen shown on app launch.
///
/// Plays an animated splash sequence that checks authentication status
/// and then navigates to the main screen.
class SplashScreen extends StatefulWidget {
  /// Called after the splash animation completes.
  final VoidCallback? onComplete;

  const SplashScreen({super.key, this.onComplete});

  @override
  /// Creates the [State] object for this [SplashScreen].
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _winkCtrl;
  Timer? _winkTimer;
  late AuthBloc _authBloc;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotate;
  late final Animation<double> _contentFade;
  late final Animation<double> _floatY;
  late final Animation<double> _winkScale;

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _winkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _logoScale =
        TweenSequence([
          TweenSequenceItem(
            tween: Tween(
              begin: 0.0,
              end: 1.15,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 60,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: 1.15,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 40,
          ),
        ]).animate(
          CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.45)),
        );

    _logoRotate = Tween(begin: -0.15, end: 0.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(
          CurvedAnimation(parent: _mainCtrl, curve: const Interval(0.0, 0.45)),
        );

    _contentFade = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOut),
      ),
    );

    _floatY = Tween(
      begin: 0.0,
      end: -13.0,
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_floatCtrl);

    _winkScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.15,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_winkCtrl);

    _authBloc = context.read<AuthBloc>();
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mainCtrl.forward();
    _winkTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _winkCtrl.forward(from: 0);
    });
    debugPrint('SplashScreen: Checking auth status...');
    final authFuture = _authBloc.stream.firstWhere(
      (s) => s is! AuthLoading && s is! AuthInitial,
    );
    _authBloc.add(const CheckAuthStatus());

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 500)),
      authFuture,
    ]);
    final authState = _authBloc.state;
    debugPrint('SplashScreen: Auth status: $authState');
    if (authState is AuthSignedIn) {
      onboardingBloc.add(CheckOnboardingStatus(authState.user.uid));
    }
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _floatCtrl.dispose();
    _winkCtrl.dispose();
    _winkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashColors.bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_mainCtrl, _floatCtrl, _winkCtrl]),
        builder: (context, _) {
          final floatOffset = _floatY.value;

          return Stack(
            children: [
              const BackgroundCircles(),
              SparkleDots(animValue: _floatCtrl.value),
              FloatingCoins(floatOffset: floatOffset),
              ReceiptCards(floatOffset: floatOffset),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: _logoRotate.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: LogoBlob(winkScale: _winkScale.value),
                      ),
                    ),
                    const SizedBox(height: 6),
                    CenterContent(contentFade: _contentFade.value),
                  ],
                ),
              ),
              BottomDots(opacity: _contentFade.value),
            ],
          );
        },
      ),
    );
  }
}

import 'dart:async';

import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/auth/presentation/screens/forgot_password_screen.dart';
import 'package:inveio/auth/presentation/screens/sign_in_screen.dart';
import 'package:inveio/auth/presentation/screens/sign_up_screen.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/profile/presentation/screens/account/change_password/change_password_screen.dart';
import 'package:inveio/profile/presentation/screens/account/security_screen.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/shared/dependencies/app_dependencies.dart';
import 'package:inveio/shared/routes/route_data/delete_account_route_data.dart';
import 'package:inveio/shared/routes/route_data/edit_profile_route_data.dart';
import 'package:inveio/shared/routes/route_data/scan_result_route_data.dart';
import 'package:inveio/shared/routes/router_constants.dart';
import 'package:inveio/expenses/presentation/screens/add_expense_screen.dart';
import 'package:inveio/expenses/presentation/screens/transaction_details_screen.dart';
import 'package:inveio/invoice/presentation/screens/add_invoice_screen.dart';
import 'package:inveio/home/presentation/screens/home_screen.dart';
import 'package:inveio/invoice/presentation/screens/invoice_screen.dart';
import 'package:inveio/shared/presentation/screens/main_screen.dart';
import 'package:inveio/onboarding/presentation/screens/business_name_screen.dart';
import 'package:inveio/onboarding/presentation/screens/gstin_screen.dart';
import 'package:inveio/onboarding/presentation/screens/onboarding_success_screen.dart';
import 'package:inveio/onboarding/presentation/screens/work_type_screen.dart';
import 'package:inveio/profile/presentation/screens/account/delete_account_confirmation_screen.dart';
import 'package:inveio/profile/presentation/screens/account/edit_profile_screen.dart';
import 'package:inveio/profile/presentation/screens/profile_screen.dart';
import 'package:inveio/reports/presentation/screens/reports_screen.dart';
import 'package:inveio/scan/presentation/screens/scan_receipt_screen.dart';
import 'package:inveio/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authBloc = AppDependencies.sl<AuthBloc>();
final onboardingBloc = AppDependencies.sl<OnboardingBloc>();
final sharedPrefs = AppDependencies.sl<SharedPreferences>();

/// Configures the [GoRouter] instance with route definitions and auth guards.
class AppRouterConfig {
  /// The [GoRouter] instance used for declarative navigation.
  static GoRouter goRouter = GoRouter(
    refreshListenable: StreamNotifier([authBloc.stream, onboardingBloc.stream]),
    initialLocation: RouterConstants.splash,
    redirect: (context, state) {
      final authState = authBloc.state;
      final onboardingState = onboardingBloc.state;
      final location = state.matchedLocation;
      debugPrint(
        'REDIRECT: auth=$authState onboarding=$onboardingState loc=$location',
      );
      final protectedRoutes = {
        RouterConstants.mainScreen,
        RouterConstants.addExpense,
        RouterConstants.addInvoice,
        RouterConstants.editInvoice,
        RouterConstants.profile,
        RouterConstants.editProfile,
        RouterConstants.deleteAccountConfirmation,
        RouterConstants.settings,
        RouterConstants.securityScreen,
        RouterConstants.changePasswordScreen,
      };

      final isOnboardingPage = location.startsWith(RouterConstants.onBoarding);
      // don't redirect while auth is still resolving
      if (authState is AuthErrorState) {
        return null;
      }
      if (authState is AuthLoading || authState is AuthInitial) return null;

      if (authState is! AuthSignedIn) {
        if (location == RouterConstants.splash) return RouterConstants.signIn;
        if (protectedRoutes.contains(location)) {
          return RouterConstants.signIn;
        }

        if (isOnboardingPage) {
          return RouterConstants.signIn;
        }

        return null;
      }

      if (onboardingState is OnboardingLoading ||
          onboardingState is OnboardingUnknown) {
        return null;
      }
      final onboardingComplete = onboardingState.onboarding.onboardingComplete;
      final isSuccessPage = location == RouterConstants.onBoardingSuccess;

      if (location == RouterConstants.splash) {
        return onboardingComplete
            ? RouterConstants.mainScreen
            : RouterConstants.onBoardingName;
      }

      if (!onboardingComplete && !isOnboardingPage) {
        return RouterConstants.onBoardingName;
      }
      if (onboardingComplete && isOnboardingPage && !isSuccessPage) {
        return RouterConstants.mainScreen;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: RouterConstants.splash,
        name: RouterConstants.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            Scaffold(body: SafeArea(child: child)),
        routes: [
          GoRoute(
            path: RouterConstants.onBoardingName,
            name: RouterConstants.onBoardingName,
            builder: (context, state) => const BusinessNameScreen(),
          ),
          GoRoute(
            path: RouterConstants.onBoardingGstin,
            name: RouterConstants.onBoardingGstin,
            builder: (context, state) => const GstinScreen(),
          ),
          GoRoute(
            path: RouterConstants.onBoardingType,
            name: RouterConstants.onBoardingType,
            builder: (context, state) => const WorkTypeScreen(),
          ),
          GoRoute(
            path: RouterConstants.onBoardingSuccess,
            name: RouterConstants.onBoardingSuccess,
            builder: (context, state) => const OnboardingSuccessScreen(),
          ),
        ],
      ),

      GoRoute(
        path: RouterConstants.mainScreen,
        name: RouterConstants.mainScreen,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: RouterConstants.home,
        name: RouterConstants.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouterConstants.invoice,
        name: RouterConstants.invoice,
        builder: (context, state) => const InvoiceScreen(),
      ),
      GoRoute(
        path: RouterConstants.scanReceipt,
        name: RouterConstants.scanReceipt,
        builder: (context, state) => const ScanReceiptScreen(),
      ),
      GoRoute(
        path: RouterConstants.reports,
        name: RouterConstants.reports,
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: RouterConstants.profile,
        name: RouterConstants.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouterConstants.editProfile,
        name: RouterConstants.editProfile,
        builder: (context, state) {
          final userData = state.extra as EditProfileRouteData;

          return EditProfileScreen(
            userData: userData.userData,
            onBoardingData: userData.onboardingData,
          );
        },
      ),
      GoRoute(
        path: RouterConstants.securityScreen,
        name: RouterConstants.securityScreen,
        builder: (context, state) {
          return const SecurityScreen();
        },
      ),
      GoRoute(
        path: RouterConstants.changePasswordScreen,
        name: RouterConstants.changePasswordScreen,
        builder: (context, state) {
          return const ChangePasswordScreen();
        },
      ),
      GoRoute(
        path: RouterConstants.deleteAccountConfirmation,
        name: RouterConstants.deleteAccountConfirmation,
        builder: (context, state) {
          final userData = state.extra as DeleteAccountRouteData;
          return DeleteAccountConfirmationScreen(userData: userData.userData);
        },
      ),
      GoRoute(
        path: RouterConstants.signUp,
        name: RouterConstants.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: RouterConstants.signIn,
        name: RouterConstants.signIn,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: RouterConstants.forgotPassword,
        name: RouterConstants.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: RouterConstants.addExpense,
        name: RouterConstants.addExpense,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is ScanResultRouteData) {
            return AddExpenseScreen(
              scannedData: extra.data,
              scannedImagePath: extra.imagePath,
            );
          }
          return const AddExpenseScreen();
        },
      ),

      GoRoute(
        path: RouterConstants.addInvoice,
        name: RouterConstants.addInvoice,
        builder: (context, state) {
          final extra = state.extra;
          if (extra is ScanResultRouteData) {
            return AddInvoiceScreen(scannedData: extra.data);
          }
          return const AddInvoiceScreen();
        },
      ),
      GoRoute(
        path: RouterConstants.editInvoice,
        name: RouterConstants.editInvoice,
        builder: (context, state) {
          final entity = state.extra as TransactionEntity?;
          return AddInvoiceScreen(initialTransaction: entity);
        },
      ),
      GoRoute(
        path: RouterConstants.transactionDetails,
        name: RouterConstants.transactionDetails,
        builder: (context, state) {
          return TransactionDetailsScreen(expenseId: state.extra.toString());
        },
      ),
    ],
  );
}

/// Listens to a [Stream] and notifies listeners whenever a new event is emitted.
///
/// Used as a [ChangeNotifier] to make [GoRouter] react to auth state changes.
class StreamNotifier extends ChangeNotifier {
  /// The subscription to the underlying stream.
  late final List<StreamSubscription> _subscriptions;

  /// Creates a [StreamNotifier] that listens to the given [stream].
  StreamNotifier(List<Stream> streams) {
    _subscriptions = streams.map((stream) {
      return stream.listen((_) {
        notifyListeners();
      });
    }).toList();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

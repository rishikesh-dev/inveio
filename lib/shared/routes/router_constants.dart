/// Route path constants used with [GoRouter].
class RouterConstants {
  /// Main / shell screen route.
  static const String mainScreen = '/';

  /// Home screen route.
  static const String home = '/home';

  /// Splash screen route.
  static const String splash = '/splash';

  /// Onboarding flow root route.
  static const String onBoarding = '/onboarding';

  /// Onboarding – business name screen route.
  static const String onBoardingName = '/onboarding/name';

  /// Onboarding – GSTIN screen route.
  static const String onBoardingGstin = '/onboarding/gstin';

  /// Onboarding – work type screen route.
  static const String onBoardingType = '/onboarding/type';

  /// Onboarding – success screen route.
  static const String onBoardingSuccess = '/onboarding/success';

  /// Sign-in screen route.
  static const String signIn = '/sign-in';

  /// Sign-up screen route.
  static const String signUp = '/sign-up';

  /// Forgot password screen route.
  static const String forgotPassword = '/forgot-password';

  /// Edit profile screen route.
  static const String editProfile = '/edit-profile';

  /// Business details screen route.
  static const String businessDetails = '/business-details';

  /// Delete account confirmation screen route.
  static const String deleteAccountConfirmation =
      '/delete-account-confirmation';

  /// Invoice list screen route.
  static const String invoice = '/invoice';

  /// Reports screen route.
  static const String reports = '/reports';

  /// Settings screen route.
  static const String settings = '/settings';

  /// Profile screen route.
  static const String profile = '/profile';

  /// Add invoice screen route.
  static const String addInvoice = '/add-invoice';

  /// Edit invoice screen route. `:id` is the transaction's local ID.
  static const String editInvoice = '/edit-invoice/:id';

  /// Add expense screen route.
  static const String addExpense = '/add-expense';

  /// Edit expense screen route. `:id` is the transaction's local ID.
  static const String editExpense = '/expense/:id/edit';

  /// Transaction details screen route.
  static const String transactionDetails = '/transaction-details';
  static const String securityScreen = '/security-screen';
  static const String changePasswordScreen = '/change-password-screen';
}

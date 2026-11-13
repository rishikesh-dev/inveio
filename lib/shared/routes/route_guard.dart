import 'package:inveio/shared/routes/router_constants.dart';

/// Routes that may only be reached by a signed-in user.
const Set<String> protectedRoutes = {
  RouterConstants.mainScreen,
  RouterConstants.addExpense,
  RouterConstants.editExpense,
  RouterConstants.addInvoice,
  RouterConstants.editInvoice,
  RouterConstants.profile,
  RouterConstants.editProfile,
  RouterConstants.deleteAccountConfirmation,
  RouterConstants.settings,
  RouterConstants.securityScreen,
  RouterConstants.changePasswordScreen,
};

/// Whether [location] requires a signed-in user.
///
/// [location] is a concrete `matchedLocation`, so parameterized routes arrive
/// with their values already substituted (e.g. `/expense/42/edit`) and never
/// equal their constant (`/expense/:id/edit`). Each route is therefore also
/// matched on the template prefix up to the first `:id` segment.
bool isProtectedLocation(String location) {
  return protectedRoutes.any((route) {
    if (location == route) return true;
    final prefix = route.split('/:').first;
    return location.startsWith('$prefix/');
  });
}

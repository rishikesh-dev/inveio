import 'package:flutter_test/flutter_test.dart';
import 'package:inveio/shared/routes/route_guard.dart';
import 'package:inveio/shared/routes/router_constants.dart';

/// Covers the predicate the router's `redirect` uses to send signed-out users
/// to the sign-in screen: `isProtectedLocation(location)` returning true means
/// a signed-out visitor is redirected away from [location].
void main() {
  group('isProtectedLocation', () {
    test('guards a plain protected route', () {
      expect(isProtectedLocation(RouterConstants.profile), isTrue);
      expect(isProtectedLocation(RouterConstants.addExpense), isTrue);
    });

    test('leaves open routes unguarded', () {
      expect(isProtectedLocation(RouterConstants.splash), isFalse);
      expect(isProtectedLocation(RouterConstants.signIn), isFalse);
      expect(isProtectedLocation(RouterConstants.signUp), isFalse);
      expect(isProtectedLocation(RouterConstants.forgotPassword), isFalse);
      expect(isProtectedLocation(RouterConstants.onBoardingName), isFalse);
      expect(isProtectedLocation('/some/unknown/route'), isFalse);
    });

    test('guards /expense/5/edit when logged out', () {
      expect(isProtectedLocation('/expense/5/edit'), isTrue);
    });

    test('guards every parameterized route after substitution', () {
      expect(isProtectedLocation('/expense/42/edit'), isTrue);
      expect(isProtectedLocation('/edit-invoice/7'), isTrue);
    });

    test('does not guard a route merely sharing a name prefix', () {
      // '/expenses' is not a route, and must not be swept up by the
      // '/expense/:id/edit' template prefix.
      expect(isProtectedLocation('/expenses'), isFalse);
    });
  });
}

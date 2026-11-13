import 'package:flutter_test/flutter_test.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/transaction/domain/services/gst_recalculator.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingLocalDataSource extends Mock
    implements OnboardingLocalDataSource {}

void main() {
  late MockOnboardingLocalDataSource onboarding;
  late GstRecalculator calculator;

  setUp(() {
    onboarding = MockOnboardingLocalDataSource();
    when(() => onboarding.getStateCode()).thenAnswer((_) async => '27');
    calculator = GstRecalculator(onboardingLocalDataSource: onboarding);
  });

  const totals = [250.0, 99.99, 1.0, 0.50, 1234.56];
  const rates = [5, 12, 18, 28];

  for (final rate in rates) {
    group('$rate% inclusive totals', () {
      for (final total in totals) {
        test('$total splits back to $total to the paisa', () async {
          final breakdown = await calculator.recalculateFromInclusiveTotal(
            totalAmount: total,
            counterpartyGstin: '27AAAAA0000A1Z5',
            gstRate: rate / 100,
          );

          final taxablePaisa = (breakdown.taxableAmount * 100).round();
          final cgstPaisa = (breakdown.cgst * 100).round();
          final sgstPaisa = (breakdown.sgst * 100).round();

          expect(
            taxablePaisa + cgstPaisa + sgstPaisa,
            (total * 100).round(),
            reason: 'components must add back to the inclusive total',
          );
          expect(breakdown.isInterState, isFalse);
          expect(breakdown.igst, 0);
        });
      }
    });
  }

  test('puts the leftover paisa on SGST', () async {
    final breakdown = await calculator.recalculateFromInclusiveTotal(
      totalAmount: 99.99,
      counterpartyGstin: '27AAAAA0000A1Z5',
      gstRate: 0.18,
    );

    expect(breakdown.taxableAmount, closeTo(84.74, 0.001));
    expect(breakdown.cgst, closeTo(7.62, 0.001));
    expect(breakdown.sgst, closeTo(7.63, 0.001));
  });
}

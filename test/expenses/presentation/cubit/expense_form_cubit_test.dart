import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inveio/expenses/domain/entities/expense_prefill.dart';
import 'package:inveio/expenses/presentation/cubit/expense_form_cubit.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockOnboardingLocalDataSource extends Mock
    implements OnboardingLocalDataSource {}

TransactionEntity _fallbackEntity() => TransactionEntity(
  uid: 'uid',
  type: TransactionType.expense,
  totalAmount: 0,
  taxableAmount: 0,
  gstSlab: 18,
  isInterState: false,
  cgst: 0,
  sgst: 0,
  igst: 0,
  description: '',
  date: DateTime(2024),
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  late MockTransactionRepository repository;
  late MockOnboardingLocalDataSource onboarding;

  setUpAll(() {
    registerFallbackValue(_fallbackEntity());
  });

  setUp(() {
    repository = MockTransactionRepository();
    onboarding = MockOnboardingLocalDataSource();
    when(() => onboarding.getStateCode()).thenAnswer((_) async => '27');
  });

  ExpenseFormCubit buildCubit() => ExpenseFormCubit(
    transactionRepository: repository,
    onboardingLocalDataSource: onboarding,
    uid: 'test-uid',
  );

  group('amountChanged', () {
    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'recalculates the GST breakdown for intra-state supply',
      build: buildCubit,
      act: (cubit) => cubit.amountChanged('1000'),
      expect: () => [
        isA<ExpenseFormState>()
            .having((s) => s.amount, 'amount', 1000)
            .having((s) => s.gst.taxableAmount, 'taxableAmount', 1000)
            .having((s) => s.gst.cgst, 'cgst', 90)
            .having((s) => s.gst.sgst, 'sgst', 90)
            .having((s) => s.gst.igst, 'igst', 0)
            .having((s) => s.gst.isInterState, 'isInterState', false),
      ],
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'recalculates IGST for inter-state supply',
      build: buildCubit,
      act: (cubit) async {
        await cubit.amountChanged('1000');
        await cubit.gstinChanged('29ABCDE1234F1Z5');
      },
      expect: () => [
        isA<ExpenseFormState>(),
        isA<ExpenseFormState>()
            .having((s) => s.gst.cgst, 'cgst', 0)
            .having((s) => s.gst.sgst, 'sgst', 0)
            .having((s) => s.gst.igst, 'igst', 180)
            .having((s) => s.gst.isInterState, 'isInterState', true),
      ],
    );
  });

  group('populateFromScan then save', () {
    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'sends an entity with correct totals and CGST/SGST split',
      build: () {
        when(() => repository.upsertTransaction(any())).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as TransactionEntity),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.populateFromScan(
          const ExpensePrefill(
            amount: 1000,
            gstin: '27AAAAA0000A1Z5',
            vendorName: 'Acme Traders',
          ),
        );
        await cubit.save();
      },
      expect: () => [
        // populateFromScan recalculates GST (fix 1)
        isA<ExpenseFormState>()
            .having((s) => s.amount, 'amount', 1000)
            .having(
              (s) => s.description,
              'description',
              'Purchase from Acme Traders',
            )
            .having((s) => s.gst.cgst, 'cgst', 90)
            .having((s) => s.gst.sgst, 'sgst', 90),
        // save -> isSaving
        isA<ExpenseFormState>().having((s) => s.isSaving, 'isSaving', true),
        // save -> success
        isA<ExpenseFormState>().having(
          (s) => s.saveSuccess,
          'saveSuccess',
          true,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => repository.upsertTransaction(captureAny()),
        ).captured;
        final entity = captured.single as TransactionEntity;
        expect(entity.totalAmount, 1180);
        expect(entity.taxableAmount, 1000);
        expect(entity.cgst, 90);
        expect(entity.sgst, 90);
        expect(entity.igst, 0);
        expect(entity.isInterState, false);
        expect(entity.description, 'Purchase from Acme Traders');
        expect(entity.vendorName, 'Acme Traders');
        expect(entity.vendorGstin, '27AAAAA0000A1Z5');
        expect(entity.gstSlab, 18);
        expect(entity.uid, 'test-uid');
      },
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'sends an entity with IGST split when the scan is inter-state',
      build: () {
        when(() => repository.upsertTransaction(any())).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as TransactionEntity),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.populateFromScan(
          const ExpensePrefill(
            amount: 1000,
            gstin: '29ABCDE1234F1Z5',
            vendorName: 'Bengaluru Supplies',
          ),
        );
        await cubit.save();
      },
      verify: (_) {
        final captured = verify(
          () => repository.upsertTransaction(captureAny()),
        ).captured;
        final entity = captured.single as TransactionEntity;
        expect(entity.totalAmount, 1180);
        expect(entity.taxableAmount, 1000);
        expect(entity.cgst, 0);
        expect(entity.sgst, 0);
        expect(entity.igst, 180);
        expect(entity.isInterState, true);
      },
    );
  });
}

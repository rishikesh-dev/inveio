import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inveio/expenses/domain/entities/expense_prefill.dart';
import 'package:inveio/expenses/presentation/cubit/expense_form_cubit.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/shared/errors/failure.dart';
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

/// A previously saved expense, as the repository would return it on edit.
TransactionEntity storedExpenseForEdit() => _fallbackEntity().copyWith(
  localId: 7,
  id: 'server-7',
  totalAmount: 1180,
  taxableAmount: 1000,
  gstSlab: 18,
  isInterState: false,
  cgst: 90,
  sgst: 90,
  igst: 0,
  description: 'Office supplies',
  date: DateTime(2024, 1, 15),
  createdAt: DateTime(2024, 1, 15, 9),
  updatedAt: DateTime(2024, 1, 15, 9),
  vendorName: 'Acme Traders',
  vendorGstin: '27AAAAA0000A1Z5',
  category: 'Office',
  paymentMode: PaymentMode.upi,
  itcEligible: false,
  receiptUrl: '/tmp/receipt.png',
);

/// The same saved expense, but supplied inter-state (IGST only).
TransactionEntity storedInterStateExpenseForEdit() => storedExpenseForEdit()
    .copyWith(isInterState: true, cgst: 0, sgst: 0, igst: 180);

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
          ExpensePrefill(
            amount: 118,
            gstin: '27AAAAA0000A1Z5',
            vendorName: 'Acme Traders',
            transactionDate: DateTime(2026, 3, 12),
          ),
        );
        await cubit.save();
      },
      expect: () => [
        // The printed total is tax-inclusive: 118 at 18% -> 100 + 18
        isA<ExpenseFormState>()
            .having((s) => s.amount, 'amount', closeTo(100, 0.001))
            .having((s) => s.isGstRateDefault, 'isGstRateDefault', true)
            .having(
              (s) => s.description,
              'description',
              'Purchase from Acme Traders',
            )
            .having((s) => s.gst.cgst, 'cgst', closeTo(9, 0.001))
            .having((s) => s.gst.sgst, 'sgst', closeTo(9, 0.001)),
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
        expect(entity.totalAmount, closeTo(118, 0.001));
        expect(entity.taxableAmount, closeTo(100, 0.001));
        expect(entity.cgst, closeTo(9, 0.001));
        expect(entity.sgst, closeTo(9, 0.001));
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
          ExpensePrefill(
            amount: 118,
            gstin: '29ABCDE1234F1Z5',
            vendorName: 'Bengaluru Supplies',
            transactionDate: DateTime(2026, 3, 12),
          ),
        );
        await cubit.save();
      },
      verify: (_) {
        final captured = verify(
          () => repository.upsertTransaction(captureAny()),
        ).captured;
        final entity = captured.single as TransactionEntity;
        expect(entity.totalAmount, closeTo(118, 0.001));
        expect(entity.taxableAmount, closeTo(100, 0.001));
        expect(entity.cgst, 0);
        expect(entity.sgst, 0);
        expect(entity.igst, closeTo(18, 0.001));
        expect(entity.isInterState, true);
      },
    );
  });

  group('scanned amounts are tax-inclusive', () {
    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'keeps the printed total unchanged when the rate changes to 0%',
      build: buildCubit,
      act: (cubit) async {
        await cubit.populateFromScan(
          const ExpensePrefill(amount: 118, gstin: '27AAAAA0000A1Z5'),
        );
        await cubit.gstRateChanged(0);
      },
      verify: (cubit) {
        expect(cubit.state.amount, closeTo(118, 0.001));
        expect(cubit.state.gst.taxableAmount, closeTo(118, 0.001));
        expect(cubit.state.gst.cgst, 0);
        expect(cubit.state.gst.sgst, 0);
        expect(cubit.state.gst.igst, 0);
        expect(cubit.state.isGstRateDefault, isFalse);
      },
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'back-calculates the taxable value when the rate changes to 5%',
      build: buildCubit,
      act: (cubit) async {
        await cubit.populateFromScan(
          const ExpensePrefill(amount: 118, gstin: '27AAAAA0000A1Z5'),
        );
        await cubit.gstRateChanged(5);
      },
      verify: (cubit) {
        expect(cubit.state.amount, closeTo(112.38, 0.01));
        expect(cubit.state.gst.taxableAmount, closeTo(112.38, 0.01));
        expect(cubit.state.gst.cgst, closeTo(2.81, 0.01));
        expect(cubit.state.gst.sgst, closeTo(2.81, 0.01));
        expect(
          cubit.state.gst.taxableAmount +
              cubit.state.gst.cgst +
              cubit.state.gst.sgst,
          closeTo(118, 0.02),
        );
        expect(cubit.state.isGstRateDefault, isFalse);
      },
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'keeps manual entry taxable (tax is still added on top)',
      build: buildCubit,
      act: (cubit) => cubit.amountChanged('1000'),
      verify: (cubit) {
        expect(cubit.state.amount, 1000);
        expect(cubit.state.gst.taxableAmount, 1000);
        expect(cubit.state.gst.cgst, 90);
        expect(cubit.state.gst.sgst, 90);
        expect(cubit.state.isGstRateDefault, isFalse);
      },
    );
  });

  group('scan without a date', () {
    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'leaves the form date empty and blocks save',
      build: buildCubit,
      act: (cubit) async {
        await cubit.populateFromScan(
          const ExpensePrefill(amount: 118, gstin: '27AAAAA0000A1Z5'),
        );
        await cubit.save();
      },
      verify: (cubit) {
        expect(cubit.state.date, isNull);
        expect(cubit.state.saveError, 'Date not found, please set it');
        expect(cubit.state.saveSuccess, isFalse);
        verifyNever(() => repository.upsertTransaction(any()));
      },
    );
  });

  group('amount guard', () {
    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'blocks saving when the amount is zero',
      build: buildCubit,
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<ExpenseFormState>()
            .having((s) => s.amount, 'amount', 0)
            .having((s) => s.amountError, 'amountError', isNotNull)
            .having((s) => s.isSaving, 'isSaving', isFalse)
            .having((s) => s.saveSuccess, 'saveSuccess', isFalse),
      ],
      verify: (_) => verifyNever(() => repository.upsertTransaction(any())),
    );
  });

  group('loadForEdit', () {
    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'restores the saved fields and GST breakdown',
      build: () {
        when(
          () => repository.getTransactionByLocalId(7),
        ).thenAnswer((_) async => right(storedExpenseForEdit()));
        return buildCubit();
      },
      act: (cubit) => cubit.loadForEdit('7'),
      expect: () => [
        isA<ExpenseFormState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.notFound, 'notFound', false),
        isA<ExpenseFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.editingId, 'editingId', '7')
            .having((s) => s.createdAt, 'createdAt', DateTime(2024, 1, 15, 9))
            .having((s) => s.amount, 'amount', 1180)
            .having((s) => s.description, 'description', 'Office supplies')
            .having((s) => s.vendorName, 'vendorName', 'Acme Traders')
            .having((s) => s.counterpartyGstin, 'gstin', '27AAAAA0000A1Z5')
            .having((s) => s.category, 'category', 'Office')
            .having((s) => s.paymentMode, 'paymentMode', PaymentMode.upi)
            .having((s) => s.itcEligible, 'itcEligible', false)
            .having((s) => s.receiptPath, 'receiptPath', '/tmp/receipt.png'),
      ],
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'does not recalculate the stored GST split',
      build: () {
        when(
          () => repository.getTransactionByLocalId(7),
        ).thenAnswer((_) async => right(storedExpenseForEdit()));
        return buildCubit();
      },
      act: (cubit) => cubit.loadForEdit('7'),
      verify: (cubit) {
        expect(cubit.state.gst.taxableAmount, 1000);
        expect(cubit.state.gst.cgst, 90);
        expect(cubit.state.gst.sgst, 90);
        expect(cubit.state.gst.igst, 0);
        expect(cubit.state.gst.isInterState, false);
        verifyNever(() => repository.upsertTransaction(any()));
      },
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'preserves an inter-state IGST split through load and save',
      build: () {
        when(
          () => repository.getTransactionByLocalId(7),
        ).thenAnswer((_) async => right(storedInterStateExpenseForEdit()));
        when(() => repository.upsertTransaction(any())).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as TransactionEntity),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadForEdit('7');
        await cubit.save();
      },
      verify: (_) {
        final captured = verify(
          () => repository.upsertTransaction(captureAny()),
        ).captured;
        final entity = captured.single as TransactionEntity;
        expect(entity.isInterState, isTrue);
        expect(entity.cgst, 0);
        expect(entity.sgst, 0);
        expect(entity.igst, 180);
        expect(entity.taxableAmount, 1000);
        expect(entity.totalAmount, 1180);
      },
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'flags notFound when the id does not resolve',
      build: () {
        when(
          () => repository.getTransactionByLocalId(99),
        ).thenAnswer((_) async => right(null));
        return buildCubit();
      },
      act: (cubit) => cubit.loadForEdit('99'),
      expect: () => [
        isA<ExpenseFormState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ExpenseFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.notFound, 'notFound', true),
      ],
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'flags notFound without hitting the repository for a malformed id',
      build: buildCubit,
      act: (cubit) => cubit.loadForEdit('not-a-number'),
      expect: () => [
        isA<ExpenseFormState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ExpenseFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.notFound, 'notFound', true),
      ],
      verify: (_) =>
          verifyNever(() => repository.getTransactionByLocalId(any())),
    );

    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'surfaces a repository failure as a save error',
      build: () {
        when(
          () => repository.getTransactionByLocalId(7),
        ).thenAnswer((_) async => const Left(CacheFailure('read failed')));
        return buildCubit();
      },
      act: (cubit) => cubit.loadForEdit('7'),
      expect: () => [
        isA<ExpenseFormState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ExpenseFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.notFound, 'notFound', false)
            .having((s) => s.saveError, 'saveError', 'read failed'),
      ],
    );
  });

  group('save in edit mode', () {
    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'keeps the local id, server id and createdAt while moving updatedAt',
      build: () {
        when(
          () => repository.getTransactionByLocalId(7),
        ).thenAnswer((_) async => right(storedExpenseForEdit()));
        when(() => repository.upsertTransaction(any())).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as TransactionEntity),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadForEdit('7');
        cubit.descriptionChanged('Office supplies Q1');
        await cubit.save();
      },
      verify: (_) {
        final captured = verify(
          () => repository.upsertTransaction(captureAny()),
        ).captured;
        final entity = captured.single as TransactionEntity;
        expect(entity.localId, 7);
        expect(entity.id, 'server-7');
        expect(entity.createdAt, DateTime(2024, 1, 15, 9));
        expect(entity.updatedAt.isAfter(DateTime(2024, 1, 15, 9)), isTrue);
        expect(entity.description, 'Office supplies Q1');
        expect(entity.type, TransactionType.expense);
        expect(entity.taxableAmount, 1000);
        expect(entity.cgst, 90);
        expect(entity.sgst, 90);
        expect(entity.totalAmount, 1180);
      },
    );
  });

  group('save and load for edit round trip', () {
    blocTest<ExpenseFormCubit, ExpenseFormState>(
      'field total equals the saved total after round trip',
      build: () {
        when(() => repository.upsertTransaction(any())).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as TransactionEntity),
        );
        when(
          () => repository.getTransactionByLocalId(7),
        ).thenAnswer((_) async => right(storedExpenseForEdit()));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.populateFromScan(
          ExpensePrefill(
            amount: 1000,
            gstin: '27AAAAA0000A1Z5',
            vendorName: 'Acme Traders',
            transactionDate: DateTime(2026, 3, 12),
          ),
        );
        await cubit.save();
        await cubit.loadForEdit('7');
      },
      verify: (cubit) {
        expect(cubit.state.amount, 1180);
        expect(cubit.state.gst.taxableAmount, 1000);
        expect(cubit.state.gst.cgst, 90);
        expect(cubit.state.gst.sgst, 90);
        expect(cubit.state.gst.igst, 0);
      },
    );
  });
}

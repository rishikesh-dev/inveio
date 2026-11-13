import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inveio/invoice/presentation/cubit/invoice_form_cubit.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/extraction_result.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockOnboardingLocalDataSource extends Mock
    implements OnboardingLocalDataSource {}

TransactionEntity _fallbackEntity() => TransactionEntity(
  uid: 'uid',
  type: TransactionType.invoice,
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

  InvoiceFormCubit buildCubit() => InvoiceFormCubit(
    transactionRepository: repository,
    onboardingLocalDataSource: onboarding,
    uid: 'test-uid',
  );

  group('save', () {
    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'happy path emits isSaving then saveSuccess',
      build: () {
        when(() => repository.upsertTransaction(any())).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as TransactionEntity),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.amountChanged('500');
        await cubit.clientGstinChanged('27AAAAA0000A1Z5');
        cubit.clientNameChanged('Acme');
        await cubit.save();
      },
      expect: () => [
        isA<InvoiceFormState>()
            .having((s) => s.amount, 'amount', 500)
            .having((s) => s.gst.cgst, 'cgst', 45)
            .having((s) => s.gst.sgst, 'sgst', 45),
        isA<InvoiceFormState>().having(
          (s) => s.clientGstin,
          'clientGstin',
          '27AAAAA0000A1Z5',
        ),
        isA<InvoiceFormState>().having(
          (s) => s.clientName,
          'clientName',
          'Acme',
        ),
        isA<InvoiceFormState>().having((s) => s.isSaving, 'isSaving', true),
        isA<InvoiceFormState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.saveSuccess, 'saveSuccess', true),
      ],
      verify: (_) {
        final captured = verify(
          () => repository.upsertTransaction(captureAny()),
        ).captured;
        final entity = captured.single as TransactionEntity;
        expect(entity.type, TransactionType.invoice);
        expect(entity.totalAmount, 590);
        expect(entity.taxableAmount, 500);
        expect(entity.cgst, 45);
        expect(entity.sgst, 45);
        expect(entity.igst, 0);
        expect(entity.clientName, 'Acme');
        expect(entity.clientGstin, '27AAAAA0000A1Z5');
        expect(entity.paymentStatus, PaymentStatus.draft);
      },
    );

    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'failure path emits isSaving then saveError',
      build: () {
        when(
          () => repository.upsertTransaction(any()),
        ).thenAnswer((_) async => const Left(CacheFailure('save failed')));
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.amountChanged('100');
        await cubit.save();
      },
      expect: () => [
        isA<InvoiceFormState>().having((s) => s.amount, 'amount', 100),
        isA<InvoiceFormState>().having((s) => s.isSaving, 'isSaving', true),
        isA<InvoiceFormState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.saveSuccess, 'saveSuccess', false)
            .having((s) => s.saveError, 'saveError', 'save failed'),
      ],
    );
  });

  group('populateFromScan', () {
    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'back-calculates the taxable value from a tax-inclusive scanned total',
      build: () {
        when(() => repository.upsertTransaction(any())).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as TransactionEntity),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.populateFromScan(
          ParsedReceipt(
            rawText: 'Total ₹118',
            amount: const ExtractionResult<double>(118, true),
            date: ExtractionResult<DateTime>(DateTime(2026, 3, 12), true),
            vendor: const ExtractionResult<String>('Acme Traders', true),
            gstin: const ExtractionResult<String>('27AAAAA0000A1Z5', true),
          ),
        );
        await cubit.save();
      },
      expect: () => [
        // Printed total 118 at 18% -> taxable 100, CGST 9, SGST 9
        isA<InvoiceFormState>()
            .having((s) => s.amount, 'amount', closeTo(100, 0.001))
            .having((s) => s.gst.taxableAmount, 'taxableAmount', closeTo(100, 0.001))
            .having((s) => s.gst.cgst, 'cgst', closeTo(9, 0.001))
            .having((s) => s.gst.sgst, 'sgst', closeTo(9, 0.001))
            .having((s) => s.description, 'description', 'Purchase from Acme Traders')
            .having((s) => s.clientName, 'clientName', 'Acme Traders')
            .having((s) => s.clientGstin, 'clientGstin', '27AAAAA0000A1Z5')
            .having((s) => s.date, 'date', DateTime(2026, 3, 12)),
        isA<InvoiceFormState>().having((s) => s.isSaving, 'isSaving', true),
        isA<InvoiceFormState>().having(
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
        expect(entity.type, TransactionType.invoice);
        expect(entity.totalAmount, closeTo(118, 0.001));
        expect(entity.taxableAmount, closeTo(100, 0.001));
        expect(entity.cgst, closeTo(9, 0.001));
        expect(entity.sgst, closeTo(9, 0.001));
        expect(entity.igst, 0);
        expect(entity.isInterState, false);
        expect(entity.gstSlab, 18);
        expect(entity.clientName, 'Acme Traders');
        expect(entity.clientGstin, '27AAAAA0000A1Z5');
        expect(entity.description, 'Purchase from Acme Traders');
        expect(entity.uid, 'test-uid');
      },
    );

    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'persists the scanned image path with the invoice',
      build: () {
        when(() => repository.upsertTransaction(any())).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as TransactionEntity),
        );
        return buildCubit();
      },
      act: (cubit) async {
        cubit.receiptAttached('/tmp/receipt.png');
        await cubit.amountChanged('100');
        cubit.clientNameChanged('Acme');
        await cubit.save();
      },
      verify: (_) {
        final captured = verify(
          () => repository.upsertTransaction(captureAny()),
        ).captured;
        final entity = captured.single as TransactionEntity;
        expect(entity.receiptUrl, '/tmp/receipt.png');
      },
    );
  });

  group('scanned amounts are tax-inclusive', () {
    blocTest<InvoiceFormCubit, InvoiceFormState>(
      're-derives the taxable value when the rate changes after a scan',
      build: buildCubit,
      act: (cubit) async {
        await cubit.populateFromScan(
          ParsedReceipt(
            rawText: 'Total ₹118',
            amount: const ExtractionResult<double>(118, true),
            date: ExtractionResult<DateTime>(DateTime(2026, 3, 12), true),
            vendor: const ExtractionResult<String>('Acme Traders', true),
            gstin: const ExtractionResult<String>('27AAAAA0000A1Z5', true),
          ),
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
        expect(cubit.state.gstSlab, 5);
      },
    );

    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'keeps manual entry taxable (tax is still added on top)',
      build: buildCubit,
      act: (cubit) => cubit.amountChanged('1000'),
      verify: (cubit) {
        expect(cubit.state.amount, 1000);
        expect(cubit.state.gst.taxableAmount, 1000);
        expect(cubit.state.gst.cgst, 90);
        expect(cubit.state.gst.sgst, 90);
      },
    );
  });

  group('scan without a date', () {
    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'leaves the form date empty and blocks save',
      build: buildCubit,
      act: (cubit) async {
        await cubit.populateFromScan(
          const ParsedReceipt(
            rawText: 'Total ₹118',
            amount: ExtractionResult<double>(118, true),
            date: ExtractionResult<DateTime>(null, false),
            vendor: ExtractionResult<String>('Acme Traders', true),
            gstin: ExtractionResult<String>('27AAAAA0000A1Z5', true),
          ),
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
    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'blocks saving when the amount is zero',
      build: buildCubit,
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<InvoiceFormState>()
            .having((s) => s.amount, 'amount', 0)
            .having((s) => s.amountError, 'amountError', isNotNull)
            .having((s) => s.isSaving, 'isSaving', isFalse)
            .having((s) => s.saveSuccess, 'saveSuccess', isFalse),
      ],
      verify: (_) => verifyNever(() => repository.upsertTransaction(any())),
    );
  });

  group('loadForEdit', () {
    TransactionEntity storedInvoice() => _fallbackEntity().copyWith(
      localId: 7,
      id: 'server-7',
      totalAmount: 1180,
      taxableAmount: 1000,
      gstSlab: 18,
      isInterState: false,
      cgst: 90,
      sgst: 90,
      igst: 0,
      description: 'Consulting',
      clientName: 'Beta Pvt Ltd',
      clientGstin: '27AAAAA0000A1Z5',
      invoiceNumber: 'INV-42',
      date: DateTime(2024, 1, 15),
      createdAt: DateTime(2024, 1, 15, 9),
      updatedAt: DateTime(2024, 1, 15, 9),
      dueDate: DateTime(2024, 2, 1),
    );

    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'restores the saved fields and GST breakdown',
      build: () {
        when(
          () => repository.getTransactionByLocalId(7),
        ).thenAnswer((_) async => right(storedInvoice()));
        return buildCubit();
      },
      act: (cubit) => cubit.loadForEdit('7'),
      expect: () => [
        isA<InvoiceFormState>()
            .having((s) => s.isLoading, 'isLoading', true)
            .having((s) => s.notFound, 'notFound', false),
        isA<InvoiceFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.editingId, 'editingId', '7')
            .having((s) => s.createdAt, 'createdAt', DateTime(2024, 1, 15, 9))
            .having((s) => s.amount, 'amount', 1000)
            .having((s) => s.description, 'description', 'Consulting')
            .having((s) => s.clientName, 'clientName', 'Beta Pvt Ltd')
            .having((s) => s.clientGstin, 'clientGstin', '27AAAAA0000A1Z5')
            .having((s) => s.invoiceNumber, 'invoiceNumber', 'INV-42')
            .having((s) => s.dueDate, 'dueDate', DateTime(2024, 2, 1))
            .having((s) => s.date, 'date', DateTime(2024, 1, 15)),
      ],
    );

    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'does not recalculate the stored GST split',
      build: () {
        // A Karnataka counterparty would be recalculated as intra-state by the
        // onboarding state code, but the stored split must survive untouched.
        when(() => repository.getTransactionByLocalId(7)).thenAnswer(
          (_) async =>
              right(storedInvoice().copyWith(isInterState: false, igst: 0)),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.loadForEdit('7'),
      verify: (cubit) {
        expect(cubit.state.gst.cgst, 90);
        expect(cubit.state.gst.sgst, 90);
        expect(cubit.state.gst.igst, 0);
        expect(cubit.state.gst.isInterState, false);
        expect(cubit.state.gst.taxableAmount, 1000);
        verifyNever(() => repository.upsertTransaction(any()));
      },
    );

    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'flags notFound when the id does not resolve',
      build: () {
        when(
          () => repository.getTransactionByLocalId(99),
        ).thenAnswer((_) async => right(null));
        return buildCubit();
      },
      act: (cubit) => cubit.loadForEdit('99'),
      expect: () => [
        isA<InvoiceFormState>().having((s) => s.isLoading, 'isLoading', true),
        isA<InvoiceFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.notFound, 'notFound', true),
      ],
    );

    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'flags notFound without hitting the repository for a malformed id',
      build: buildCubit,
      act: (cubit) => cubit.loadForEdit('not-a-number'),
      expect: () => [
        isA<InvoiceFormState>().having((s) => s.isLoading, 'isLoading', true),
        isA<InvoiceFormState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.notFound, 'notFound', true),
      ],
      verify: (_) =>
          verifyNever(() => repository.getTransactionByLocalId(any())),
    );
  });

  group('save in edit mode', () {
    blocTest<InvoiceFormCubit, InvoiceFormState>(
      'keeps the local id, server id and createdAt while moving updatedAt',
      build: () {
        final created = DateTime(2024, 1, 15, 9);
        when(() => repository.getTransactionByLocalId(7)).thenAnswer(
          (_) async => right(
            _fallbackEntity().copyWith(
              localId: 7,
              id: 'server-7',
              taxableAmount: 1000,
              cgst: 90,
              sgst: 90,
              createdAt: created,
              updatedAt: created,
            ),
          ),
        );
        when(() => repository.upsertTransaction(any())).thenAnswer(
          (invocation) async =>
              Right(invocation.positionalArguments.first as TransactionEntity),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadForEdit('7');
        cubit.descriptionChanged('Consulting Q1');
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
        expect(entity.description, 'Consulting Q1');
        expect(entity.type, TransactionType.invoice);
        expect(entity.taxableAmount, 1000);
        expect(entity.cgst, 90);
        expect(entity.sgst, 90);
      },
    );
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inveio/invoice/presentation/cubit/invoice_form_cubit.dart';
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
      act: (cubit) => cubit.save(),
      expect: () => [
        isA<InvoiceFormState>().having((s) => s.isSaving, 'isSaving', true),
        isA<InvoiceFormState>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.saveSuccess, 'saveSuccess', false)
            .having((s) => s.saveError, 'saveError', 'save failed'),
      ],
    );
  });

  group('populateFromEntity', () {
    test('copies entity fields and GST breakdown into the state', () {
      final entity = _fallbackEntity().copyWith(
        localId: 7,
        totalAmount: 1180,
        taxableAmount: 1000,
        gstSlab: 18,
        cgst: 90,
        sgst: 90,
        igst: 0,
        description: 'Consulting',
        clientName: 'Beta Pvt Ltd',
        clientGstin: '27AAAAA0000A1Z5',
        invoiceNumber: 'INV-42',
        dueDate: DateTime(2024, 2, 1),
      );

      final cubit = buildCubit()..populateFromEntity(entity);

      expect(cubit.state.amount, 1000);
      expect(cubit.state.description, 'Consulting');
      expect(cubit.state.clientName, 'Beta Pvt Ltd');
      expect(cubit.state.clientGstin, '27AAAAA0000A1Z5');
      expect(cubit.state.invoiceNumber, 'INV-42');
      expect(cubit.state.dueDate, DateTime(2024, 2, 1));
      expect(cubit.state.gst.taxableAmount, 1000);
      expect(cubit.state.gst.cgst, 90);
      expect(cubit.state.gst.sgst, 90);
      expect(cubit.state.gst.igst, 0);
    });
  });
}

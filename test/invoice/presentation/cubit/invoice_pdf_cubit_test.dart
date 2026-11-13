import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inveio/invoice/domain/services/invoice_pdf_generator.dart';
import 'package:inveio/invoice/presentation/cubit/invoice_pdf_cubit.dart'
    show FontLoader, InvoicePdfCubit;
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:mocktail/mocktail.dart';

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

class MockInvoicePdfGenerator extends Mock implements InvoicePdfGenerator {}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

void main() {
  setUpAll(() {
    registerFallbackValue(
      InvoicePdfInput(
        invoice: TransactionEntity(
          uid: 'uid',
          type: TransactionType.invoice,
          totalAmount: 0,
          taxableAmount: 0,
          gstSlab: 0,
          isInterState: false,
          cgst: 0,
          sgst: 0,
          igst: 0,
          description: '',
          date: DateTime(2026),
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
        business: const OnboardingEntity.empty(),
      ),
    );
  });
  late MockOnboardingRepository repository;
  late MockInvoicePdfGenerator generator;
  late InvoicePdfCubit cubit;
  late FontLoader failingFontLoader;
  late FontLoader successFontLoader;

  setUp(() {
    repository = MockOnboardingRepository();
    generator = MockInvoicePdfGenerator();
    failingFontLoader = (_) async => null;
    successFontLoader = (_) async => ByteData(8);
    cubit = InvoicePdfCubit(
      onboardingRepository: repository,
      generator: generator,
      uid: 'test-uid',
      fontLoader: successFontLoader,
    );
  });

  tearDown(() {
    cubit.close();
  });

  TransactionEntity invoice({
    String? invoiceNumber,
    double taxableAmount = 1000.0,
  }) {
    return TransactionEntity(
      uid: 'uid-1',
      type: TransactionType.invoice,
      totalAmount: taxableAmount + 180.0,
      taxableAmount: taxableAmount,
      gstSlab: 18,
      isInterState: false,
      cgst: 90.0,
      sgst: 90.0,
      igst: 0.0,
      description: 'Consulting services',
      date: DateTime(2026, 3, 12),
      invoiceNumber: invoiceNumber,
      createdAt: DateTime(2026, 3, 12),
      updatedAt: DateTime(2026, 3, 12),
    );
  }

  OnboardingEntity business({String? businessName}) {
    return OnboardingEntity(businessName: businessName, address: '123 Street');
  }

  test('build returns PDF bytes and emits success state', () async {
    when(() => repository.getOnboarding('test-uid')).thenAnswer(
      (_) async => Right(business(businessName: 'Acme Pvt Ltd')),
    );
    when(() => generator.generate(
      any(),
      regularFont: any(named: 'regularFont'),
      boldFont: any(named: 'boldFont'),
    )).thenAnswer(
      (_) async => Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
    );

    final successCubit = InvoicePdfCubit(
      onboardingRepository: repository,
      generator: generator,
      uid: 'test-uid',
      fontLoader: successFontLoader,
    );

    final bytes = await successCubit.build(invoice(invoiceNumber: 'INV-001'));

    expect(bytes, equals(Uint8List.fromList([0x25, 0x50, 0x44, 0x46])));
    expect(successCubit.state.pdfBytes, equals(Uint8List.fromList([0x25, 0x50, 0x44, 0x46])));
    expect(successCubit.state.filename, 'INV-001.pdf');
    expect(successCubit.state.isLoading, isFalse);
    expect(successCubit.state.error, isNull);
    await successCubit.close();
  });

  test('missing business details emits error and returns null', () async {
    when(() => repository.getOnboarding('test-uid')).thenAnswer(
      (_) async => Right(business(businessName: '')),
    );

    final bytes = await cubit.build(invoice());

    expect(bytes, isNull);
    expect(cubit.state.pdfBytes, isNull);
    expect(cubit.state.error, contains('Business Details'));
    expect(cubit.state.isLoading, isFalse);
  });

  test('generator failure emits error and returns null', () async {
    when(() => repository.getOnboarding('test-uid')).thenAnswer(
      (_) async => Right(business(businessName: 'Acme Pvt Ltd')),
    );
    when(() => generator.generate(
      any(),
      regularFont: any(named: 'regularFont'),
      boldFont: any(named: 'boldFont'),
    )).thenThrow(Exception('boom'));

    final bytes = await cubit.build(invoice());

    expect(bytes, isNull);
    expect(cubit.state.pdfBytes, isNull);
    expect(cubit.state.error, contains('Failed to generate PDF'));
    expect(cubit.state.isLoading, isFalse);
  });

  test('repository failure emits error and returns null', () async {
    when(() => repository.getOnboarding('test-uid')).thenAnswer(
      (_) async => const Left(CacheFailure('db error')),
    );

    final bytes = await cubit.build(invoice());

    expect(bytes, isNull);
    expect(cubit.state.pdfBytes, isNull);
    expect(cubit.state.error, isNotNull);
    expect(cubit.state.isLoading, isFalse);
  });

  test('font load failure emits error and returns null', () async {
    when(() => repository.getOnboarding('test-uid')).thenAnswer(
      (_) async => Right(business(businessName: 'Acme Pvt Ltd')),
    );

    final failingCubit = InvoicePdfCubit(
      onboardingRepository: repository,
      generator: generator,
      uid: 'test-uid',
      fontLoader: failingFontLoader,
    );

    final bytes = await failingCubit.build(invoice());

    expect(bytes, isNull);
    expect(failingCubit.state.pdfBytes, isNull);
    expect(failingCubit.state.error, contains('font'));
    expect(failingCubit.state.isLoading, isFalse);
    await failingCubit.close();
  });
}

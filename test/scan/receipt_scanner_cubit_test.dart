import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/extraction_result.dart';
import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
import 'package:inveio/scan/domain/failures/scan_failures.dart';
import 'package:inveio/scan/domain/repositories/scan_receipt_repository.dart';
import 'package:inveio/scan/presentation/cubit/receipt_scanner_cubit.dart';
import 'package:inveio/shared/errors/failure.dart';
import 'package:mocktail/mocktail.dart';

class MockScanReceiptRepository extends Mock implements ScanReceiptRepository {}

ParsedReceipt _draft({double? amount}) => ParsedReceipt(
  rawText: 'receipt text',
  amount: ExtractionResult(amount, amount != null),
  date: const ExtractionResult(null, false),
  vendor: const ExtractionResult(null, false),
  gstin: const ExtractionResult(null, false),
);

void main() {
  late MockScanReceiptRepository repository;

  setUpAll(() {
    registerFallbackValue(File('/tmp/receipt.png'));
  });

  setUp(() {
    repository = MockScanReceiptRepository();
    when(
      () => repository.scanReceipt(),
    ).thenAnswer((_) async => right(File('/tmp/receipt.png')));
  });

  ReceiptScannerCubit buildCubitWith(ParsedReceipt draft) {
    when(
      () => repository.extractReceiptData(any()),
    ).thenAnswer((_) async => right(draft));
    return ReceiptScannerCubit(scanReceiptRepository: repository);
  }

  group('ScannerSuccess.hasUsableAmount', () {
    blocTest<ReceiptScannerCubit, ReceiptScannerState>(
      'is false when no amount was found',
      build: () => buildCubitWith(_draft()),
      act: (cubit) => cubit.scanReceipt(),
      expect: () => [
        isA<ScannerSuccess>().having(
          (state) => state.hasUsableAmount,
          'hasUsableAmount',
          isFalse,
        ),
      ],
    );

    blocTest<ReceiptScannerCubit, ReceiptScannerState>(
      'is false when the amount is zero',
      build: () => buildCubitWith(_draft(amount: 0)),
      act: (cubit) => cubit.scanReceipt(),
      expect: () => [
        isA<ScannerSuccess>().having(
          (state) => state.hasUsableAmount,
          'hasUsableAmount',
          isFalse,
        ),
      ],
    );

    blocTest<ReceiptScannerCubit, ReceiptScannerState>(
      'is true when only the amount was found',
      build: () => buildCubitWith(_draft(amount: 84.80)),
      act: (cubit) => cubit.scanReceipt(),
      expect: () => [
        isA<ScannerSuccess>()
            .having((state) => state.hasUsableAmount, 'hasUsableAmount', isTrue)
            .having((state) => state.draft.amount.value, 'amount', 84.80)
            .having((state) => state.draft.vendor.value, 'vendor', isNull),
      ],
    );
  });

  group('cancelling the scan', () {
    blocTest<ReceiptScannerCubit, ReceiptScannerState>(
      'emits nothing when the very first scan is cancelled',
      setUp: () {
        when(
          () => repository.scanReceipt(),
        ).thenAnswer((_) async => const Left(ScanCancelledFailure()));
      },
      build: () => ReceiptScannerCubit(scanReceiptRepository: repository),
      act: (cubit) => cubit.scanReceipt(),
      expect: () => <ReceiptScannerState>[],
    );

    blocTest<ReceiptScannerCubit, ReceiptScannerState>(
      'returns to the initial state after a successful scan is cancelled',
      setUp: () {
        when(
          () => repository.scanReceipt(),
        ).thenAnswer((_) async => const Left(ScanCancelledFailure()));
      },
      build: () => ReceiptScannerCubit(scanReceiptRepository: repository),
      seed: () => ScannerSuccess(_draft(amount: 10)),
      act: (cubit) => cubit.scanReceipt(),
      expect: () => [isA<ReceiptScannerInitial>()],
    );
  });

  group('scan failures', () {
    blocTest<ReceiptScannerCubit, ReceiptScannerState>(
      'emits a failure with a readable message when the scan fails',
      setUp: () {
        when(() => repository.scanReceipt()).thenAnswer(
          (_) async => const Left(
            CacheFailure('Could not scan the document. Please try again.'),
          ),
        );
      },
      build: () => ReceiptScannerCubit(scanReceiptRepository: repository),
      act: (cubit) => cubit.scanReceipt(),
      expect: () => [
        isA<ScannerFailure>()
            .having(
              (state) => state.reason,
              'reason',
              'Could not scan the document. Please try again.',
            ),
      ],
    );

    blocTest<ReceiptScannerCubit, ReceiptScannerState>(
      'retrying after a failure succeeds',
      setUp: () {
        var attempts = 0;
        when(() => repository.scanReceipt()).thenAnswer((_) async {
          attempts++;
          if (attempts == 1) {
            return const Left(
              CacheFailure('Could not scan the document. Please try again.'),
            );
          }
          return right(File('/tmp/receipt.png'));
        });
        when(
          () => repository.extractReceiptData(any()),
        ).thenAnswer((_) async => right(_draft(amount: 42)));
      },
      build: () => ReceiptScannerCubit(scanReceiptRepository: repository),
      act: (cubit) async {
        await cubit.scanReceipt();
        await cubit.scanReceipt();
      },
      expect: () => [
        isA<ScannerFailure>(),
        isA<ReceiptScannerInitial>(),
        isA<ScannerSuccess>().having(
          (state) => state.hasUsableAmount,
          'hasUsableAmount',
          isTrue,
        ),
      ],
    );

    blocTest<ReceiptScannerCubit, ReceiptScannerState>(
      'does not flag a text-recognition failure as permission denied',
      setUp: () {
        when(() => repository.extractReceiptData(any())).thenAnswer(
          (_) async => const Left(
            CacheFailure('Could not read the document. Please try again.'),
          ),
        );
      },
      build: () => ReceiptScannerCubit(scanReceiptRepository: repository),
      act: (cubit) => cubit.scanReceipt(),
      expect: () => [
        isA<ScannerFailure>()
            .having(
              (state) => state.reason,
              'reason',
              'Could not read the document. Please try again.',
            ),
      ],
    );
  });
}

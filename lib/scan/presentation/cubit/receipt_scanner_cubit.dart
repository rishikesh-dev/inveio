import 'package:inveio/scan/domain/entities/parsed_receipt.dart';
import 'package:inveio/scan/domain/failures/scan_failures.dart';
import 'package:inveio/scan/domain/repositories/scan_receipt_repository.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'receipt_scanner_state.dart';

class ReceiptScannerCubit extends Cubit<ReceiptScannerState> {
  final ScanReceiptRepository scanReceiptRepository;
  ReceiptScannerCubit({required this.scanReceiptRepository})
    : super(ReceiptScannerInitial());
  Future<void> scanReceipt() async {
    // Reset first so every scan (including a retake) is handled fresh by the
    // screen. Starting from the initial state already means "not handled".
    if (state is! ReceiptScannerInitial) emit(ReceiptScannerInitial());
    final result = await scanReceiptRepository.scanReceipt();
    await result.fold(
      (failure) async {
        if (failure is ScanCancelledFailure) {
          // Cancelling is not an error: return to the idle state silently.
          if (state is! ReceiptScannerInitial) emit(ReceiptScannerInitial());
          return;
        }
        emit(ScannerFailure(failure.message));
      },
      (success) async {
        final imagePath = success.path;
        final extractInfo = await scanReceiptRepository.extractReceiptData(
          success,
        );
        extractInfo.fold(
          (failure) => emit(ScannerFailure(failure.message)),
          (extractedInfo) =>
              emit(ScannerSuccess(extractedInfo, imagePath: imagePath)),
        );
      },
    );
  }
}

import 'package:inveio/scan/domain/entities/scan_receipt_entity.dart';
import 'package:inveio/scan/domain/repositories/scan_receipt_repository.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'receipt_scanner_state.dart';

class ReceiptScannerCubit extends Cubit<ReceiptScannerState> {
  final ScanReceiptRepository scanReceiptRepository;
  ReceiptScannerCubit({required this.scanReceiptRepository})
    : super(ReceiptScannerInitial());
  Future<void> scanReceipt() async {
    final result = await scanReceiptRepository.scanReceipt();
    await result.fold(
      (failure) async => emit(ScannerFailure(failure.message)),
      (success) async {
        final imagePath = success.path;
        final extractInfo = await scanReceiptRepository.extractReceiptData(
          success,
        );
        extractInfo.fold(
          (failure) => emit(ScannerFailure(failure.message)),
          (extractedInfo) => emit(
            ScannerSuccess(extractedInfo, imagePath: imagePath),
          ),
        );
      },
    );
  }
}

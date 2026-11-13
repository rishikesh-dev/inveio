import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/settings/data/services/csv_export_service.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';

part 'export_data_state.dart';

/// Cubit that exports expenses and invoices to a CSV file.
class ExportDataCubit extends Cubit<ExportDataState> {
  final TransactionRepository _repository;
  final CsvExportService _exportService;

  /// Creates an [ExportDataCubit] with the given [repository] and service.
  ExportDataCubit({
    required TransactionRepository repository,
    required CsvExportService exportService,
  }) : _repository = repository,
       _exportService = exportService,
       super(const ExportDataInitial());

  /// Loads all transactions and writes them to a CSV file.
  Future<void> exportData() => _export();

  /// Loads invoices only and writes them to a CSV file.
  Future<void> exportInvoices() =>
      _export(type: TransactionType.invoice, filePrefix: 'inveio_invoices');

  Future<void> _export({
    TransactionType? type,
    String filePrefix = 'inveio_export',
  }) async {
    emit(const ExportDataInProgress());
    final result = await _repository.getAllTransactions();
    await result.fold(
      (failure) async => emit(ExportDataFailure(failure.message)),
      (transactions) async {
        try {
          final filtered = type == null
              ? transactions
              : transactions.where((transaction) => transaction.type == type);
          final path = await _exportService.export(
            filtered.toList(),
            filePrefix: filePrefix,
          );
          emit(ExportDataSuccess(path));
        } catch (e) {
          emit(ExportDataFailure(e.toString()));
        }
      },
    );
  }
}

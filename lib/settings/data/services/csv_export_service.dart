import 'dart:io';

import 'package:inveio/transaction/domain/entities/transaction_entity.dart';
import 'package:path_provider/path_provider.dart';

/// Writes transactions to a CSV file in the temporary directory.
class CsvExportService {
  static const _headers = <String>[
    'Type',
    'Date',
    'Description',
    'Party',
    'GSTIN',
    'Taxable Amount',
    'GST Slab',
    'CGST',
    'SGST',
    'IGST',
    'Total Amount',
    'Payment Mode',
    'Payment Status',
    'Invoice Number',
  ];

  /// Exports [transactions] (expenses and invoices) to a CSV file and returns
  /// the path of the written file. [filePrefix] names the generated file.
  Future<String> export(
    List<TransactionEntity> transactions, {
    String filePrefix = 'inveio_export',
  }) async {
    final buffer = StringBuffer()..writeln(_encodeRow(_headers));
    for (final transaction in transactions) {
      buffer.writeln(_encodeRow(_row(transaction)));
    }

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/${filePrefix}_'
      '${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  List<String> _row(TransactionEntity transaction) {
    final isExpense = transaction.type == TransactionType.expense;
    return [
      transaction.type.name,
      transaction.date.toIso8601String(),
      transaction.description,
      (isExpense ? transaction.vendorName : transaction.clientName) ?? '',
      (isExpense ? transaction.vendorGstin : transaction.clientGstin) ?? '',
      transaction.taxableAmount.toStringAsFixed(2),
      transaction.gstSlab.toString(),
      transaction.cgst.toStringAsFixed(2),
      transaction.sgst.toStringAsFixed(2),
      transaction.igst.toStringAsFixed(2),
      transaction.totalAmount.toStringAsFixed(2),
      transaction.paymentMode?.name ?? '',
      transaction.paymentStatus?.name ?? '',
      transaction.invoiceNumber ?? '',
    ];
  }

  String _encodeRow(List<String> cells) => cells.map(_encodeCell).join(',');

  String _encodeCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }
}

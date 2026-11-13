import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';

/// A single row rendered in the invoice PDF line-item table.
class InvoiceLineItem {
  /// Creates an [InvoiceLineItem].
  const InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.rate,
    required this.taxableAmount,
  });

  /// Line description shown in the table.
  final String description;

  /// Quantity of the item.
  final int quantity;

  /// Per-unit taxable rate.
  final double rate;

  /// Taxable amount for the line (quantity * rate).
  final double taxableAmount;
}

/// Input supplied to [InvoicePdfGenerator.generate].
class InvoicePdfInput {
  /// Creates an [InvoicePdfInput].
  const InvoicePdfInput({
    required this.invoice,
    required this.business,
    this.phone,
    this.email,
    this.items,
  });

  /// The invoice to render.
  final TransactionEntity invoice;

  /// Saved business details (seller header).
  final OnboardingEntity business;

  /// Optional seller phone number.
  final String? phone;

  /// Optional seller email address.
  final String? email;

  /// Line items for the table. When `null` or empty, a single item is derived
  /// from the invoice entity's description and taxable amount.
  final List<InvoiceLineItem>? items;
}

/// Generates an A4 invoice PDF as [Uint8List] bytes.
///
/// Free of Flutter widgets and [BuildContext] so it can be unit tested.
class InvoicePdfGenerator {
  /// Creates an [InvoicePdfGenerator].
  const InvoicePdfGenerator();

  /// Renders [input] to PDF bytes.
  ///
  /// [regularFont] and [boldFont] are the raw bytes of the TTF fonts used to
  /// render text. They must contain the ₹ glyph (e.g. the bundled Inter
  /// Regular/Bold). When omitted the built-in Helvetica font is used, which
  /// cannot render ₹.
  Future<Uint8List> generate(InvoicePdfInput input,
      {ByteData? regularFont, ByteData? boldFont}) async {
    final regular = regularFont != null ? pw.Font.ttf(regularFont) : null;
    final bold = boldFont != null ? pw.Font.ttf(boldFont) : regular;
    final baseFont = bold ?? regular;

    final titleStyle = pw.TextStyle(
      font: baseFont,
      fontSize: 22,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final headingStyle = pw.TextStyle(
      font: baseFont,
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );
    final baseStyle = pw.TextStyle(
      font: baseFont,
      fontSize: 9.5,
      color: PdfColors.black,
    );
    final smallStyle = pw.TextStyle(
      font: baseFont,
      fontSize: 8,
      color: PdfColors.grey,
    );

    final invoice = input.invoice;
    final business = input.business;

    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        footer: (_) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Generated with Inveio',
            style: smallStyle,
          ),
        ),
        build: (_) => <pw.Widget>[
          _businessHeader(business, input.phone, input.email, titleStyle, baseStyle),
          pw.SizedBox(height: 20),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Expanded(
                child: _metaPair(
                  'Invoice No',
                  invoice.invoiceNumber != null && invoice.invoiceNumber!.isNotEmpty
                      ? invoice.invoiceNumber!
                      : '—',
                  headingStyle,
                  baseStyle,
                ),
              ),
              pw.Expanded(
                child: _metaPair(
                  'Date',
                  DateFormat('dd MMM yyyy').format(invoice.date),
                  headingStyle,
                  baseStyle,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('Bill To', style: headingStyle),
          pw.SizedBox(height: 4),
          pw.Text(
            invoice.clientName != null && invoice.clientName!.isNotEmpty
                ? invoice.clientName!
                : 'Customer',
            style: baseStyle,
          ),
          if (invoice.clientGstin != null && invoice.clientGstin!.isNotEmpty)
            pw.SizedBox(height: 2),
          if (invoice.clientGstin != null && invoice.clientGstin!.isNotEmpty)
            pw.Text(
              'GSTIN: ${invoice.clientGstin}',
              style: baseStyle,
            ),
          pw.SizedBox(height: 24),
          _lineTable(input, baseStyle, headingStyle),
          pw.SizedBox(height: 20),
          _taxBlock(invoice, baseStyle, headingStyle),
          pw.SizedBox(height: 16),
          _totalRow(invoice, baseStyle),
        ],
      ),
    );

    return doc.save();
  }

  pw.Widget _businessHeader(
    OnboardingEntity business,
    String? phone,
    String? email,
    pw.TextStyle titleStyle,
    pw.TextStyle baseStyle,
  ) {
    final children = <pw.Widget>[];
    if (business.businessName != null && business.businessName!.isNotEmpty) {
      children.add(pw.Text(business.businessName!, style: titleStyle));
    }
    if (business.address != null && business.address!.isNotEmpty) {
      children.add(pw.SizedBox(height: 2));
      children.add(pw.Text(business.address!, style: baseStyle));
    }
    final contact = <String>[];
    if (business.gstin != null && business.gstin!.isNotEmpty) {
      contact.add('GSTIN: ${business.gstin}');
    }
    if (phone != null && phone.isNotEmpty) {
      contact.add('Phone: $phone');
    }
    if (email != null && email.isNotEmpty) {
      contact.add('Email: $email');
    }
    if (contact.isNotEmpty) {
      children.add(pw.SizedBox(height: 4));
      children.add(pw.Text(contact.join('  |  '), style: baseStyle));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: children,
    );
  }

  pw.Widget _metaPair(String label, String value, pw.TextStyle headingStyle, pw.TextStyle baseStyle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Text(label, style: headingStyle),
        pw.SizedBox(height: 2),
        pw.Text(value, style: baseStyle),
      ],
    );
  }

  pw.Widget _lineTable(
    InvoicePdfInput input,
    pw.TextStyle baseStyle,
    pw.TextStyle headingStyle,
  ) {
    final rows = _tableRows(input);
    return pw.TableHelper.fromTextArray(
      headers: <String>['Description', 'Qty', 'Rate', 'Taxable Amount'],
      data: rows,
      cellStyle: baseStyle,
      headerStyle: headingStyle,
      cellAlignments: <int, pw.AlignmentGeometry>{
        1: pw.Alignment.centerRight,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
      },
      border: const pw.TableBorder(
        left: pw.BorderSide(),
        right: pw.BorderSide(),
        top: pw.BorderSide(),
        bottom: pw.BorderSide(),
        horizontalInside: pw.BorderSide(),
        verticalInside: pw.BorderSide(),
      ),
    );
  }

  List<List<dynamic>> _tableRows(InvoicePdfInput input) {
    final items = input.items;
    if (items == null || items.isEmpty) {
      return <List<dynamic>>[
        <dynamic>[
          input.invoice.description.isNotEmpty
              ? input.invoice.description
              : 'Invoice',
          1,
          _inr(input.invoice.taxableAmount),
          _inr(input.invoice.taxableAmount),
        ],
      ];
    }
    return items
        .map(
          (item) => <dynamic>[
            item.description,
            item.quantity,
            _inr(item.rate),
            _inr(item.taxableAmount),
          ],
        )
        .toList();
  }

  pw.Widget _taxBlock(
    TransactionEntity invoice,
    pw.TextStyle baseStyle,
    pw.TextStyle headingStyle,
  ) {
    final lines = <pw.Widget>[
      pw.Text('Tax', style: headingStyle),
      pw.SizedBox(height: 4),
    ];
    final rateLabel = _rateLabel(invoice.gstSlab);
    if (invoice.isInterState) {
      lines.add(pw.Text(
        'IGST ($rateLabel%): ${_inr(invoice.igst)}',
        style: baseStyle,
      ));
    } else {
      final half = invoice.gstSlab / 2;
      final halfLabel = half == half.toInt() ? half.toInt().toString() : half.toString();
      lines.add(pw.Text(
        'CGST ($halfLabel%): ${_inr(invoice.cgst)}',
        style: baseStyle,
      ));
      lines.add(pw.Text(
        'SGST ($halfLabel%): ${_inr(invoice.sgst)}',
        style: baseStyle,
      ));
    }
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines,
    );
  }

  pw.Widget _totalRow(TransactionEntity invoice, pw.TextStyle baseStyle) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.Expanded(
          child: pw.Text(
            'Total',
            style: pw.TextStyle(
              font: baseStyle.font,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
        pw.Text(
          _inr(invoice.totalAmount),
          style: pw.TextStyle(
            font: baseStyle.font,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
      ],
    );
  }

  String _rateLabel(int gstSlab) {
    return gstSlab.toString();
  }

  /// Formats [amount] with the ₹ symbol and Indian digit grouping
  /// (e.g. 1,23,456.00).
  String _inr(double amount) {
    final neg = amount < 0;
    final s = amount.abs().toStringAsFixed(2);
    final dot = s.indexOf('.');
    final intPart = s.substring(0, dot);
    final dec = s.substring(dot);
    final parts = <String>[];
    var n = intPart.length;
    if (n > 3) {
      parts.add(intPart.substring(n - 3));
      n -= 3;
      while (n > 0) {
        final start = n - 2;
        parts.add(intPart.substring(start < 0 ? 0 : start, n));
        n -= 2;
      }
    } else {
      parts.add(intPart);
    }
    return '${neg ? '-₹' : '₹'}${parts.reversed.join(',')}$dec';
  }
}

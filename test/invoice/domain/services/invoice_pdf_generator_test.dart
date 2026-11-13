import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inveio/invoice/domain/services/invoice_pdf_generator.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';

void main() {
  late ByteData regularFont;
  late ByteData boldFont;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    regularFont = await rootBundle.load(
      'assets/fonts/Inter/Inter_28pt-Regular.ttf',
    );
    boldFont = await rootBundle.load(
      'assets/fonts/Inter/Inter_28pt-Bold.ttf',
    );
  });

  TransactionEntity invoice({
    String? clientName,
    String? clientGstin,
    String? invoiceNumber,
    bool isInterState = false,
    double taxableAmount = 1000.0,
    double cgst = 90.0,
    double sgst = 90.0,
    double igst = 0.0,
  }) {
    final total = taxableAmount + cgst + sgst + igst;
    return TransactionEntity(
      uid: 'uid-1',
      type: TransactionType.invoice,
      totalAmount: total,
      taxableAmount: taxableAmount,
      gstSlab: 18,
      isInterState: isInterState,
      cgst: cgst,
      sgst: sgst,
      igst: igst,
      description: 'Consulting services',
      date: DateTime(2026, 3, 12),
      clientName: clientName,
      clientGstin: clientGstin,
      invoiceNumber: invoiceNumber,
      createdAt: DateTime(2026, 3, 12),
      updatedAt: DateTime(2026, 3, 12),
    );
  }

  OnboardingEntity business({
    String? businessName,
    String? address,
    String? gstin,
  }) {
    return OnboardingEntity(
      businessName: businessName,
      address: address,
      gstin: gstin,
    );
  }

  InvoicePdfInput input({
    required TransactionEntity invoice,
    required OnboardingEntity business,
    String? phone,
    String? email,
    List<InvoiceLineItem>? items,
  }) {
    return InvoicePdfInput(
      invoice: invoice,
      business: business,
      phone: phone,
      email: email,
      items: items,
    );
  }

  Future<Uint8List> generate(InvoicePdfInput input) =>
      const InvoicePdfGenerator().generate(
        input,
        regularFont: regularFont,
        boldFont: boldFont,
      );

  test('returns non-empty PDF bytes starting with %PDF', () async {
    final bytes = await generate(
      input(invoice: invoice(), business: business(businessName: 'Acme Pvt Ltd')),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), startsWith('%PDF'));
  });

  test('missing optional fields do not throw', () async {
    final bytes = await generate(
      input(
        invoice: invoice(
          clientName: null,
          clientGstin: null,
          invoiceNumber: null,
        ),
        business: business(
          businessName: '',
          address: null,
          gstin: null,
        ),
        phone: null,
        email: null,
      ),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), startsWith('%PDF'));
  });

  test('inter-state invoice uses IGST and does not throw', () async {
    final bytes = await generate(
      input(
        invoice: invoice(
          isInterState: true,
          taxableAmount: 1000.0,
          cgst: 0.0,
          sgst: 0.0,
          igst: 180.0,
        ),
        business: business(businessName: 'Acme Pvt Ltd', gstin: '27AAAAA0000A1Z5'),
      ),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), startsWith('%PDF'));
  });

  test('invoice with many items does not throw', () async {
    final bytes = await generate(
      input(
        invoice: invoice(taxableAmount: 5000.0, cgst: 450.0, sgst: 450.0),
        business: business(businessName: 'Acme Pvt Ltd'),
        items: <InvoiceLineItem>[
          const InvoiceLineItem(
            description: 'Consulting services',
            quantity: 10,
            rate: 300.0,
            taxableAmount: 3000.0,
          ),
          const InvoiceLineItem(
            description: 'Support retainer',
            quantity: 2,
            rate: 750.0,
            taxableAmount: 1500.0,
          ),
          const InvoiceLineItem(
            description: 'Domain registration',
            quantity: 1,
            rate: 500.0,
            taxableAmount: 500.0,
          ),
        ],
      ),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), startsWith('%PDF'));
  });

  test('empty item list falls back to the invoice and does not throw', () async {
    final bytes = await generate(
      input(
        invoice: invoice(),
        business: business(businessName: 'Acme Pvt Ltd'),
        items: <InvoiceLineItem>[],
      ),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), startsWith('%PDF'));
  });
}

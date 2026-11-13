import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inveio/invoice/domain/services/invoice_pdf_generator.dart';
import 'package:inveio/onboarding/domain/entities/onboarding_entity.dart';
import 'package:inveio/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:inveio/transaction/domain/entities/transaction_entity.dart';

const _pdfUnset = Object();

/// Signature for an injected font loader (tests can provide a stub that
/// succeeds or fails without touching the asset bundle).
typedef FontLoader = Future<ByteData?> Function(String assetPath);

/// State for [InvoicePdfCubit].
class InvoicePdfState extends Equatable {
  /// Whether a PDF is currently being built.
  final bool isLoading;

  /// Error message if the build failed, otherwise null.
  final String? error;

  /// Generated PDF bytes, present on success.
  final Uint8List? pdfBytes;

  /// Suggested filename for the PDF.
  final String? filename;

  const InvoicePdfState({
    this.isLoading = false,
    this.error,
    this.pdfBytes,
    this.filename,
  });

  /// The initial state before any PDF has been built.
  factory InvoicePdfState.initial() => const InvoicePdfState();

  InvoicePdfState copyWith({
    bool? isLoading,
    String? error,
    Object? pdfBytes = _pdfUnset,
    Object? filename = _pdfUnset,
  }) {
    return InvoicePdfState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pdfBytes: identical(pdfBytes, _pdfUnset)
          ? this.pdfBytes
          : pdfBytes as Uint8List?,
      filename: identical(filename, _pdfUnset)
          ? this.filename
          : filename as String?,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, pdfBytes, filename];
}

/// Cubit that builds invoice PDFs out of the UI layer.
///
/// Responsibilities:
/// - Validate that business details are present before generating.
/// - Build the PDF via [InvoicePdfGenerator].
/// - Emit loading / success / error states so the widget can react.
///
/// Flutter widget and printing calls live in the UI layer so this cubit
/// stays unit-testable.
class InvoicePdfCubit extends Cubit<InvoicePdfState> {
  /// Creates an [InvoicePdfCubit].
  ///
  /// [fontLoader] is injected for tests so they can simulate a font load
  /// failure without touching the asset bundle. When omitted, the bundled
  /// Inter fonts are loaded via `rootBundle`.
  InvoicePdfCubit({
    required OnboardingRepository onboardingRepository,
    required InvoicePdfGenerator generator,
    required String uid,
    FontLoader? fontLoader,
  })  : _onboardingRepository = onboardingRepository,
        _generator = generator,
        _uid = uid,
        _fontLoader = fontLoader ?? _defaultFontLoader,
        super(InvoicePdfState.initial());

  final OnboardingRepository _onboardingRepository;
  final InvoicePdfGenerator _generator;
  final String _uid;
  final FontLoader _fontLoader;

  static Future<ByteData?> _defaultFontLoader(String assetPath) async {
    return rootBundle.load(assetPath);
  }

  /// Builds the PDF for [invoice] using the bundled Inter fonts (which contain
  /// the ₹ glyph).
  ///
  /// Returns the PDF bytes on success, or `null` if business details are
  /// missing, a font fails to load, or generation failed. The emitted
  /// [InvoicePdfState] carries the result so the UI can show loading/error/
  /// filename.
  Future<Uint8List?> build(TransactionEntity invoice) async {
    final businessResult = await _onboardingRepository.getOnboarding(_uid);
    var business = const OnboardingEntity.empty();
    businessResult.fold(
      (failure) => business = const OnboardingEntity.empty(),
      (entity) => business = entity,
    );
    if ((business.businessName ?? '').isEmpty) {
      emit(
        const InvoicePdfState(
          error:
              'Please complete your Business Details in Profile before generating a PDF.',
        ),
      );
      return null;
    }

    emit(const InvoicePdfState(isLoading: true));
    try {
      final regularFont = await _fontLoader(
        'assets/fonts/Inter/Inter_28pt-Regular.ttf',
      );
      final boldFont = await _fontLoader(
        'assets/fonts/Inter/Inter_28pt-Bold.ttf',
      );
      if (regularFont == null || boldFont == null) {
        emit(
          const InvoicePdfState(
            isLoading: false,
            error: 'Failed to load the bundled Inter font required for the ₹ symbol.',
          ),
        );
        return null;
      }
      final bytes = await _generator.generate(
        InvoicePdfInput(
          invoice: invoice,
          business: business,
        ),
        regularFont: regularFont,
        boldFont: boldFont,
      );
      emit(
        InvoicePdfState(
          isLoading: false,
          pdfBytes: bytes,
          filename: _filename(invoice),
        ),
      );
      return bytes;
    } catch (_) {
      emit(const InvoicePdfState(isLoading: false, error: 'Failed to generate PDF.'));
      return null;
    }
  }

  String _filename(TransactionEntity invoice) {
    final number = invoice.invoiceNumber;
    return (number != null && number.isNotEmpty) ? '$number.pdf' : 'invoice.pdf';
  }
}

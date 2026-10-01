import 'package:inveio/onboarding/domain/usecases/create_onboarding_status_use_case.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/receipt_text_recognition_data_source.dart';
import 'package:inveio/scan/data/datasources/local/ml_kit/receipt_text_recognition_data_source_impl.dart';
import 'package:inveio/scan/data/datasources/local/receipt_scanner/receipt_scanner_data_source.dart';
import 'package:inveio/scan/data/datasources/local/receipt_scanner/receipt_scanner_data_source_impl.dart';
import 'package:inveio/scan/data/repositories/scan_receipt_repository_impl.dart';
import 'package:inveio/scan/domain/repositories/scan_receipt_repository.dart';
import 'package:inveio/scan/presentation/cubit/receipt_scanner_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:isar_community/isar.dart';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:inveio/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:inveio/auth/data/datasources/remote/firebase_auth_remote_data_source_impl.dart';
import 'package:inveio/auth/data/repositories/auth_repository_impl.dart';
import 'package:inveio/auth/domain/repositories/auth_repository.dart';
import 'package:inveio/auth/domain/usecases/sign_up_with_email_use_case.dart';
import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/transaction/data/models/transaction_model.dart';
import 'package:inveio/transaction/data/datasources/local/transaction_data_source.dart';
import 'package:inveio/transaction/data/datasources/local/isar_transaction_data_source_impl.dart';
import 'package:inveio/transaction/data/repositories/transaction_repository_impl.dart';
import 'package:inveio/transaction/domain/repositories/transaction_repository.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:inveio/expenses/presentation/cubit/expense_form_cubit.dart';
import 'package:inveio/invoice/presentation/cubit/invoice_form_cubit.dart';
import 'package:inveio/profile/data/models/user_model.dart';
import 'package:inveio/shared/secrets/app_secrets.dart';
import 'package:inveio/firebase_options.dart';
import 'package:inveio/onboarding/data/datasources/local/onboarding_local_data_source.dart';
import 'package:inveio/onboarding/data/datasources/remote/onboarding_remote_data_source.dart';
import 'package:inveio/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:inveio/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:inveio/onboarding/domain/usecases/save_onboarding_use_case.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/profile/data/datasources/remote/firebase_user_remote_data_source_impl.dart';
import 'package:inveio/profile/data/datasources/remote/user_remote_data_source.dart';
import 'package:inveio/profile/data/datasources/local/user_local_data_source.dart';
import 'package:inveio/profile/data/datasources/local/user_local_data_source_impl.dart';
import 'package:inveio/profile/data/repositories/user_repository_impl.dart';
import 'package:inveio/profile/domain/repositories/user_repository.dart';
import 'package:inveio/profile/presentation/bloc/user_bloc.dart';

/// Central service locator using GetIt to register and resolve dependencies.
class AppDependencies {
  /// The [GetIt] service locator instance.
  static final GetIt sl = GetIt.instance;

  /// Initializes core dependencies (SharedPreferences, Isar, Firebase).
  static Future<void> init() async {
    sl.registerSingleton(await SharedPreferences.getInstance());
    await Isar.initializeIsarCore(download: true);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await GoogleSignIn.instance.initialize(
      serverClientId: AppSecrets.serverClientId,
    );
  }

  /// Initializes the Isar database and registers it as a singleton.
  static Future<void> initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open([
      UserModelSchema,
      TransactionModelSchema,
    ], directory: dir.path);

    sl.registerSingleton<Isar>(isar);
  }

  /// Registers authentication-related dependencies (data sources, repository, use case, bloc).
  static Future<void> initAuth() async {
    if (!sl.isRegistered<AuthRemoteDataSource>()) {
      sl.registerLazySingleton<AuthRemoteDataSource>(
        () => FirebaseAuthRemoteDataSourceImpl(
          firebaseAuth: FirebaseAuth.instance,
          googleSignIn: GoogleSignIn.instance,
        ),
      );
    }

    if (!sl.isRegistered<AuthRepository>()) {
      sl.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          authRemoteDataSource: sl(),
          userLocalDataSource: sl(),
          userRemoteDataSource: sl(),
        ),
      );
    }
    if (!sl.isRegistered<SignUpWithEmailUseCase>()) {
      sl.registerLazySingleton<SignUpWithEmailUseCase>(
        () => SignUpWithEmailUseCase(userRepository: sl()),
      );
    }
    if (!sl.isRegistered<AuthBloc>()) {
      sl.registerLazySingleton<AuthBloc>(
        () => AuthBloc(authRepository: sl(), signUpWithEmailUseCase: sl()),
      );
    }
  }

  /// Registers user-related dependencies (data sources, repository, bloc).
  static Future<void> initUser() async {
    if (!sl.isRegistered<UserRemoteDataSource>()) {
      sl.registerLazySingleton<UserRemoteDataSource>(
        () => UserRemoteDataSourceImpl(
          firestore: FirebaseFirestore.instance,
          firebaseAuth: FirebaseAuth.instance,
        ),
      );
    }
    if (!sl.isRegistered<UserLocalDataSource>()) {
      sl.registerLazySingleton<UserLocalDataSource>(
        () => UserLocalDataSourceImpl(isar: sl()),
      );
    }
    if (!sl.isRegistered<UserRepository>()) {
      sl.registerLazySingleton<UserRepository>(
        () => UserRepositoryImpl(
          userRemoteDataSource: sl(),
          userLocalDataSource: sl(),
        ),
      );
    }
    if (!sl.isRegistered<UserBloc>()) {
      sl.registerFactory<UserBloc>(
        () => UserBloc(repository: sl(), authBloc: sl()),
      );
    }
  }

  /// Registers transaction-related dependencies (data source, repository, bloc).
  static Future<void> initTransactions() async {
    if (!sl.isRegistered<TransactionDataSource>()) {
      sl.registerLazySingleton<TransactionDataSource>(
        () => IsarTransactionDataSourceImpl(isar: sl()),
      );
    }
    if (!sl.isRegistered<TransactionRepository>()) {
      sl.registerLazySingleton<TransactionRepository>(
        () => TransactionRepositoryImpl(localDataSource: sl()),
      );
    }
    if (!sl.isRegistered<TransactionBloc>()) {
      sl.registerFactory<TransactionBloc>(
        () => TransactionBloc(
          transactionRepository: sl(),
          uid: FirebaseAuth.instance.currentUser?.uid ?? '',
        ),
      );
    }
    if (!sl.isRegistered<ExpenseFormCubit>()) {
      sl.registerFactory<ExpenseFormCubit>(
        () => ExpenseFormCubit(
          transactionRepository: sl(),
          onboardingLocalDataSource: sl(),
          uid: FirebaseAuth.instance.currentUser?.uid ?? '',
        ),
      );
    }
    if (!sl.isRegistered<InvoiceFormCubit>()) {
      sl.registerFactory<InvoiceFormCubit>(
        () => InvoiceFormCubit(
          transactionRepository: sl(),
          onboardingLocalDataSource: sl(),
          uid: FirebaseAuth.instance.currentUser?.uid ?? '',
        ),
      );
    }
  }

  /// Registers onboarding-related dependencies (data sources, repository, use case, bloc).
  static Future<void> initOnboarding() async {
    if (!sl.isRegistered<OnboardingLocalDataSource>()) {
      sl.registerLazySingleton<OnboardingLocalDataSource>(
        () => OnboardingLocalDataSource(prefs: sl()),
      );
    }
    if (!sl.isRegistered<OnboardingRemoteDataSource>()) {
      sl.registerLazySingleton<OnboardingRemoteDataSource>(
        () => OnboardingRemoteDataSource(
          firestore: FirebaseFirestore.instance,
          auth: FirebaseAuth.instance,
        ),
      );
    }
    if (!sl.isRegistered<OnboardingRepository>()) {
      sl.registerLazySingleton<OnboardingRepository>(
        () => OnboardingRepositoryImpl(local: sl(), remote: sl()),
      );
    }
    if (!sl.isRegistered<SaveOnboardingUseCase>()) {
      sl.registerLazySingleton<SaveOnboardingUseCase>(
        () => SaveOnboardingUseCase(repository: sl()),
      );
    }
    if (!sl.isRegistered<CheckOnboardingStatusUseCase>()) {
      sl.registerLazySingleton<CheckOnboardingStatusUseCase>(
        () => CheckOnboardingStatusUseCase(repository: sl()),
      );
    }
    if (!sl.isRegistered<OnboardingBloc>()) {
      sl.registerFactory<OnboardingBloc>(
        () => OnboardingBloc(
          saveOnboardingUsecase: sl(),
          checkUsecase: sl(),
          authBloc: sl(),
        ),
      );
    }
  }

  static Future<void> initScanner() async {
    sl.registerLazySingleton<ReceiptScannerDataSource>(
      () => ReceiptScannerDataSourceImpl(
        scannedDocuments: DocumentScanner(
          options: DocumentScannerOptions(
            documentFormats: {DocumentFormat.jpeg},
            mode: ScannerMode.filter,
            pageLimit: 1,
          ),
        ),
      ),
    );
    sl.registerLazySingleton<ReceiptTextRecognitionDataSource>(
      () => ReceiptTextRecognitionDataSourceImpl(
        textRecognizer: TextRecognizer(),
      ),
    );
    sl.registerLazySingleton<ScanReceiptRepository>(
      () => ScanReceiptRepositoryImpl(
        textRecognitionDataSource: sl(),
        receiptScannerDataSource: sl(),
      ),
    );
    sl.registerFactory<ReceiptScannerCubit>(
      () => ReceiptScannerCubit(scanReceiptRepository: sl()),
    );
  }
}

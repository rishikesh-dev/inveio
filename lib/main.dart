import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/scan/presentation/cubit/receipt_scanner_cubit.dart';
import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/shared/dependencies/app_dependencies.dart';
import 'package:inveio/shared/routes/app_router_config.dart';
import 'package:inveio/shared/theme/app_theme.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/profile/presentation/bloc/user_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Entry point of the Inveio application.
///
/// Initializes all required dependencies (auth, onboarding, transactions,
/// database) and boots the root [InveioApp] wrapped in [MultiBlocProvider].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDependencies.init();
  await AppDependencies.initDatabase();
  await AppDependencies.initUser();
  await AppDependencies.initAuth();
  await AppDependencies.initOnboarding();
  await AppDependencies.initTransactions();
  await AppDependencies.initScanner();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppDependencies.sl<AuthBloc>()),
        BlocProvider(create: (context) => AppDependencies.sl<OnboardingBloc>()),
        BlocProvider(
          create: (context) => AppDependencies.sl<TransactionBloc>(),
        ),
        BlocProvider(create: (context) => AppDependencies.sl<UserBloc>()),
        BlocProvider(
          create: (context) => AppDependencies.sl<ReceiptScannerCubit>(),
        ),
      ],
      child: const InveioApp(),
    ),
  );
}

/// Root widget of the Inveio expense manager application.
///
/// Configures [MaterialApp.router] with light/dark themes, routing, and
/// sets the app title.
class InveioApp extends StatefulWidget {
  /// Creates a [InveioApp] instance.
  const InveioApp({super.key});

  @override
  /// Creates the mutable state for [InveioApp].
  State<InveioApp> createState() => _InveioAppState();
}

class _InveioAppState extends State<InveioApp> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(FetchProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: AppRouterConfig.goRouter,
    );
  }
}

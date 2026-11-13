import 'package:inveio/auth/presentation/bloc/auth_bloc.dart';
import 'package:inveio/scan/presentation/cubit/receipt_scanner_cubit.dart';
import 'package:inveio/shared/constants/app_constants.dart';
import 'package:inveio/shared/dependencies/app_dependencies.dart';
import 'package:inveio/shared/routes/app_router_config.dart';
import 'package:inveio/shared/theme/app_theme.dart';
import 'package:inveio/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:inveio/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:inveio/profile/presentation/bloc/user_bloc.dart';
import 'package:inveio/settings/domain/entities/app_settings.dart';
import 'package:inveio/settings/presentation/cubit/export_data_cubit.dart';
import 'package:inveio/settings/presentation/cubit/theme_cubit.dart';
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
  await AppDependencies.initSettings();
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
        BlocProvider(create: (context) => AppDependencies.sl<ThemeCubit>()),
        BlocProvider(create: (context) => AppDependencies.sl<ExportDataCubit>()),
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
    context.read<ThemeCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ThemeCubit, AppSettings, ThemeMode>(
      selector: (settings) => settings.themeMode.material,
      builder: (context, themeMode) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: AppRouterConfig.goRouter,
        );
      },
    );
  }
}

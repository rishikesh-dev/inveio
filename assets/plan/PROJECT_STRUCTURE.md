# Inveio Flutter Project Structure

## Root Structure
```
inveio/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── routes.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_text_styles.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   └── formatters.dart
│   │   └── error/
│   │       └── failures.dart
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── local/
│   │   │   │   └── isar_local_datasource.dart
│   │   │   └── remote/
│   │   │       └── gemini_remote_datasource.dart
│   │   ├── models/
│   │   │   ├── expense_model.dart
│   │   │   ├── invoice_model.dart
│   │   │   └── user_model.dart
│   │   └── repositories/
│   │       ├── expense_repository_impl.dart
│   │       └── invoice_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── expense.dart
│   │   │   ├── invoice.dart
│   │   │   └── user.dart
│   │   ├── repositories/
│   │   │   ├── expense_repository.dart
│   │   │   └── invoice_repository.dart
│   │   └── usecases/
│   │       ├── expense/
│   │       │   ├── get_expenses.dart
│   │       │   ├── add_expense.dart
│   │       │   └── delete_expense.dart
│   │       └── invoice/
│   │           ├── get_invoices.dart
│   │           └── create_invoice.dart
│   ├── presentation/
│   │   ├── blocs/
│   │   │   ├── dashboard/
│   │   │   │   ├── dashboard_bloc.dart
│   │   │   │   ├── dashboard_event.dart
│   │   │   │   └── dashboard_state.dart
│   │   │   ├── expense_list/
│   │   │   │   ├── expense_list_bloc.dart
│   │   │   │   ├── expense_list_event.dart
│   │   │   │   └── expense_list_state.dart
│   │   │   ├── expense_detail/
│   │   │   │   ├── expense_detail_bloc.dart
│   │   │   │   ├── expense_detail_event.dart
│   │   │   │   └── expense_detail_state.dart
│   │   │   ├── invoice_list/
│   │   │   │   ├── invoice_list_bloc.dart
│   │   │   │   ├── invoice_list_event.dart
│   │   │   │   └── invoice_list_state.dart
│   │   │   ├── invoice/
│   │   │   │   ├── invoice_bloc.dart
│   │   │   │   ├── invoice_event.dart
│   │   │   │   └── invoice_state.dart
│   │   │   ├── reports/
│   │   │   │   ├── reports_bloc.dart
│   │   │   │   ├── reports_event.dart
│   │   │   │   └── reports_state.dart
│   │   │   └── scan/
│   │   │       ├── scan_bloc.dart
│   │   │       ├── scan_event.dart
│   │   │       └── scan_state.dart
│   │   ├── pages/
│   │   │   ├── onboarding/
│   │   │   │   ├── onboarding_page.dart
│   │   │   │   └── widgets/
│   │   │   ├── dashboard/
│   │   │   │   ├── dashboard_page.dart
│   │   │   │   └── widgets/
│   │   │   ├── expenses/
│   │   │   │   ├── expense_list_page.dart
│   │   │   │   └── widgets/
│   │   │   ├── invoices/
│   │   │   │   ├── invoice_list_page.dart
│   │   │   │   └── widgets/
│   │   │   ├── reports/
│   │   │   │   ├── reports_page.dart
│   │   │   │   └── widgets/
│   │   │   ├── scan/
│   │   │   │   ├── scan_page.dart
│   │   │   │   └── widgets/
│   │   │   ├── settings/
│   │   │   │   ├── settings_page.dart
│   │   │   │   └── widgets/
│   │   │   └── invoice_creator/
│   │   │       ├── invoice_creator_page.dart
│   │   │       └── widgets/
│   │   └── widgets/
│   │       ├── common/
│   │       │   ├── app_button.dart
│   │       │   ├── empty_state.dart
│   │       │   ├── error_state.dart
│   │       │   └── shimmer_loading.dart
│   │       └── shared/
│   │           ├── bottom_nav.dart
│   │           └── fab_scan.dart
│   └── main.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## Key Files Content (Starter)

### pubspec.yaml (Dependencies)
```yaml
name: inveio
description: Smart invoicing and expense tracking app
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Local Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.2
  
  # Camera & ML
  camera: ^0.10.5+5
  google_mlkit_text_recognition: ^0.11.0
  image_picker: ^1.0.7
  
  # Charts
  fl_chart: ^0.66.2
  
  # PDF & Sharing
  pdf: ^3.10.7
  printing: ^5.12.0
  share_plus: ^7.2.2
  url_launcher: ^6.2.5
  
  # Auth & Payments (future)
  # google_sign_in: ^6.2.1
  # revenuecat_flutter: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.8

flutter:
  uses-material-design: true
```

### lib/core/constants/app_colors.dart
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Dark theme
  static const Color darkBg = Color(0xFF0D1F1A);
  static const Color accent = Color(0xFF00D97E);
  static const Color cta = Color(0xFFAAFF4D);
  
  // Light theme
  static const Color lightBg = Color(0xFFF5F7F5);
  static const Color lightAccent = Color(0xFF00A85A);
  
  // Common
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Colors.grey;
  static const Color red = Color(0xFFFF4D4D);
  static const Color amber = Colors.amber;
}
```

This structure follows Clean Architecture + BLoC as specified. All screens, flows, and UX rules from the spec can be implemented following this skeleton. Ready for incremental feature development.
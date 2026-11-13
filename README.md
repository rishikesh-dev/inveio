# Kharcha (Inveio)

**AI-powered expense management app** built with Flutter — designed for Indian freelancers, consultants, small businesses, and contractors. The app is branded in-app as **Inveio**.

Track expenses, scan receipts, generate GST-compliant invoices, and visualize spending — all with a modern Material 3 dark-first UI.

---

## Features

### Core
- **Smart Dashboard** — Monthly spending overview, greeting, quick actions, and recent transactions
- **Expense Tracking** — Categorize expenses with GST calculation, vendor info, payment mode, and receipt attachment
- **Invoice Generation** — Create invoices with client details, line items, notes, and GST breakdown
- **Receipt Scanning** — Camera-based receipt capture (OCR placeholder)
- **Reports & Analytics** — Custom line charts, category donut charts, cash flow summaries
- **User Profile** — Edit profile, settings (theme, currency, data export)

### GST Compliance (India)
- Automatic CGST/SGST/IGST calculation based on GSTIN state code
- Interstate vs. intrastate detection (first 2 digits of GSTIN)
- Configurable GST slabs (5%, 12%, 18%, 28%)
- ITC (Input Tax Credit) eligibility toggle per transaction

### Authentication
- Email/password sign-up and sign-in
- Google Sign-In
- Password reset
- Account deletion

### Onboarding Flow
4-step setup for new users:
1. Business Name
2. GSTIN (auto-detects state from first 2 characters)
3. Work Type (Freelancer / Business / Consultant / Contractor)
4. Success confirmation

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Dart 3.11+ |
| Framework | Flutter (Material 3) |
| Architecture | Clean Architecture (feature-first) |
| State Management | flutter_bloc 9.x + equatable |
| Routing | go_router 17.x |
| Backend | Firebase Auth + Cloud Firestore |
| Local Database | Isar 3.x (NoSQL document DB) |
| DI | get_it 9.x (service locator) |
| Functional Programming | fpdart 1.x (Either for error handling) |
| Charts | Syncfusion Flutter Charts 33.x + Custom Canvas/CustomPainter |
| Icons | Lucide Icons |
| Fonts | Inter (primary) + IBM Plex Mono (monospace) |
| Code Generation | build_runner + isar_generator |
| Caching | cached_network_image |
| Local Storage | shared_preferences |

### Platform Support
Android, iOS, Web, macOS, Windows, Linux

---

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── main_screen.dart                   # Bottom nav shell + FAB
├── firebase_options.dart              # Auto-generated Firebase config
│
├── auth/                              # Authentication feature
│   ├── data/
│   │   ├── data_sources/remote_data_sources/
│   │   │   ├── auth_remote_data_source.dart
│   │   │   └── firebase_auth_remote_data_source_impl.dart
│   │   ├── failure_helper/
│   │   │   └── auth_failure_helper.dart
│   │   └── repositories/
│   │       └── auth_repository_impl.dart
│   ├── domain/
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   └── use_cases/
│   │       ├── params/user_details_params.dart
│   │       └── sign_up_with_email_use_case.dart
│   └── presentation/
│       ├── bloc/                      # AuthBloc, AuthEvent, AuthState
│       ├── screens/                   # SignInScreen, SignUpScreen, ForgotPasswordScreen
│       └── widgets/                   # AuthButton, AuthWidgets
│
├── onboarding/                        # Onboarding feature
│   ├── data/
│   │   ├── datasources/               # Local (SharedPrefs) + Remote (Firestore)
│   │   ├── models/
│   │   │   └── onboarding_model.dart
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   │   └── onboarding_entity.dart
│   │   ├── repositories/
│   │   └── usecases/
│   │       └── save_onboarding_usecase.dart
│   └── presentation/
│       ├── bloc/                      # OnboardingBloc, events, states
│       ├── screens/                   # BusinessNameScreen, GstinScreen, WorkTypeScreen, OnboardingSuccessScreen
│       └── widgets/                   # ProgressBar, TextField, CtaButton, RowOption
│
├── splash/                            # Animated splash screen
│   └── presentation/
│       ├── screens/
│       │   └── splash_screen.dart
│       └── widgets/                   # BackgroundCircles, FloatingCoins, ReceiptCards, SparkleDots, etc.
│
├── home/                              # Dashboard
│   └── presentation/
│       ├── screens/
│       │   └── home_screen.dart
│       └── widgets/                   # MonthlySpendingWidget, QuickActionsWidget, TransactionListWidget, etc.
│
├── expenses/                          # Expense listing & details
│   └── presentation/
│       ├── screens/
│       │   └── expenses_screen.dart
│       └── widgets/                   # GstBreakdownCard, TransactionDetailWidgets
│
├── transaction/                       # Core transaction logic
│   ├── data/
│   │   ├── data_sources/
│   │   │   ├── transaction_data_source.dart
│   │   │   └── local_data_sources/
│   │   │       └── transaction_local_data_source_impl.dart
│   │   └── repositories/
│   │       └── transaction_repository_impl.dart
│   ├── domain/
│   │   └── repositories/
│   │       └── transaction_repository.dart
│   └── presentation/
│       ├── bloc/                      # TransactionBloc
│       ├── screens/                   # AddTransaction, AddExpense, AddInvoice, TransactionDetails
│       └── widgets/                   # GstSplitBar, LineItemForm
│
├── scan/                              # Receipt scanning
│   └── presentation/
│       ├── cubit/
│       └── widgets/
│
├── invoice/                           # Invoice management
│   └── presentation/
│       ├── screens/
│       │   └── invoice_screen.dart
│       └── widgets/
│
├── reports/                           # Reports & analytics
│   └── presentation/
│       ├── screens/
│       │   └── reports_screen.dart
│       └── widgets/                   # Custom LineChartPainter, DonutPainter, ReportCard
│
├── profile/                           # User profile & settings
│   ├── data/
│   │   ├── data_sources/              # Remote (Firestore) + Local (Isar)
│   │   └── repository/
│   │       └── user_repository_impl.dart
│   ├── domain/
│   │   └── repositories/
│   │       └── user_repository.dart
│   └── presentation/
│       ├── bloc/                      # UserBloc
│       ├── screens/
│       │   └── profile_screen.dart
│       └── widgets/                   # ProfileHeader, EditProfileSheet, SettingsTile, etc.
│
└── core/                              # Cross-cutting concerns
    ├── constants/
    │   └── app_constants.dart
    ├── dependencies/
    │   └── app_dependencies.dart      # get_it registration (all layers)
    ├── domain/entities/               # QuickAction, MonthlySpendingSummary, ExpenseTransaction, DashboardMetric
    ├── models/                        # TransactionModel, UserModel (Isar-annotated)
    ├── entities/                      # TransactionEntity, UserEntity, OtpSession
    ├── errors/                        # Failure base class, ErrorBanner widget
    ├── notifications/widgets/         # Snackbar, Toast, InfoBottomSheet
    ├── presentation/widgets/          # AppBar, BottomNav, AppCard, NeonButton, AccentChip, TextField, etc.
    ├── routes/                        # AppRouterConfig (go_router), RouterConstants
    ├── theme/                         # AppColors, AppTheme (light/dark), AppTextStyles
    └── utils/                         # CurrencyFormatter, Greeting, AnimatedEntrance
```

### Architecture: Clean Architecture (Feature-First)

Each feature follows a strict 3-layer separation:

```
┌─────────────────────────────────────────┐
│           PRESENTATION LAYER            │
│  ┌──────┐  ┌──────────┐  ┌──────────┐  │
│  │ BLoC │  │ Screens  │  │ Widgets  │  │
│  └──────┘  └──────────┘  └──────────┘  │
├─────────────────────────────────────────┤
│            DOMAIN LAYER                 │
│  ┌──────────┐  ┌────────────┐          │
│  │ Entities │  │ Repos.     │  UseCases│
│  │ (pure)   │  │ (abstract) │          │
│  └──────────┘  └────────────┘          │
├─────────────────────────────────────────┤
│             DATA LAYER                  │
│  ┌────────────┐  ┌────────────┐        │
│  │ DataSources│  │ Repos. Impl│  Models │
│  │(Remote/Loc)│  │            │(Isar)   │
│  └────────────┘  └────────────┘        │
└─────────────────────────────────────────┘
```

- **Presentation**: BLoC pattern (events in, states out), Flutter screens/widgets
- **Domain**: Pure Dart entities, abstract repository interfaces, use cases (single-responsibility)
- **Data**: Data source implementations (Firebase Auth, Firestore, Isar, SharedPreferences), concrete repository implementations, data models with `fromEntity`/`toEntity` mapping

**Data flow**: Screen → BLoC → UseCase → Repository → DataSource → Firebase/Isar

---

## Database Schema

### Isar (Local)

**UserModel**
| Field | Type | Notes |
|---|---|---|
| `isarId` | `Id` | Auto-increment primary key |
| `uid` | `String?` | Firebase UID (unique index) |
| `name` | `String` | |
| `email` | `String` | |
| `phone` | `String?` | |
| `photoUrl` | `String?` | |
| `isPro` | `bool` | |
| `createdAt` | `DateTime?` | |

**TransactionModel**
| Field | Type | Notes |
|---|---|---|
| `isarId` | `Id` | Auto-increment primary key |
| `id` | `String?` | UUID (indexed) |
| `uid` | `String` | Owner Firebase UID (indexed) |
| `type` | `TransactionType` | `expense` or `invoice` |
| `totalAmount` | `double` | |
| `taxableAmount` | `double` | |
| `gstSlab` | `int` | 5, 12, 18, or 28 |
| `isInterState` | `bool` | Interstate vs intrastate |
| `cgst` | `double` | Central GST amount |
| `sgst` | `double` | State GST amount |
| `igst` | `double` | Integrated GST amount |
| `description` | `String` | |
| `date` | `DateTime` | |
| `vendorName` | `String?` | |
| `vendorGstin` | `String?` | |
| `receiptUrl` | `String?` | |
| `category` | `String?` | Supplies, Travel, Software, Rent, Utilities |
| `paymentMode` | `PaymentMode?` | `cash`, `upi`, `card`, `bank` |
| `clientName` | `String?` | For invoices |
| `clientGstin` | `String?` | For invoices |
| `invoiceNumber` | `String?` | |
| `paymentStatus` | `PaymentStatus?` | `paid`, `pending`, `draft` |
| `dueDate` | `DateTime?` | |
| `pdfPath` | `String?` | |
| `isSynced` | `bool` | Sync status with Firestore |
| `firestoreId` | `String?` | |
| `createdAt` | `DateTime` | |
| `updatedAt` | `DateTime` | |

### Firestore (Remote)

- `users/{uid}` — User profile document
- `users/{uid}/onboarding/details` — Onboarding data

### SharedPreferences (Local Key-Value)

- `onboarding_business_name`
- `onboarding_gstin`
- `onboarding_work_type`
- `onboarding_state_code`
- `onboarding_complete`

---

## Route Map

| Route | Path | Screen |
|---|---|---|
| `splash` | `/splash` | SplashScreen |
| `onBoardingName` | `/onboarding/name` | BusinessNameScreen |
| `onBoardingGstin` | `/onboarding/gstin` | GstinScreen |
| `onBoardingType` | `/onboarding/type` | WorkTypeScreen |
| `onBoardingSuccess` | `/onboarding/success` | OnboardingSuccessScreen |
| `mainScreen` | `/` | MainScreen (shell with bottom nav) |
| `home` | `/home` | HomeScreen |
| `signIn` | `/sign-in` | SignInScreen |
| `signUp` | `/sign-up` | SignUpScreen |
| `forgotPassword` | `/forgot-password` | ForgotPasswordScreen |
| `addTransaction` | `/add-transaction` | AddTransactionScreen |
| `transactionDetails` | `/transaction-details` | TransactionDetailsScreen |
| `invoice` | `/invoice` | InvoiceScreen |
| `reports` | `/reports` | ReportsScreen |

**Route Guards** (via `go_router.redirect`):
1. Unauthenticated users accessing protected routes → redirected to `/sign-in`
2. Authenticated users with incomplete onboarding → redirected to `/onboarding/name`
3. Onboarded users visiting onboarding routes → redirected to `/`

---

## State Management: BLoC Pattern

| BLoC | Events | States |
|---|---|---|
| `AuthBloc` | Sign-in, sign-up, Google sign-in, forgot password, sign out, delete account | `AuthInitial`, `AuthLoading`, `AuthSignedIn`, `AuthError` |
| `OnboardingBloc` | Save business name, save GSTIN, save work type | `OnboardingInitial`, `OnboardingLoading`, `OnboardingSuccess`, `OnboardingError` |
| `TransactionBloc` | Add expense, add invoice, fetch transactions | `TransactionInitial`, `TransactionLoading`, `TransactionLoaded`, `TransactionError` |
| `UserBloc` | Fetch profile, update profile, update settings | `UserInitial`, `UserLoading`, `UserLoaded`, `UserError` |

Error handling uses `fpdart`'s `Either<Failure, Success>` in the repository layer, mapped to bloc error states.

---

## Dependency Injection

All dependencies are registered in `AppDependencies` using `get_it` (service locator). Registration order in `lib/main.dart`:

```
init()                     → SharedPreferences, Isar core, Firebase
initUser()                 → UserRemoteDataSource, UserLocalDataSource, UserRepository, UserBloc
initAuth()                 → AuthRemoteDataSource, AuthRepository, SignUpWithEmailUseCase, AuthBloc
initOnboarding()           → OnboardingLocalDatasource, OnboardingRemoteDatasource, OnboardingRepository, SaveOnboardingUsecase, OnboardingBloc
initTransactions()         → TransactionDataSource, TransactionRepository, TransactionBloc
initDatabase()             → Isar instance (with UserModel + TransactionModel schemas)
```

---

## Theme

- **Default mode**: Dark theme (`ThemeMode.dark`)
- **Primary color**: `#AAFF4D` (lime green)
- **Accent**: `#00D97E` (income green)
- **Background**: `#090C09` (near-black green)
- **Cards**: `#151A12`
- **Text**: `#F7F7F0` (primary), `#C9CEB2` (secondary)
- **Light theme**: Also available (greener/lighter surfaces)

Both themes use Material 3 with custom `ColorScheme`, `TextTheme`, and component themes.

---

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.3
- Firebase project with **Authentication** (Email/Password + Google) and **Cloud Firestore** enabled
- Android Studio / Xcode (for platform builds)

### Setup

```sh
# Clone
git clone https://github.com/your-username/kharcha.git
cd kharcha

# Install dependencies
flutter pub get

# Generate Isar models (if models change)
dart run build_runner build

# Run
flutter run
```

### Firebase Configuration

1. Create a Firebase project (or use the existing `project-kharcha` one)
2. Enable **Email/Password** and **Google** sign-in in Firebase Auth
3. Create a **Cloud Firestore** database
4. Place platform config files:
   - `android/app/google-services.json` (already present for `project-kharcha`)
   - `ios/Runner/GoogleService-Info.plist` (generate from Firebase Console)
5. Regenerate `lib/firebase_options.dart` if using a different project:
   ```sh
   flutterfire configure
   ```

### Build Commands

```sh
flutter build apk              # Android APK
flutter build appbundle        # Android App Bundle
flutter build ios              # iOS
flutter build web              # Web
flutter build macos            # macOS
flutter build windows          # Windows
flutter build linux            # Linux
```

---

## Testing

Currently limited to a single widget test:

```sh
flutter test
```

Test file: `test/widget_test.dart` — verifies the splash screen renders correctly with mock dependencies.

---

## Linting & Code Style

Configuration in `analysis_options.yaml`:

```yaml
linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
    prefer_single_quotes: true
    sort_child_properties_last: true
    use_key_in_widget_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_unnecessary_containers: true
```

---

## Design System

The design system is documented in `assets/reference/ui/kharcha_design_system/DESIGN.md` with UI mockups in `assets/reference/ui/`.

### Color Tokens

| Token | Dark | Light |
|---|---|---|
| Background | `#090C09` | `#F0F5F2` |
| Surface | `#111511` | `#FFFFFF` |
| Card | `#151A12` | `#FFFFFF` |
| Border | `#252D1E` | `#CCDDD5` |
| Text Primary | `#F7F7F0` | `#0D1F1A` |
| Text Secondary | `#C9CEB2` | `#1A3C34` |

### Category Colors
- Food: `#FF9F43`
- Transport: `#54A0FF`
- Shopping: `#FF6B9D`
- Utilities: `#FFD45C`
- Software: `#A29BFE`
- Other: `#8395A7`

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Code of Conduct

See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## License

MIT License — see [LICENSE](LICENSE).

---

> **Inveio** — formerly Kharcha. Built with Flutter, Firebase, and ❤️.

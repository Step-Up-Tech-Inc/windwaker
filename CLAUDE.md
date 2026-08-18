# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Tilarán en Línea** — a Flutter marketplace app for local commerce in Tilarán, Guanacaste, Costa Rica. Backend is Supabase (PostgreSQL + Auth), with Firebase for analytics and crash reporting.

## Common Commands

```bash
# Run the app (defaults to testing mode per environment.dart)
flutter run

# Run in a specific mode via dart-define
flutter run --dart-define=APP_MODE=bypass     # Dev, code: 000000
flutter run --dart-define=APP_MODE=testing    # Test, code: 123456
flutter run --dart-define=APP_MODE=production # Real SMS OTP

# Lint / analyze
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart

# Build release
flutter build apk --release
flutter build ios --release

# Code generation (freezed models, json serialization)
dart run build_runner build --delete-conflicting-outputs

# Watch for changes
dart run build_runner watch --delete-conflicting-outputs
```

## App Architecture

### Entry point & initialization order (`lib/main.dart`)
1. Firebase initialized (skipped if `AppMode.bypass` with invalid config)
2. Supabase initialized with `SecureLocalStorage` for auth session persistence
3. `setupDependencies()` registers all singletons via GetIt (schema changes live ONLY in `supabase/migrations/` — never run SQL from the client)
4. `ProviderScope` + `MyApp` (Riverpod at root, GoRouter via `routerProvider`)

### Environment / Mode system
The app has three runtime modes, configured in `lib/core/config/environment.dart`:

| Mode | Auth | SMS code | Crashlytics | Logging |
|------|------|----------|-------------|---------|
| `bypass` | Fake Supabase signup | `000000` | Off | Full |
| `testing` | Real Supabase Auth | `123456` | Off | Full |
| `production` | Real Supabase OTP | Real SMS | On | Minimal |

**To switch modes**, edit line 6 of `lib/core/config/environment.dart`:
```dart
static const AppMode _currentMode = AppMode.testing; // ← change here
```
Always verify mode is `production` before release commits.

### Dependency Injection (`lib/core/config/di_config.dart`)
Uses **GetIt** (`getIt` singleton). All services and repositories are `registerLazySingleton`; `HomeCubit` is `registerFactory`. Access via `getIt<T>()`. DI is set up before `runApp`.

### State Management
- **Riverpod** (`flutter_riverpod`): used for the router (`routerProvider`). Screens use `ConsumerWidget` / `ref.watch`.
- **BLoC/Cubit** (`flutter_bloc`): used for screen-level state. `HomeCubit` is the primary example — injected via `BlocProvider` in the router, retrieved with `getIt`.
- **Freezed**: all BLoC states and models use `@freezed`. After modifying a freezed class, run `build_runner`.

### Routing (`lib/core/router.dart`)
GoRouter with `routerProvider` (Riverpod). Navigation flow enforced via `redirect`:
1. `/splash` → checks intro, auth state, profile completeness
2. `/app-intro` → onboarding (first launch)
3. `/auth` → `AuthSelectionScreen` (choose login or register)
4. **Register**: `/register` (phone) → `/otp-verification` (verify phone) → `/complete-profile` (email + password) → `/location-permission` → `/home`
5. **Login**: `/login` (email OR phone + password) → `/home`

The redirect logic: unauthenticated users go to `/auth`; authenticated users with incomplete profiles go to `/complete-profile`; fully authenticated users on auth routes go to `/home`.

### Authentication (`lib/core/services/auth_service.dart`)
`AuthService` is a singleton. It must be initialized with `UserRepository` before use (done in `di_config.dart`). Registration verifies the phone via OTP, then `completeRegistration()` sets email + password; login uses `signInWithPassword()` with either identifier. Key methods:
- `isAuthenticated()` — synchronous, checks Supabase current user
- `isProfileCompleteAsync()` — async, queries `profiles` table for email + phone
- `isProfileBasicAsync()` — async, queries for phone only (TODO: remove in production)
- `sendRegistrationSms()` / `authenticateWithSmsCode()` — mode-aware, registration flow only
- `completeRegistration()` — sets password (`updateUser`) + email (Admin API, auto-confirmed) + upserts `profiles`
- `signInWithPassword()` — email or E.164 phone + password; phone input is normalized with `PhoneNumber.normalize()` (`lib/core/utils/phone_number.dart`, +506 default)

### Database (`supabase/migrations/`)
Run `01_complete_database_setup.sql` first, then `02_seed_stores_and_products.sql`. Core tables:
- `profiles` — user profiles (`id` matches Supabase Auth UID, stores `email` + `phone`)
- `stores` — business listings
- `products` — products per store
- `inventory` — stock levels

RLS is enabled. Profiles use `auth.uid() = id` for write policies. Stores/products/inventory are publicly readable.

### Repository pattern
- `UserRepository` — wraps Supabase `profiles` table
- `NegociosRepository` — wraps `stores` table
- `ProductRepositoryInterface` / `ProductRepositoryFactory` — selects between local cache (SharedPreferences) and remote (Supabase) based on connectivity/config
- `CartRepository` — uses SharedPreferences for local cart state

### Models
Located in `lib/core/models/`. All use `@freezed` with `fromJson`/`toJson`. After editing, regenerate with `build_runner`. The `.freezed.dart` and `.g.dart` files are generated — do not edit manually.

### Key files to know
- `lib/core/config/environment.dart` — **change mode here**
- `lib/core/config/app_config.dart` — feature flags derived from mode
- `lib/core/config/di_config.dart` — all dependency wiring
- `lib/core/router.dart` — all routes and redirect logic
- `lib/core/services/auth_service.dart` — auth logic for all three modes
- `supabase/migrations/01_complete_database_setup.sql` — full DB schema with RLS

# Guía de Migración: Android → Flutter

## E-Bike Rentals App

> **Referencia completa** para recrear la app desde cero en Flutter, manteniendo la misma arquitectura, lógica de negocio y diseño visual.

---

## Tabla de Contenidos

1. [Resumen del Proyecto Android](#1-resumen-del-proyecto-android)
2. [Equivalencias de Arquitectura](#2-equivalencias-de-arquitectura)
3. [Stack Flutter Elegido](#3-stack-flutter-elegido)
4. [Estructura de Carpetas](#4-estructura-de-carpetas)
5. [pubspec.yaml](#5-pubspecyaml)
6. [Paleta de Colores y Tema](#6-paleta-de-colores-y-tema)
7. [Modelos de Datos](#7-modelos-de-datos)
8. [Supabase — Configuración e Integración](#8-supabase--configuración-e-integración)
9. [Navegación con go_router](#9-navegación-con-go_router)
10. [Módulo: Login](#10-módulo-login)
11. [Módulo: Sign Up](#11-módulo-sign-up)
12. [Módulo: Forgot Password](#12-módulo-forgot-password)
13. [Módulo: Home (Dashboard)](#13-módulo-home-dashboard)
14. [Módulo: Schedule](#14-módulo-schedule)
15. [Módulo: Profile](#15-módulo-profile)
16. [Módulo: Wallet](#16-módulo-wallet)
17. [Módulo: Trips](#17-módulo-trips)
18. [Módulo: Support](#18-módulo-support)
19. [main.dart](#19-maindart)
20. [Checklist de Migración](#20-checklist-de-migración)

---

## 1. Resumen del Proyecto Android

| Campo            | Valor                                       |
| ---------------- | ------------------------------------------- |
| Nombre de la app | E-Bike Rentals                              |
| Package          | `com.example.clase21`                       |
| Arquitectura     | MVVM + Single Activity + Jetpack Navigation |
| Estado           | `StateFlow` con sealed classes              |
| Backend          | Supabase Auth (email/password)              |
| Min SDK          | 26 (Android 8.0)                            |

### Pantallas implementadas

| Pantalla         | Ruta Android                        | Estado          |
| ---------------- | ----------------------------------- | --------------- |
| Login            | `loginFragment` (start destination) | Supabase real   |
| Sign Up          | `signUpFragment`                    | Supabase real   |
| Forgot Password  | `forgotPasswordFragment`            | Mock (simulado) |
| Home / Dashboard | `homeFragment`                      | Mock            |
| Schedule         | `scheduleFragment`                  | Mock            |
| Profile          | `profileFragment`                   | Mock            |
| Wallet           | `walletFragment`                    | Mock            |
| Trips            | `tripsFragment`                     | Mock            |
| Support          | `supportFragment`                   | Mock            |

### Flujo de navegación Android

```
Login ──► Home ──► Schedule
      │         ├──► Profile
      │         ├──► Wallet
      │         ├──► Trips
      │         └──► Support
      ├──► SignUp
      └──► ForgotPassword
```

- `BottomNavigationView` visible sólo en Home y Schedule.
- Login → Home hace `popUpTo(login, inclusive=true)` para borrar el backstack de auth.

---

## 2. Equivalencias de Arquitectura

| Android (Kotlin)                      | Flutter (Dart)                                    |
| ------------------------------------- | ------------------------------------------------- |
| `Fragment`                            | `Screen` (Widget)                                 |
| `ViewModel`                           | `Notifier` (Riverpod)                             |
| `sealed class UiState`                | `sealed class / freezed State`                    |
| `StateFlow`                           | `StateNotifierProvider` / `AsyncNotifierProvider` |
| `NavController`                       | `GoRouter`                                        |
| `NavHostFragment`                     | `MaterialApp.router(routerConfig: router)`        |
| `BottomNavigationView`                | `BottomNavigationBar` / `NavigationBar`           |
| `RecyclerView + Adapter`              | `ListView.builder` / `CustomScrollView`           |
| `ViewBinding`                         | Widget directo (no necesario)                     |
| `repeatOnLifecycle(STARTED)`          | `ref.watch(provider)` en build                    |
| `viewModelScope.launch`               | `ref.read(provider.notifier).method()`            |
| `delay()`                             | `await Future.delayed()`                          |
| `object : Idle/Loading/Success/Error` | `sealed class` con subclases                      |

---

## 3. Stack Flutter Elegido

```
flutter_riverpod    — State management (≈ MVVM + StateFlow)
go_router           — Navegación declarativa (≈ Jetpack Navigation)
supabase_flutter    — Backend Supabase (auth email/password)
freezed             — Inmutabilidad de modelos y estados (opcional pero recomendado)
flutter_svg         — Íconos SVG si se usan
intl                — Formateo de fechas
```

### Razones de elección

- **Riverpod**: el patrón `StateNotifier` espeja exactamente el patrón `ViewModel + StateFlow`. Cada `Notifier` = un `ViewModel`. Cada `State` = un `UiState`.
- **go_router**: navegación declarativa con rutas nombradas, equivalente a `nav_graph.xml`. Soporta guards de autenticación nativamente.
- **supabase_flutter**: misma API que el SDK de Kotlin. `supabase.auth.signInWithPassword()` = `client.auth.signInWith(Email)`.

---

## 4. Estructura de Carpetas

```
lib/
├── main.dart
├── app.dart                          # MaterialApp.router + theme
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart           # go_router config
│   └── supabase/
│       └── supabase_client.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── trip_model.dart
│   │   ├── transaction_model.dart
│   │   ├── ride_schedule_model.dart
│   │   └── faq_model.dart
│   └── repositories/
│       └── auth_repository.dart
└── ui/
    ├── login/
    │   ├── login_screen.dart
    │   ├── login_notifier.dart
    │   └── login_state.dart
    ├── signup/
    │   ├── signup_screen.dart
    │   ├── signup_notifier.dart
    │   └── signup_state.dart
    ├── forgot_password/
    │   ├── forgot_password_screen.dart
    │   ├── forgot_password_notifier.dart
    │   └── forgot_password_state.dart
    ├── home/
    │   ├── home_screen.dart
    │   ├── home_notifier.dart
    │   └── home_state.dart
    ├── schedule/
    │   ├── schedule_screen.dart
    │   ├── schedule_notifier.dart
    │   └── schedule_state.dart
    ├── profile/
    │   ├── profile_screen.dart
    │   ├── profile_notifier.dart
    │   └── profile_state.dart
    ├── wallet/
    │   ├── wallet_screen.dart
    │   ├── wallet_notifier.dart
    │   └── wallet_state.dart
    ├── trips/
    │   ├── trips_screen.dart
    │   ├── trips_notifier.dart
    │   └── trips_state.dart
    └── support/
        ├── support_screen.dart
        ├── support_notifier.dart
        └── support_state.dart
```

---

## 5. pubspec.yaml

```yaml
name: ebike_rentals
description: E-Bike Rentals app
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Navigation
  go_router: ^14.2.0

  # Backend
  supabase_flutter: ^2.5.0

  # Utils
  intl: ^0.19.0
  flutter_dotenv: ^5.1.0 # para leer .env con SUPABASE_URL y SUPABASE_ANON_KEY

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0

flutter:
  uses-material-design: true
  assets:
    - .env
```

### .env (equivalente a local.properties)

```
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
```

---

## 6. Paleta de Colores y Tema

### lib/core/theme/app_colors.dart

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color bgDark   = Color(0xFF1B263B);
  static const Color bgNavy   = Color(0xFF2C3E50);

  // Accents
  static const Color accentTeal = Color(0xFF4CC9F0);
  static const Color accentBlue = Color(0xFF4361EE);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray  = Color(0xFF9CA3AF);

  // UI
  static const Color inputBg   = Color(0xFFFFFFFF);
  static const Color cardBg    = Color(0xFFF8F9FA);
  static const Color darkButton = Color(0xFF0D1B2A);

  // Status
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusPending   = Color(0xFFF59E0B);
}
```

### lib/core/theme/app_theme.dart

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.bgDark,
      onPrimary: AppColors.textWhite,
      secondary: AppColors.accentTeal,
      onSecondary: AppColors.bgDark,
      surface: AppColors.bgDark,
      onSurface: AppColors.textWhite,
    ),
    scaffoldBackgroundColor: AppColors.bgDark,
    fontFamily: 'Roboto',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentTeal,
        foregroundColor: AppColors.bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
```

---

## 7. Modelos de Datos

Equivalentes directos a los `data class` de Kotlin.

### lib/data/models/user_model.dart

```dart
class UserModel {
  final String username;
  const UserModel({required this.username});
}
```

### lib/data/models/trip_model.dart

```dart
class TripModel {
  final String id;
  final String date;
  final String origin;
  final String destination;
  final double cost;
  final String status; // 'COMPLETED' | 'CANCELLED' | 'PENDING'

  const TripModel({
    required this.id,
    required this.date,
    required this.origin,
    required this.destination,
    required this.cost,
    required this.status,
  });
}
```

### lib/data/models/transaction_model.dart

```dart
class TransactionModel {
  final String id;
  final String title;
  final String date;
  final double amount;
  final bool isExpense;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    this.isExpense = true,
  });
}
```

### lib/data/models/ride_schedule_model.dart

```dart
class RideScheduleModel {
  final DateTime date;
  final String timeSlot;
  final String duration;
  final String? pickupLocation;

  const RideScheduleModel({
    required this.date,
    required this.timeSlot,
    required this.duration,
    this.pickupLocation,
  });
}
```

### lib/data/models/faq_model.dart

```dart
class FaqModel {
  final String id;
  final String question;
  final String answer;

  const FaqModel({
    required this.id,
    required this.question,
    required this.answer,
  });
}
```

---

## 8. Supabase — Configuración e Integración

### lib/core/supabase/supabase_client.dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Acceso global al cliente — equivalente al object SupabaseClient de Kotlin
SupabaseClient get supabase => Supabase.instance.client;
```

### Inicialización en main.dart

```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

### lib/data/repositories/auth_repository.dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';

// Equivalente exacto a AuthRepository.kt
class AuthRepository {
  Future<void> login(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await supabase.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Session? get currentSession => supabase.auth.currentSession;
  User? get currentUser => supabase.auth.currentUser;
}
```

---

## 9. Navegación con go_router

Equivalente al `nav_graph.xml`. Incluye guard de autenticación: si no hay sesión activa, redirige al login.

### lib/core/router/app_router.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../ui/login/login_screen.dart';
import '../../ui/signup/signup_screen.dart';
import '../../ui/forgot_password/forgot_password_screen.dart';
import '../../ui/home/home_screen.dart';
import '../../ui/schedule/schedule_screen.dart';
import '../../ui/profile/profile_screen.dart';
import '../../ui/wallet/wallet_screen.dart';
import '../../ui/trips/trips_screen.dart';
import '../../ui/support/support_screen.dart';

// Rutas nombradas — equivalente a los IDs del nav_graph
abstract class AppRoutes {
  static const login          = '/login';
  static const signup         = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home           = '/home';
  static const schedule       = '/schedule';
  static const profile        = '/profile';
  static const wallet         = '/wallet';
  static const trips          = '/trips';
  static const support        = '/support';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuth = session != null;
    final onAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.signup ||
        state.matchedLocation == AppRoutes.forgotPassword;

    // Si no está autenticado y no está en ruta de auth → al login
    if (!isAuth && !onAuthRoute) return AppRoutes.login;
    // Si ya está autenticado y va al login → al home
    if (isAuth && onAuthRoute) return AppRoutes.home;
    return null;
  },
  routes: [
    GoRoute(path: AppRoutes.login,          builder: (_, __) => const LoginScreen()),
    GoRoute(path: AppRoutes.signup,         builder: (_, __) => const SignUpScreen()),
    GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: AppRoutes.home,           builder: (_, __) => const HomeScreen()),
    GoRoute(path: AppRoutes.schedule,       builder: (_, __) => const ScheduleScreen()),
    GoRoute(path: AppRoutes.profile,        builder: (_, __) => const ProfileScreen()),
    GoRoute(path: AppRoutes.wallet,         builder: (_, __) => const WalletScreen()),
    GoRoute(path: AppRoutes.trips,          builder: (_, __) => const TripsScreen()),
    GoRoute(path: AppRoutes.support,        builder: (_, __) => const SupportScreen()),
  ],
);
```

---

## 10. Módulo: Login

### lib/ui/login/login_state.dart

```dart
// Equivalente a LoginUiState.kt + LoginField enum
sealed class LoginState {
  const LoginState();
}

class LoginIdle    extends LoginState { const LoginIdle(); }
class LoginLoading extends LoginState { const LoginLoading(); }

class LoginError extends LoginState {
  final String? message;
  final LoginField? fieldError;
  const LoginError({this.message, this.fieldError});
}

class LoginSuccess extends LoginState {
  final String email;
  const LoginSuccess(this.email);
}

enum LoginField { email, password }
```

### lib/ui/login/login_notifier.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_state.dart';

// Equivalente a LoginViewModel.kt
class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _auth;
  LoginNotifier(this._auth) : super(const LoginIdle());

  Future<void> onLoginPressed(String email, String password) async {
    final e = email.trim();
    final p = password.trim();

    if (e.isEmpty) {
      state = const LoginError(fieldError: LoginField.email);
      return;
    }
    if (p.isEmpty) {
      state = const LoginError(fieldError: LoginField.password);
      return;
    }

    state = const LoginLoading();
    try {
      await _auth.login(e, p);
      state = LoginSuccess(e);
    } catch (ex) {
      state = LoginError(message: ex.toString());
    }
  }

  void reset() => state = const LoginIdle();
}

final loginProvider = StateNotifierProvider.autoDispose<LoginNotifier, LoginState>(
  (ref) => LoginNotifier(AuthRepository()),
);
```

### lib/ui/login/login_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'login_notifier.dart';
import 'login_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // Equivalente al collect { state -> when(state) } del Fragment
    ref.listen<LoginState>(loginProvider, (_, next) {
      if (next is LoginSuccess) {
        context.go(AppRoutes.home);
        ref.read(loginProvider.notifier).reset();
      }
    });

    final emailError    = loginState is LoginError && loginState.fieldError == LoginField.email
        ? 'Completá todos los campos antes de continuar.' : null;
    final passwordError = loginState is LoginError && loginState.fieldError == LoginField.password
        ? 'Completá todos los campos antes de continuar.' : null;
    final generalError  = loginState is LoginError && loginState.fieldError == null
        ? loginState.message : null;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'E-BIKE RENTALS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.accentTeal,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'LOGIN',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textWhite, fontSize: 18),
              ),
              const SizedBox(height: 40),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email Address',
                  errorText: emailError,
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  errorText: passwordError,
                ),
              ),
              const SizedBox(height: 8),

              // Error general
              if (generalError != null)
                Text(generalError, style: const TextStyle(color: AppColors.statusCancelled)),

              const SizedBox(height: 24),

              // Botón Login
              ElevatedButton(
                onPressed: loginState is LoginLoading
                    ? null
                    : () => ref.read(loginProvider.notifier).onLoginPressed(
                          _emailCtrl.text, _passwordCtrl.text),
                child: loginState is LoginLoading
                    ? const CircularProgressIndicator(color: AppColors.bgDark)
                    : const Text('LOGIN'),
              ),
              const SizedBox(height: 16),

              // Links
              TextButton(
                onPressed: () => context.push(AppRoutes.forgotPassword),
                child: const Text('Forgot Password?',
                    style: TextStyle(color: AppColors.accentTeal)),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.signup),
                child: const Text("Don't have an account? Sign Up",
                    style: TextStyle(color: AppColors.accentTeal)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 11. Módulo: Sign Up

### lib/ui/signup/signup_state.dart

```dart
sealed class SignUpState { const SignUpState(); }

class SignUpIdle    extends SignUpState { const SignUpIdle(); }
class SignUpLoading extends SignUpState { const SignUpLoading(); }
class SignUpSuccess extends SignUpState {
  final String email;
  const SignUpSuccess(this.email);
}
class SignUpError extends SignUpState {
  final String? message;
  final SignUpField? fieldError;
  const SignUpError({this.message, this.fieldError});
}

enum SignUpField { fullName, email, password, confirmPassword }
```

### lib/ui/signup/signup_notifier.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';
import 'signup_state.dart';

class SignUpNotifier extends StateNotifier<SignUpState> {
  final AuthRepository _auth;
  SignUpNotifier(this._auth) : super(const SignUpIdle());

  Future<void> onSignUpPressed(
      String name, String email, String pass, String confirmPass) async {
    if (name.trim().isEmpty) {
      state = const SignUpError(fieldError: SignUpField.fullName); return;
    }
    if (email.trim().isEmpty) {
      state = const SignUpError(fieldError: SignUpField.email); return;
    }
    if (pass.trim().isEmpty) {
      state = const SignUpError(fieldError: SignUpField.password); return;
    }
    if (confirmPass.trim().isEmpty) {
      state = const SignUpError(fieldError: SignUpField.confirmPassword); return;
    }
    if (pass != confirmPass) {
      state = const SignUpError(message: 'Passwords do not match.'); return;
    }

    state = const SignUpLoading();
    try {
      await _auth.signUp(email.trim(), pass.trim());
      state = SignUpSuccess(email.trim());
    } catch (e) {
      state = SignUpError(message: e.toString());
    }
  }
}

final signUpProvider = StateNotifierProvider.autoDispose<SignUpNotifier, SignUpState>(
  (ref) => SignUpNotifier(AuthRepository()),
);
```

### lib/ui/signup/signup_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'signup_notifier.dart';
import 'signup_state.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signUpProvider);

    ref.listen<SignUpState>(signUpProvider, (_, next) {
      if (next is SignUpSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')));
        context.pop();
      }
    });

    String? fieldErr(SignUpField f) =>
        state is SignUpError && (state as SignUpError).fieldError == f
            ? 'Completá todos los campos antes de continuar.' : null;

    final generalErr = state is SignUpError && (state as SignUpError).fieldError == null
        ? (state as SignUpError).message : null;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Account',
                  style: TextStyle(color: AppColors.textWhite, fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),

              TextField(controller: _nameCtrl,
                  decoration: InputDecoration(
                      hintText: 'Full Name', errorText: fieldErr(SignUpField.fullName))),
              const SizedBox(height: 16),

              TextField(controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      hintText: 'Email', errorText: fieldErr(SignUpField.email))),
              const SizedBox(height: 16),

              TextField(controller: _passCtrl, obscureText: true,
                  decoration: InputDecoration(
                      hintText: 'Password', errorText: fieldErr(SignUpField.password))),
              const SizedBox(height: 16),

              TextField(controller: _confirmCtrl, obscureText: true,
                  decoration: InputDecoration(hintText: 'Confirm Password',
                      errorText: fieldErr(SignUpField.confirmPassword))),
              const SizedBox(height: 8),

              if (generalErr != null)
                Text(generalErr, style: const TextStyle(color: AppColors.statusCancelled)),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: state is SignUpLoading ? null : () =>
                    ref.read(signUpProvider.notifier).onSignUpPressed(
                        _nameCtrl.text, _emailCtrl.text,
                        _passCtrl.text, _confirmCtrl.text),
                child: state is SignUpLoading
                    ? const CircularProgressIndicator(color: AppColors.bgDark)
                    : const Text('SIGN UP'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Already have an account? Login',
                    style: TextStyle(color: AppColors.accentTeal)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 12. Módulo: Forgot Password

### lib/ui/forgot_password/forgot_password_state.dart

```dart
sealed class ForgotPasswordState { const ForgotPasswordState(); }
class ForgotPasswordIdle    extends ForgotPasswordState { const ForgotPasswordIdle(); }
class ForgotPasswordError   extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);
}
class ForgotPasswordSuccess extends ForgotPasswordState { const ForgotPasswordSuccess(); }
```

### lib/ui/forgot_password/forgot_password_notifier.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'forgot_password_state.dart';

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  ForgotPasswordNotifier() : super(const ForgotPasswordIdle());

  // Actualmente es mock — sin llamada a Supabase
  void onSendPressed(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (email.isNotEmpty && emailRegex.hasMatch(email)) {
      state = const ForgotPasswordSuccess();
    } else {
      state = const ForgotPasswordError('Please enter a valid email address.');
    }
  }

  void reset() => state = const ForgotPasswordIdle();
}

final forgotPasswordProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  (ref) => ForgotPasswordNotifier(),
);
```

### lib/ui/forgot_password/forgot_password_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'forgot_password_notifier.dart';
import 'forgot_password_state.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);

    // Auto-pop después de success (equivale al delay(2000) + popBackStack)
    ref.listen<ForgotPasswordState>(forgotPasswordProvider, (_, next) async {
      if (next is ForgotPasswordSuccess) {
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) context.pop();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Forgot Password',
                style: TextStyle(color: AppColors.textWhite, fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Enter your email address below to receive a password reset link.',
              style: TextStyle(color: AppColors.textGray),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email Address'),
            ),
            const SizedBox(height: 16),

            if (state is ForgotPasswordError)
              Text(state.message,
                  style: const TextStyle(color: AppColors.statusCancelled)),
            if (state is ForgotPasswordSuccess)
              const Text('Reset link sent to your email.',
                  style: TextStyle(color: AppColors.accentTeal)),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(forgotPasswordProvider.notifier)
                  .onSendPressed(_emailCtrl.text.trim()),
              child: const Text('Send Reset Link'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Back to Login',
                  style: TextStyle(color: AppColors.accentTeal)),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 13. Módulo: Home (Dashboard)

> **Nota importante**: en el Android original el Home tiene un BottomNavigationView propio hardcodeado en el layout. En Flutter se recomienda usar el `BottomNavigationBar` del Scaffold directamente. El Home aquí se implementa como pantalla con `BottomNavigationBar` visible sólo en Home y Schedule (igual que Android).

### lib/ui/home/home_state.dart

```dart
sealed class HomeState { const HomeState(); }
class HomeIdle              extends HomeState { const HomeIdle(); }
class HomeNavigateSchedule  extends HomeState { const HomeNavigateSchedule(); }
class HomeNavigateProfile   extends HomeState { const HomeNavigateProfile(); }
class HomeNavigateWallet    extends HomeState { const HomeNavigateWallet(); }
class HomeNavigateTrips     extends HomeState { const HomeNavigateTrips(); }
class HomeNavigateSupport   extends HomeState { const HomeNavigateSupport(); }
class HomeLogout            extends HomeState { const HomeLogout(); }
```

### lib/ui/home/home_notifier.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_state.dart';

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeIdle());

  void onUnlockPressed()   => state = const HomeNavigateSchedule();
  void onSchedulePressed() => state = const HomeNavigateSchedule();
  void onProfilePressed()  => state = const HomeNavigateProfile();
  void onWalletPressed()   => state = const HomeNavigateWallet();
  void onTripsPressed()    => state = const HomeNavigateTrips();
  void onSupportPressed()  => state = const HomeNavigateSupport();
  void onLogoutPressed()   => state = const HomeLogout();
  void reset()             => state = const HomeIdle();
}

final homeProvider = StateNotifierProvider.autoDispose<HomeNotifier, HomeState>(
  (ref) => HomeNotifier(),
);
```

### lib/ui/home/home_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import 'home_notifier.dart';
import 'home_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);

    ref.listen<HomeState>(homeProvider, (_, next) {
      switch (next) {
        case HomeNavigateSchedule(): context.push(AppRoutes.schedule); ref.read(homeProvider.notifier).reset();
        case HomeNavigateProfile():  context.push(AppRoutes.profile);  ref.read(homeProvider.notifier).reset();
        case HomeNavigateWallet():   context.push(AppRoutes.wallet);   ref.read(homeProvider.notifier).reset();
        case HomeNavigateTrips():    context.push(AppRoutes.trips);    ref.read(homeProvider.notifier).reset();
        case HomeNavigateSupport():  context.push(AppRoutes.support);  ref.read(homeProvider.notifier).reset();
        case HomeLogout():           context.go(AppRoutes.login);
        default: break;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgNavy,
        selectedItemColor: AppColors.accentTeal,
        unselectedItemColor: AppColors.textGray,
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) ref.read(homeProvider.notifier).onSchedulePressed();
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('E-BIKE RENTALS',
                          style: TextStyle(color: AppColors.accentTeal,
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('Dashboard',
                          style: TextStyle(color: AppColors.textGray)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.textGray),
                        onPressed: () => ref.read(homeProvider.notifier).onLogoutPressed(),
                      ),
                      const CircleAvatar(
                        backgroundColor: AppColors.accentTeal,
                        child: Icon(Icons.person, color: AppColors.bgDark),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Unlock button
              ElevatedButton.icon(
                icon: const Icon(Icons.lock_open),
                label: const Text('Unlock E-Bike'),
                onPressed: () => ref.read(homeProvider.notifier).onUnlockPressed(),
              ),
              const SizedBox(height: 32),

              // Grid de acciones
              const Text('Find a Ride',
                  style: TextStyle(color: AppColors.textWhite,
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ActionButton(
                    icon: Icons.history,
                    label: 'Previous\nTrips',
                    onTap: () => ref.read(homeProvider.notifier).onTripsPressed(),
                  ),
                  _ActionButton(
                    icon: Icons.account_balance_wallet,
                    label: 'Wallet',
                    onTap: () => ref.read(homeProvider.notifier).onWalletPressed(),
                  ),
                  _ActionButton(
                    icon: Icons.support_agent,
                    label: 'Support',
                    onTap: () => ref.read(homeProvider.notifier).onSupportPressed(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.bgNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.accentTeal, size: 28),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textWhite, fontSize: 11)),
        ],
      ),
    ),
  );
}
```

---

## 14. Módulo: Schedule

### lib/ui/schedule/schedule_state.dart

```dart
// ScheduleUiState.kt → data class equivalente
class ScheduleState {
  final DateTime? selectedDate;
  final int? selectedTimeSlotIndex;
  final int? selectedDurationIndex;

  const ScheduleState({
    this.selectedDate,
    this.selectedTimeSlotIndex,
    this.selectedDurationIndex,
  });

  ScheduleState copyWith({
    DateTime? selectedDate,
    int? selectedTimeSlotIndex,
    int? selectedDurationIndex,
  }) => ScheduleState(
    selectedDate: selectedDate ?? this.selectedDate,
    selectedTimeSlotIndex: selectedTimeSlotIndex ?? this.selectedTimeSlotIndex,
    selectedDurationIndex: selectedDurationIndex ?? this.selectedDurationIndex,
  );
}
```

### lib/ui/schedule/schedule_notifier.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'schedule_state.dart';

class ScheduleNotifier extends StateNotifier<ScheduleState> {
  ScheduleNotifier() : super(const ScheduleState());

  void onDateSelected(DateTime date)    => state = state.copyWith(selectedDate: date);
  void onTimeSlotSelected(int index)    => state = state.copyWith(selectedTimeSlotIndex: index);
  void onDurationSelected(int index)    => state = state.copyWith(selectedDurationIndex: index);
}

final scheduleProvider = StateNotifierProvider.autoDispose<ScheduleNotifier, ScheduleState>(
  (ref) => ScheduleNotifier(),
);
```

### lib/ui/schedule/schedule_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'schedule_notifier.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  static const _timeSlots  = ['9:00 AM','10:00 AM','10:10 AM','11:00 AM','12:30 PM','2:00 PM'];
  static const _durations  = ['30 minutes','2 hours','4 hours','Full Day'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.bgNavy,
        selectedItemColor: AppColors.accentTeal,
        unselectedItemColor: AppColors.textGray,
        currentIndex: 1, // Schedule tab activo
        onTap: (i) { if (i == 0) context.pop(); },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar manual
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
                    onPressed: () => context.pop(),
                  ),
                  const Text('Schedule Your Ride',
                      style: TextStyle(color: AppColors.textWhite,
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar
                    CalendarDatePicker(
                      initialDate: state.selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      onDateChanged: (date) =>
                          ref.read(scheduleProvider.notifier).onDateSelected(date),
                    ),
                    const SizedBox(height: 24),

                    // Time Slots
                    const Text('Time Slots',
                        style: TextStyle(color: AppColors.textWhite,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_timeSlots.length, (i) => ChoiceChip(
                        label: Text(_timeSlots[i]),
                        selected: state.selectedTimeSlotIndex == i,
                        onSelected: (_) =>
                            ref.read(scheduleProvider.notifier).onTimeSlotSelected(i),
                        selectedColor: AppColors.accentTeal,
                        labelStyle: TextStyle(
                          color: state.selectedTimeSlotIndex == i
                              ? AppColors.bgDark : AppColors.textWhite,
                        ),
                      )),
                    ),
                    const SizedBox(height: 24),

                    // Rental Duration
                    const Text('Rental Duration',
                        style: TextStyle(color: AppColors.textWhite,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(_durations.length, (i) => ChoiceChip(
                        label: Text(_durations[i]),
                        selected: state.selectedDurationIndex == i,
                        onSelected: (_) =>
                            ref.read(scheduleProvider.notifier).onDurationSelected(i),
                        selectedColor: AppColors.accentTeal,
                        labelStyle: TextStyle(
                          color: state.selectedDurationIndex == i
                              ? AppColors.bgDark : AppColors.textWhite,
                        ),
                      )),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 15. Módulo: Profile

### lib/ui/profile/profile_state.dart

```dart
class ProfileState {
  final bool isLoading;
  final String userName;
  final String userEmail;
  final String tripsCount;
  final String totalDistance;
  final String userLevel;
  final String co2Saved;
  final String userRating;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.userName = 'Juan Pérez',
    this.userEmail = 'juan.perez@ebike.com',
    this.tripsCount = '42',
    this.totalDistance = '156.4',
    this.userLevel = 'Premium Member',
    this.co2Saved = '12kg',
    this.userRating = '4.9',
    this.error,
  });
}
```

### lib/ui/profile/profile_notifier.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(const ProfileState());
  // Futura lógica de logout / editar perfil
}

final profileProvider = StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(),
);
```

### lib/ui/profile/profile_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'profile_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text('Profile', style: TextStyle(color: AppColors.textWhite)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textGray),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon'))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar + nombre
            const CircleAvatar(radius: 48,
                backgroundColor: AppColors.accentTeal,
                child: Icon(Icons.person, size: 48, color: AppColors.bgDark)),
            const SizedBox(height: 12),
            Text(state.userName,
                style: const TextStyle(color: AppColors.textWhite,
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(state.userLevel,
                style: const TextStyle(color: AppColors.accentTeal)),
            Text(state.userEmail,
                style: const TextStyle(color: AppColors.textGray)),
            const SizedBox(height: 24),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _StatCard(label: 'Total Trips', value: state.tripsCount),
                _StatCard(label: 'Distance (km)', value: state.totalDistance),
                _StatCard(label: 'CO₂ Saved', value: state.co2Saved),
                _StatCard(label: 'Rating', value: state.userRating),
              ],
            ),
            const SizedBox(height: 24),

            // Opciones
            _ProfileOption(icon: Icons.person, label: 'Personal Info',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Personal Info')))),
            _ProfileOption(icon: Icons.payment, label: 'Payment Methods',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment Methods')))),
            _ProfileOption(icon: Icons.notifications, label: 'Notifications',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification Settings')))),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppColors.bgNavy,
        borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.all(12),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(value, style: const TextStyle(color: AppColors.accentTeal,
          fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
    ]),
  );
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ProfileOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.accentTeal),
    title: Text(label, style: const TextStyle(color: AppColors.textWhite)),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textGray),
    onTap: onTap,
  );
}
```

---

## 16. Módulo: Wallet

### lib/ui/wallet/wallet_state.dart

```dart
import '../../data/models/transaction_model.dart';

sealed class WalletState { const WalletState(); }
class WalletIdle    extends WalletState { const WalletIdle(); }
class WalletLoading extends WalletState { const WalletLoading(); }
class WalletSuccess extends WalletState {
  final double balance;
  final List<TransactionModel> transactions;
  const WalletSuccess({required this.balance, required this.transactions});
}
class WalletError extends WalletState {
  final String message;
  const WalletError(this.message);
}
```

### lib/ui/wallet/wallet_notifier.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/transaction_model.dart';
import 'wallet_state.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier() : super(const WalletIdle()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = const WalletLoading();
    await Future.delayed(const Duration(milliseconds: 1500));

    state = const WalletSuccess(
      balance: 85.50,
      transactions: [
        TransactionModel(id:'1', title:'Viaje al Centro',        date:'20 Oct 2023', amount:15.00, isExpense:true),
        TransactionModel(id:'2', title:'Recarga de saldo',       date:'18 Oct 2023', amount:50.00, isExpense:false),
        TransactionModel(id:'3', title:'Viaje a la Universidad', date:'15 Oct 2023', amount:12.50, isExpense:true),
      ],
    );
  }

  void onReloadPressed() => _loadData();
}

final walletProvider = StateNotifierProvider.autoDispose<WalletNotifier, WalletState>(
  (ref) => WalletNotifier(),
);
```

### lib/ui/wallet/wallet_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';
import 'wallet_notifier.dart';
import 'wallet_state.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text('Wallet', style: TextStyle(color: AppColors.textWhite)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accentTeal),
            onPressed: () => ref.read(walletProvider.notifier).onReloadPressed(),
            tooltip: 'Recargar',
          )
        ],
      ),
      body: switch (state) {
        WalletLoading() => const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
        WalletSuccess(:final balance, :final transactions) => Column(
          children: [
            // Balance card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentTeal],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Balance',
                      style: TextStyle(color: AppColors.textWhite)),
                  Text('\$$balance',
                      style: const TextStyle(color: AppColors.textWhite,
                          fontSize: 36, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // Transactions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(alignment: Alignment.centerLeft,
                  child: Text('Transactions',
                      style: TextStyle(color: AppColors.textWhite,
                          fontWeight: FontWeight.bold, fontSize: 16))),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: transactions.length,
                itemBuilder: (_, i) => _TransactionTile(transactions[i]),
              ),
            ),
          ],
        ),
        WalletError(:final message) => Center(child: Text(message,
            style: const TextStyle(color: AppColors.statusCancelled))),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionTile(this.tx);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgNavy,
        borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: tx.isExpense ? AppColors.textGray : AppColors.statusCompleted,
          child: Icon(tx.isExpense ? Icons.remove : Icons.add,
              color: AppColors.textWhite),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx.title, style: const TextStyle(color: AppColors.textWhite,
                fontWeight: FontWeight.w500)),
            Text(tx.date, style: const TextStyle(color: AppColors.textGray,
                fontSize: 12)),
          ]),
        ),
        Text(
          tx.isExpense ? '-\$${tx.amount}' : '+\$${tx.amount}',
          style: TextStyle(
            color: tx.isExpense ? AppColors.textWhite : AppColors.statusCompleted,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// Extensión para acceder a statusCompleted en el widget
extension on AppColors {
  static const Color statusCompleted = Color(0xFF10B981);
}
```

---

## 17. Módulo: Trips

### lib/ui/trips/trips_state.dart

```dart
import '../../data/models/trip_model.dart';

sealed class TripsState { const TripsState(); }
class TripsIdle    extends TripsState { const TripsIdle(); }
class TripsLoading extends TripsState { const TripsLoading(); }
class TripsSuccess extends TripsState {
  final List<TripModel> trips;
  const TripsSuccess(this.trips);
}
class TripsError extends TripsState {
  final String message;
  const TripsError(this.message);
}
```

### lib/ui/trips/trips_notifier.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trip_model.dart';
import 'trips_state.dart';

class TripsNotifier extends StateNotifier<TripsState> {
  TripsNotifier() : super(const TripsIdle()) { _load(); }

  Future<void> _load() async {
    state = const TripsLoading();
    await Future.delayed(const Duration(milliseconds: 1200));
    state = const TripsSuccess([
      TripModel(id:'1', date:'22 Oct 2023', origin:'Av. Principal 123',    destination:'Calle Luna 456',       cost:12.00, status:'COMPLETED'),
      TripModel(id:'2', date:'20 Oct 2023', origin:'Parque Central',       destination:'Centro Comercial',     cost:8.50,  status:'COMPLETED'),
      TripModel(id:'3', date:'18 Oct 2023', origin:'Estación Norte',       destination:'Aeropuerto',           cost:25.00, status:'CANCELLED'),
      TripModel(id:'4', date:'15 Oct 2023', origin:'Plaza Mayor',          destination:'Biblioteca Nacional',  cost:5.00,  status:'COMPLETED'),
    ]);
  }
}

final tripsProvider = StateNotifierProvider.autoDispose<TripsNotifier, TripsState>(
  (ref) => TripsNotifier(),
);
```

### lib/ui/trips/trips_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/trip_model.dart';
import 'trips_notifier.dart';
import 'trips_state.dart';

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tripsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text('Previous Trips',
            style: TextStyle(color: AppColors.textWhite)),
      ),
      body: switch (state) {
        TripsLoading() => const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
        TripsSuccess(:final trips) => ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: trips.length,
          itemBuilder: (_, i) => _TripCard(trips[i]),
        ),
        TripsError(:final message) => Center(child: Text(message,
            style: const TextStyle(color: AppColors.statusCancelled))),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  const _TripCard(this.trip);

  Color get _statusColor => switch (trip.status) {
    'COMPLETED' => AppColors.statusCompleted,
    'CANCELLED' => AppColors.statusCancelled,
    _           => AppColors.statusPending,
  };

  String get _statusLabel => switch (trip.status) {
    'COMPLETED' => 'Completado',
    'CANCELLED' => 'Cancelado',
    _           => 'Pendiente',
  };

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgNavy,
        borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(trip.date, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_statusLabel,
              style: TextStyle(color: _statusColor, fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        const Icon(Icons.radio_button_checked, color: AppColors.accentTeal, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(trip.origin,
            style: const TextStyle(color: AppColors.textWhite))),
      ]),
      Padding(
        padding: const EdgeInsets.only(left: 7),
        child: Container(height: 16, width: 1, color: AppColors.textGray),
      ),
      Row(children: [
        const Icon(Icons.location_on, color: AppColors.accentBlue, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(trip.destination,
            style: const TextStyle(color: AppColors.textWhite))),
      ]),
      const SizedBox(height: 12),
      Align(alignment: Alignment.centerRight,
          child: Text('\$${trip.cost}',
              style: const TextStyle(color: AppColors.textWhite,
                  fontWeight: FontWeight.bold, fontSize: 16))),
    ]),
  );
}
```

---

## 18. Módulo: Support

### lib/ui/support/support_state.dart

```dart
import '../../data/models/faq_model.dart';

sealed class SupportState { const SupportState(); }
class SupportIdle    extends SupportState { const SupportIdle(); }
class SupportLoading extends SupportState { const SupportLoading(); }
class SupportSuccess extends SupportState {
  final List<FaqModel> faqs;
  final String contactEmail;
  final String contactPhone;
  const SupportSuccess({required this.faqs, required this.contactEmail, required this.contactPhone});
}
class SupportError extends SupportState {
  final String message;
  const SupportError(this.message);
}
```

### lib/ui/support/support_notifier.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/faq_model.dart';
import 'support_state.dart';

class SupportNotifier extends StateNotifier<SupportState> {
  SupportNotifier() : super(const SupportIdle()) { _load(); }

  Future<void> _load() async {
    state = const SupportLoading();
    await Future.delayed(const Duration(seconds: 1));
    state = const SupportSuccess(
      faqs: [
        FaqModel(id:'1', question:'¿Cómo recargo mi billetera?',
            answer:'Puedes recargar desde la sección Wallet usando tu tarjeta.'),
        FaqModel(id:'2', question:'¿Qué hago si mi viaje no finaliza?',
            answer:'Asegúrate de estar en una zona de parqueo permitida.'),
        FaqModel(id:'3', question:'¿Cómo reportar un problema mecánico?',
            answer:'Usa el botón de chat para contactar a soporte técnico.'),
      ],
      contactEmail: 'soporte@ebike.com',
      contactPhone: '+51 999 888 777',
    );
  }

  void onCallPressed() {}  // implementar con url_launcher
  void onChatPressed() {}
}

final supportProvider = StateNotifierProvider.autoDispose<SupportNotifier, SupportState>(
  (ref) => SupportNotifier(),
);
```

### lib/ui/support/support_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/faq_model.dart';
import 'support_notifier.dart';
import 'support_state.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(supportProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => context.pop(),
        ),
        title: const Text('Support', style: TextStyle(color: AppColors.textWhite)),
      ),
      body: switch (state) {
        SupportLoading() => const Center(child: CircularProgressIndicator(color: AppColors.accentTeal)),
        SupportSuccess(:final faqs, :final contactEmail, :final contactPhone) =>
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Contact buttons
                Row(children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.phone),
                      label: const Text('Call'),
                      onPressed: () => ref.read(supportProvider.notifier).onCallPressed(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bgNavy),
                      onPressed: () => ref.read(supportProvider.notifier).onChatPressed(),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),
                Text(contactEmail,
                    style: const TextStyle(color: AppColors.textGray),
                    textAlign: TextAlign.center),
                Text(contactPhone,
                    style: const TextStyle(color: AppColors.textGray),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),

                const Text('Preguntas Frecuentes',
                    style: TextStyle(color: AppColors.textWhite,
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...faqs.map((f) => _FaqTile(f)),
              ],
            ),
          ),
        SupportError(:final message) => Center(child: Text(message,
            style: const TextStyle(color: AppColors.statusCancelled))),
        _ => const SizedBox.shrink(),
      },
    );
  }
}

class _FaqTile extends StatelessWidget {
  final FaqModel faq;
  const _FaqTile(this.faq);

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(faq.question,
        style: const TextStyle(color: AppColors.textWhite, fontSize: 14)),
    iconColor: AppColors.accentTeal,
    collapsedIconColor: AppColors.textGray,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Text(faq.answer,
            style: const TextStyle(color: AppColors.textGray)),
      ),
    ],
  );
}
```

---

## 19. main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Equivalente a leer local.properties con BuildConfig
  await dotenv.load(fileName: '.env');

  // Equivalente a SupabaseClient.kt + install(Auth)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    const ProviderScope(  // Equivalente al Hilt/manual DI de Android
      child: EBikeApp(),
    ),
  );
}

class EBikeApp extends StatelessWidget {
  const EBikeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'E-Bike Rentals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,  // Equivalente al NavHostFragment + nav_graph
    );
  }
}
```

---

## 20. Checklist de Migración

### Setup inicial

- [ ] `flutter create ebike_rentals`
- [ ] Copiar `pubspec.yaml` completo
- [ ] `flutter pub get`
- [ ] Crear `.env` con `SUPABASE_URL` y `SUPABASE_ANON_KEY`
- [ ] Crear estructura de carpetas `lib/core/`, `lib/data/`, `lib/ui/`

### Archivos core

- [ ] `app_colors.dart`
- [ ] `app_theme.dart`
- [ ] `supabase_client.dart`
- [ ] `app_router.dart`
- [ ] `main.dart`

### Modelos de datos

- [ ] `user_model.dart`
- [ ] `trip_model.dart`
- [ ] `transaction_model.dart`
- [ ] `ride_schedule_model.dart`
- [ ] `faq_model.dart`

### Repository

- [ ] `auth_repository.dart`

### Módulos (por cada uno: state → notifier → screen)

- [ ] Login
- [ ] Sign Up
- [ ] Forgot Password
- [ ] Home
- [ ] Schedule
- [ ] Profile
- [ ] Wallet
- [ ] Trips
- [ ] Support

### Verificación funcional

- [ ] Login con Supabase real funciona
- [ ] SignUp con Supabase real funciona
- [ ] Navegación Home → todas las pantallas funciona
- [ ] Botón back regresa correctamente
- [ ] BottomNav visible sólo en Home y Schedule
- [ ] Logout limpia el backstack (equivalente a popUpTo inclusive)
- [ ] Loading states muestran indicador
- [ ] Errores de validación se muestran en los campos correctos

### Funcionalidades pendientes (no implementadas en Android tampoco)

- [ ] Forgot Password con Supabase real (`supabase.auth.resetPasswordForEmail()`)
- [ ] Profile con datos reales del usuario autenticado
- [ ] Wallet con datos de Supabase
- [ ] Trips con datos de Supabase
- [ ] Support → `url_launcher` para llamadas y chat
- [ ] Mapa en Home Screen
- [ ] Unlock de e-bike con QR/Bluetooth

---

## Notas de Migración

### Equivalencia de patrones clave

| Patrón Android                                                                                                  | Patrón Flutter                                       |
| --------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `viewLifecycleOwner.lifecycleScope.launch { repeatOnLifecycle(STARTED) { viewModel.uiState.collect { ... } } }` | `ref.listen<State>(provider, (_, next) { ... })`     |
| `_uiState.value = SomeState()`                                                                                  | `state = SomeState()`                                |
| `findNavController().navigate(R.id.action_X)`                                                                   | `context.push(AppRoutes.x)`                          |
| `findNavController().popBackStack()`                                                                            | `context.pop()`                                      |
| `popUpTo(R.id.login, inclusive=true)`                                                                           | `context.go(AppRoutes.home)` (go reemplaza el stack) |
| `RecyclerView + ListAdapter + DiffUtil`                                                                         | `ListView.builder` con keys                          |
| `Chip + ChipGroup`                                                                                              | `ChoiceChip` / `FilterChip`                          |
| `Toast.makeText(...)`                                                                                           | `ScaffoldMessenger.of(context).showSnackBar(...)`    |

### Supabase: diferencias de API

| Kotlin SDK                                                                | Dart SDK                                                      |
| ------------------------------------------------------------------------- | ------------------------------------------------------------- |
| `client.auth.signInWith(Email) { this.email = ...; this.password = ... }` | `supabase.auth.signInWithPassword(email: ..., password: ...)` |
| `client.auth.signUpWith(Email) { ... }`                                   | `supabase.auth.signUp(email: ..., password: ...)`             |
| `client.auth.currentSession`                                              | `supabase.auth.currentSession`                                |

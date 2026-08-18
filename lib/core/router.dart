import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as dev;
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/app_intro_service.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/screens/auth/auth_selection_screen.dart';
import 'package:windwaker/screens/auth/login_screen.dart';
import 'package:windwaker/screens/auth/register_screen.dart';
import 'package:windwaker/screens/auth/complete_profile_screen.dart';
import 'package:windwaker/screens/auth/emergency_logout_screen.dart';
import 'package:windwaker/screens/auth/otp_verification_screen.dart';
import 'package:windwaker/core/routing/role_navigation.dart';
import 'package:windwaker/screens/business/business_home_screen.dart';
import 'package:windwaker/screens/driver/driver_home_screen.dart';
import 'package:windwaker/screens/help/help_support_screen.dart';
import 'package:windwaker/screens/home/home_screen.dart';
import 'package:windwaker/screens/home/cubit/home_cubit.dart';
import 'package:windwaker/screens/splash/location_permission_screen.dart';
import 'package:windwaker/screens/splash/app_intro_screen.dart';
import 'package:windwaker/screens/profile/addresses_screen.dart';
import 'package:windwaker/screens/profile/order_history_screen.dart';
import 'package:windwaker/screens/profile/profile_screen.dart';
import 'package:windwaker/screens/splash/splash_screen.dart';
import 'package:windwaker/screens/search/search_screen.dart';
import 'package:windwaker/screens/order_tracking/order_tracking_screen.dart';
import 'package:windwaker/core/config/app_config.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authService = getIt<AuthService>();
  final appIntroService = getIt<AppIntroService>();

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/app-intro',
        builder: (context, state) => const AppIntroScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (BuildContext context, GoRouterState state) {
          final phone = state.uri.queryParameters['phone'];

          if (phone == null || phone.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Teléfono requerido')),
            );
          }
          return OTPVerificationScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (BuildContext context, GoRouterState state) {
          final phone = state.uri.queryParameters['phone'];
          return CompleteProfileScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/location-permission',
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: '/emergency-logout',
        builder: (context, state) => const EmergencyLogoutScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          return Builder(
            builder: (context) {
              return BlocProvider(
                create: (_) => getIt<HomeCubit>(),
                child: const HomeScreen(),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/business',
        builder: (context, state) => const BusinessHomeScreen(),
      ),
      GoRoute(
        path: '/driver',
        builder: (context, state) => const DriverHomeScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) =>
            SearchScreen(initialQuery: state.uri.queryParameters['q']),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/order-history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/help',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/addresses',
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: '/order-tracking',
        builder: (context, state) {
          final String? orderId = state.uri.queryParameters['order_id'];
          return OrderTrackingScreen(orderId: orderId ?? '');
        },
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      // No redirigir si estamos en la pantalla de splash
      if (state.matchedLocation == '/splash') {
        return null;
      }

      // No redirigir si estamos en la pantalla de introducción
      if (state.matchedLocation == '/app-intro') {
        return null;
      }

      // Verificar si ya se mostró el onboarding
      final bool hasSeenIntro = await appIntroService.hasSeenIntro();
      if (!hasSeenIntro && state.matchedLocation != '/app-intro') {
        return '/app-intro';
      }

      // Si ya vimos la introducción y estamos tratando de ir a /app-intro, redirigir a /auth
      if (hasSeenIntro && state.matchedLocation == '/app-intro') {
        return '/auth';
      }

      // Verificar si el usuario está autenticado
      final isAuthenticated = authService.isAuthenticated();

      if (AppConfig.logAuthFlow) {
        dev.log('🔍 === ROUTER: VERIFICANDO AUTENTICACIÓN ===');
        dev.log('🔍 isAuthenticated: $isAuthenticated');
        dev.log('🔍 Ruta actual: ${state.matchedLocation}');
      }

      // Si no está autenticado y no está en una ruta de autenticación
      // (completar perfil requiere sesión: se llega ahí tras verificar el OTP)
      if (!isAuthenticated) {
        if (state.matchedLocation != '/auth' &&
            state.matchedLocation != '/login' &&
            state.matchedLocation != '/register' &&
            state.matchedLocation != '/otp-verification') {
          return '/auth';
        }
        return null;
      }

      // Si está autenticado, verificar si el perfil está completo (asíncrono)
      final isProfileComplete = await authService.isProfileCompleteAsync();

      // Si está autenticado pero el perfil no está completo
      if (isAuthenticated && !isProfileComplete) {
        if (state.matchedLocation == '/otp-verification' ||
            state.matchedLocation == '/complete-profile') {
          return null;
        }
        return '/complete-profile';
      }

      // Perfil completo: la sección inicial depende del rol
      // (cliente → /home, negocio → /business, repartidor → /driver)
      final role = await authService.getCurrentRole();

      // Si está en una ruta de autenticación, ir al shell de su rol
      if (state.matchedLocation == '/auth' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/otp-verification' ||
          state.matchedLocation == '/complete-profile') {
        return RoleNavigation.homePath(role);
      }

      // Bloquear secciones que no corresponden al rol
      if (!RoleNavigation.canAccess(role, state.matchedLocation)) {
        if (AppConfig.logAuthFlow) {
          dev.log(
            '🚫 ROUTER: rol $role no puede acceder a '
            '${state.matchedLocation}, redirigiendo a su shell',
          );
        }
        return RoleNavigation.homePath(role);
      }

      return null;
    },
  );
});

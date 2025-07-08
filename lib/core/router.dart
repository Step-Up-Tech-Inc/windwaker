import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/services/app_intro_service.dart';
import 'package:windwaker/core/services/auth_service.dart';
import 'package:windwaker/screens/auth/auth_gate_screen.dart';
import 'package:windwaker/screens/auth/complete_profile_screen.dart';
import 'package:windwaker/screens/auth/emergency_logout_screen.dart';
import 'package:windwaker/screens/auth/otp_verification_screen.dart';
import 'package:windwaker/screens/auth/phone_login_screen.dart';
import 'package:windwaker/screens/auth/email_verification_screen.dart';
import 'package:windwaker/screens/home/home_screen.dart';
import 'package:windwaker/screens/home/cubit/home_cubit.dart';
import 'package:windwaker/screens/splash/location_permission_screen.dart';
import 'package:windwaker/screens/splash/app_intro_screen.dart';
import 'package:windwaker/screens/profile/profile_screen.dart';
import 'package:windwaker/screens/splash/splash_screen.dart';
import 'package:windwaker/screens/search/search_screen.dart';
import 'package:windwaker/screens/order_tracking/order_tracking_screen.dart';

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
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final String? phone = state.uri.queryParameters['phone'];
          if (phone == null) {
            return const Scaffold(
              body: Center(child: Text('Teléfono requerido')),
            );
          }
          return OTPVerificationScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) {
          final String? email = state.uri.queryParameters['email'];
          if (email == null) {
            return const Scaffold(body: Center(child: Text('Email requerido')));
          }
          return EmailVerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) {
          final String? phone = state.uri.queryParameters['phone'];
          final String? otp = state.uri.queryParameters['otp'];
          final String? bypass = state.uri.queryParameters['bypass'];
          return CompleteProfileScreen(
            phone: phone,
            otp: otp,
            bypass: bypass == 'true',
          );
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
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
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

      // No redirigir si estamos en la pantalla principal
      if (state.matchedLocation == '/home') {
        return null;
      }

      // No redirigir si estamos en la pantalla de cierre de sesión de emergencia
      if (state.matchedLocation == '/emergency-logout') {
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
      final isProfileComplete = authService.isProfileComplete();

      // Si no está autenticado y no está en una ruta de autenticación
      if (!isAuthenticated) {
        if (state.matchedLocation != '/auth' &&
            state.matchedLocation != '/phone-login' &&
            state.matchedLocation != '/otp-verification' &&
            state.matchedLocation != '/email-verification' &&
            state.matchedLocation != '/complete-profile') {
          return '/auth';
        }
        return null;
      }

      // Si está autenticado pero el perfil no está completo
      if (isAuthenticated && !isProfileComplete) {
        if (state.matchedLocation != '/complete-profile') {
          return '/complete-profile';
        }
        return null;
      }

      // Si está autenticado y el perfil está completo, pero está en una ruta de autenticación
      if (isAuthenticated &&
          isProfileComplete &&
          (state.matchedLocation == '/auth' ||
              state.matchedLocation == '/phone-login' ||
              state.matchedLocation == '/otp-verification' ||
              state.matchedLocation == '/email-verification' ||
              state.matchedLocation == '/complete-profile')) {
        return '/location-permission';
      }

      // Si está en la pantalla de permisos de ubicación, permitir que continúe
      if (state.matchedLocation == '/location-permission') {
        return null;
      }

      return null;
    },
  );
});

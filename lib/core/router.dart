import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/auth_gate_screen.dart';
import '../screens/splash/location_permission_screen.dart';
import '../screens/splash/app_intro_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/auth/phone_login_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/complete_profile_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/store/test_store_screen.dart';
import '../screens/cart/cart_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../screens/home/cubit/home_cubit.dart';
import 'config/di_config.dart';
import '../screens/order_tracking/order_tracking_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: '/location-permission',
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: '/app-intro',
        builder: (context, state) => const AppIntroScreen(),
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
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final String? query = state.uri.queryParameters['query'];
          return SearchScreen(initialQuery: query);
        },
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
        path: '/orders',
        builder:
            (context, state) => const Scaffold(
              body: Center(child: Text('Pantalla de Pedidos')),
            ),
      ),
      GoRoute(
        path: '/profile',
        builder:
            (context, state) =>
                const Scaffold(body: Center(child: Text('Pantalla de Perfil'))),
      ),
      GoRoute(
        path: '/test-store',
        builder: (context, state) => const TestStoreScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) {
          final String? storeId = state.uri.queryParameters['storeId'];
          final String storeName = state.uri.queryParameters['storeName'] ?? '';
          final String storeCategory =
              state.uri.queryParameters['storeCategory'] ?? '';
          final double storeRating =
              double.tryParse(state.uri.queryParameters['storeRating'] ?? '') ??
              4.5;
          final String deliveryTime =
              state.uri.queryParameters['deliveryTime'] ?? '20-30 min';

          return CartScreen(
            storeId: storeId,
            storeName: storeName,
            storeCategory: storeCategory,
            storeRating: storeRating,
            deliveryTime: deliveryTime,
          );
        },
      ),
      GoRoute(
        path: '/order-tracking/:orderId',
        builder: (context, state) {
          final String orderId = state.pathParameters['orderId'] ?? '';
          return OrderTrackingScreen(key: UniqueKey(), orderId: orderId);
        },
      ),
    ],
  );
});

part of 'business_orders_cubit.dart';

@freezed
class BusinessOrdersState with _$BusinessOrdersState {
  const factory BusinessOrdersState.loading() = _Loading;

  /// El usuario negocio aún no ha creado su tienda (onboarding).
  const factory BusinessOrdersState.noStore() = _NoStore;

  const factory BusinessOrdersState.loaded({
    required BusinessStore store,
    required List<Order> orders,
  }) = _Loaded;

  const factory BusinessOrdersState.error(String message) = _Error;
}

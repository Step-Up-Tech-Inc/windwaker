part of 'driver_cubit.dart';

@freezed
class DriverState with _$DriverState {
  const factory DriverState.loading() = _Loading;

  const factory DriverState.loaded({
    required List<Order> available,
    Order? active,
    required List<Order> history,
  }) = _Loaded;

  const factory DriverState.error(String message) = _Error;
}

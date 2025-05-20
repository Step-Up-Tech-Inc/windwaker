part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded({
    required String ciudad,
    required List<Negocio> negocios,
  }) = _Loaded;
  const factory HomeState.error({required String message}) = _Error;
}

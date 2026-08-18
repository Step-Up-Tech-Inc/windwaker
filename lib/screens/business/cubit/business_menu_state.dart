part of 'business_menu_cubit.dart';

@freezed
class BusinessMenuState with _$BusinessMenuState {
  const factory BusinessMenuState.loading() = _Loading;
  const factory BusinessMenuState.loaded(List<BusinessProduct> products) =
      _Loaded;
  const factory BusinessMenuState.error(String message) = _Error;
}

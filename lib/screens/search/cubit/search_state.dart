import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/store.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String searchQuery,
    @Default('') String selectedCategory,
    @Default([]) List<Store> stores,
    @Default([]) List<String> categories,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SearchState;
}

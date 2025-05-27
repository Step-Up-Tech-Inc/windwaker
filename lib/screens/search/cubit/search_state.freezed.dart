// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SearchState {
  String get searchQuery => throw _privateConstructorUsedError;
  String get selectedCategory => throw _privateConstructorUsedError;
  List<Store> get stores => throw _privateConstructorUsedError;
  List<Store> get featuredStores => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
    SearchState value,
    $Res Function(SearchState) then,
  ) = _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call({
    String searchQuery,
    String selectedCategory,
    List<Store> stores,
    List<Store> featuredStores,
    List<String> categories,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = null,
    Object? selectedCategory = null,
    Object? stores = null,
    Object? featuredStores = null,
    Object? categories = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            searchQuery:
                null == searchQuery
                    ? _value.searchQuery
                    : searchQuery // ignore: cast_nullable_to_non_nullable
                        as String,
            selectedCategory:
                null == selectedCategory
                    ? _value.selectedCategory
                    : selectedCategory // ignore: cast_nullable_to_non_nullable
                        as String,
            stores:
                null == stores
                    ? _value.stores
                    : stores // ignore: cast_nullable_to_non_nullable
                        as List<Store>,
            featuredStores:
                null == featuredStores
                    ? _value.featuredStores
                    : featuredStores // ignore: cast_nullable_to_non_nullable
                        as List<Store>,
            categories:
                null == categories
                    ? _value.categories
                    : categories // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            errorMessage:
                freezed == errorMessage
                    ? _value.errorMessage
                    : errorMessage // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
    _$SearchStateImpl value,
    $Res Function(_$SearchStateImpl) then,
  ) = __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String searchQuery,
    String selectedCategory,
    List<Store> stores,
    List<Store> featuredStores,
    List<String> categories,
    bool isLoading,
    String? errorMessage,
  });
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
    _$SearchStateImpl _value,
    $Res Function(_$SearchStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? searchQuery = null,
    Object? selectedCategory = null,
    Object? stores = null,
    Object? featuredStores = null,
    Object? categories = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$SearchStateImpl(
        searchQuery:
            null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                    as String,
        selectedCategory:
            null == selectedCategory
                ? _value.selectedCategory
                : selectedCategory // ignore: cast_nullable_to_non_nullable
                    as String,
        stores:
            null == stores
                ? _value._stores
                : stores // ignore: cast_nullable_to_non_nullable
                    as List<Store>,
        featuredStores:
            null == featuredStores
                ? _value._featuredStores
                : featuredStores // ignore: cast_nullable_to_non_nullable
                    as List<Store>,
        categories:
            null == categories
                ? _value._categories
                : categories // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        errorMessage:
            freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc

class _$SearchStateImpl implements _SearchState {
  const _$SearchStateImpl({
    this.searchQuery = '',
    this.selectedCategory = '',
    final List<Store> stores = const [],
    final List<Store> featuredStores = const [],
    final List<String> categories = const [],
    this.isLoading = false,
    this.errorMessage,
  }) : _stores = stores,
       _featuredStores = featuredStores,
       _categories = categories;

  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final String selectedCategory;
  final List<Store> _stores;
  @override
  @JsonKey()
  List<Store> get stores {
    if (_stores is EqualUnmodifiableListView) return _stores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stores);
  }

  final List<Store> _featuredStores;
  @override
  @JsonKey()
  List<Store> get featuredStores {
    if (_featuredStores is EqualUnmodifiableListView) return _featuredStores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_featuredStores);
  }

  final List<String> _categories;
  @override
  @JsonKey()
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'SearchState(searchQuery: $searchQuery, selectedCategory: $selectedCategory, stores: $stores, featuredStores: $featuredStores, categories: $categories, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            const DeepCollectionEquality().equals(other._stores, _stores) &&
            const DeepCollectionEquality().equals(
              other._featuredStores,
              _featuredStores,
            ) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    searchQuery,
    selectedCategory,
    const DeepCollectionEquality().hash(_stores),
    const DeepCollectionEquality().hash(_featuredStores),
    const DeepCollectionEquality().hash(_categories),
    isLoading,
    errorMessage,
  );

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState implements SearchState {
  const factory _SearchState({
    final String searchQuery,
    final String selectedCategory,
    final List<Store> stores,
    final List<Store> featuredStores,
    final List<String> categories,
    final bool isLoading,
    final String? errorMessage,
  }) = _$SearchStateImpl;

  @override
  String get searchQuery;
  @override
  String get selectedCategory;
  @override
  List<Store> get stores;
  @override
  List<Store> get featuredStores;
  @override
  List<String> get categories;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

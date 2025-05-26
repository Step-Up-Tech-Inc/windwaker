// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store_products_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$StoreProductsState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  List<Product> get products => throw _privateConstructorUsedError;
  List<CartItem> get cartItems => throw _privateConstructorUsedError;
  String get selectedCategory => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  double get cartTotal => throw _privateConstructorUsedError;

  /// Create a copy of StoreProductsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StoreProductsStateCopyWith<StoreProductsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreProductsStateCopyWith<$Res> {
  factory $StoreProductsStateCopyWith(
    StoreProductsState value,
    $Res Function(StoreProductsState) then,
  ) = _$StoreProductsStateCopyWithImpl<$Res, StoreProductsState>;
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    List<Product> products,
    List<CartItem> cartItems,
    String selectedCategory,
    List<String> categories,
    double cartTotal,
  });
}

/// @nodoc
class _$StoreProductsStateCopyWithImpl<$Res, $Val extends StoreProductsState>
    implements $StoreProductsStateCopyWith<$Res> {
  _$StoreProductsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StoreProductsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? products = null,
    Object? cartItems = null,
    Object? selectedCategory = null,
    Object? categories = null,
    Object? cartTotal = null,
  }) {
    return _then(
      _value.copyWith(
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
            products:
                null == products
                    ? _value.products
                    : products // ignore: cast_nullable_to_non_nullable
                        as List<Product>,
            cartItems:
                null == cartItems
                    ? _value.cartItems
                    : cartItems // ignore: cast_nullable_to_non_nullable
                        as List<CartItem>,
            selectedCategory:
                null == selectedCategory
                    ? _value.selectedCategory
                    : selectedCategory // ignore: cast_nullable_to_non_nullable
                        as String,
            categories:
                null == categories
                    ? _value.categories
                    : categories // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            cartTotal:
                null == cartTotal
                    ? _value.cartTotal
                    : cartTotal // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StoreProductsStateImplCopyWith<$Res>
    implements $StoreProductsStateCopyWith<$Res> {
  factory _$$StoreProductsStateImplCopyWith(
    _$StoreProductsStateImpl value,
    $Res Function(_$StoreProductsStateImpl) then,
  ) = __$$StoreProductsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    String? error,
    List<Product> products,
    List<CartItem> cartItems,
    String selectedCategory,
    List<String> categories,
    double cartTotal,
  });
}

/// @nodoc
class __$$StoreProductsStateImplCopyWithImpl<$Res>
    extends _$StoreProductsStateCopyWithImpl<$Res, _$StoreProductsStateImpl>
    implements _$$StoreProductsStateImplCopyWith<$Res> {
  __$$StoreProductsStateImplCopyWithImpl(
    _$StoreProductsStateImpl _value,
    $Res Function(_$StoreProductsStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StoreProductsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? products = null,
    Object? cartItems = null,
    Object? selectedCategory = null,
    Object? categories = null,
    Object? cartTotal = null,
  }) {
    return _then(
      _$StoreProductsStateImpl(
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
        products:
            null == products
                ? _value._products
                : products // ignore: cast_nullable_to_non_nullable
                    as List<Product>,
        cartItems:
            null == cartItems
                ? _value._cartItems
                : cartItems // ignore: cast_nullable_to_non_nullable
                    as List<CartItem>,
        selectedCategory:
            null == selectedCategory
                ? _value.selectedCategory
                : selectedCategory // ignore: cast_nullable_to_non_nullable
                    as String,
        categories:
            null == categories
                ? _value._categories
                : categories // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        cartTotal:
            null == cartTotal
                ? _value.cartTotal
                : cartTotal // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc

class _$StoreProductsStateImpl implements _StoreProductsState {
  const _$StoreProductsStateImpl({
    this.isLoading = false,
    this.error = null,
    final List<Product> products = const [],
    final List<CartItem> cartItems = const [],
    this.selectedCategory = 'Todos',
    final List<String> categories = const ['Todos'],
    this.cartTotal = 0.0,
  }) : _products = products,
       _cartItems = cartItems,
       _categories = categories;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? error;
  final List<Product> _products;
  @override
  @JsonKey()
  List<Product> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  final List<CartItem> _cartItems;
  @override
  @JsonKey()
  List<CartItem> get cartItems {
    if (_cartItems is EqualUnmodifiableListView) return _cartItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cartItems);
  }

  @override
  @JsonKey()
  final String selectedCategory;
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
  final double cartTotal;

  @override
  String toString() {
    return 'StoreProductsState(isLoading: $isLoading, error: $error, products: $products, cartItems: $cartItems, selectedCategory: $selectedCategory, categories: $categories, cartTotal: $cartTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreProductsStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            const DeepCollectionEquality().equals(
              other._cartItems,
              _cartItems,
            ) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            (identical(other.cartTotal, cartTotal) ||
                other.cartTotal == cartTotal));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    error,
    const DeepCollectionEquality().hash(_products),
    const DeepCollectionEquality().hash(_cartItems),
    selectedCategory,
    const DeepCollectionEquality().hash(_categories),
    cartTotal,
  );

  /// Create a copy of StoreProductsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StoreProductsStateImplCopyWith<_$StoreProductsStateImpl> get copyWith =>
      __$$StoreProductsStateImplCopyWithImpl<_$StoreProductsStateImpl>(
        this,
        _$identity,
      );
}

abstract class _StoreProductsState implements StoreProductsState {
  const factory _StoreProductsState({
    final bool isLoading,
    final String? error,
    final List<Product> products,
    final List<CartItem> cartItems,
    final String selectedCategory,
    final List<String> categories,
    final double cartTotal,
  }) = _$StoreProductsStateImpl;

  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  List<Product> get products;
  @override
  List<CartItem> get cartItems;
  @override
  String get selectedCategory;
  @override
  List<String> get categories;
  @override
  double get cartTotal;

  /// Create a copy of StoreProductsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StoreProductsStateImplCopyWith<_$StoreProductsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

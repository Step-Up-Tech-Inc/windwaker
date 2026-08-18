import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address.dart';

/// Repositorio de direcciones de entrega (tabla `addresses`).
/// El RLS garantiza que cada usuario solo ve y escribe las suyas.
class AddressRepository {
  final SupabaseClient _supabase;

  AddressRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  /// Direcciones del usuario autenticado (la default primero).
  Future<List<Address>> getMyAddresses() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return const [];

    final rows = await _supabase
        .from('addresses')
        .select()
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return rows.map(Address.fromJson).toList();
  }

  /// Guarda una dirección nueva. Si [isDefault] es true, quita la marca
  /// de las demás.
  Future<Address> saveAddress({
    required String label,
    required String detail,
    String? district,
    String? reference,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('No hay usuario autenticado');
    }

    if (isDefault) {
      await _supabase
          .from('addresses')
          .update({'is_default': false})
          .eq('user_id', uid);
    }

    final row =
        await _supabase
            .from('addresses')
            .insert({
              'user_id': uid,
              'label': label,
              'detail': detail,
              'district': district,
              'reference': reference,
              'latitude': latitude,
              'longitude': longitude,
              'is_default': isDefault,
            })
            .select()
            .single();
    return Address.fromJson(row);
  }

  Future<void> deleteAddress(String id) async {
    await _supabase.from('addresses').delete().eq('id', id);
  }

  /// Marca [id] como dirección predeterminada (y desmarca las demás).
  Future<void> setDefault(String id) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    await _supabase
        .from('addresses')
        .update({'is_default': false})
        .eq('user_id', uid);
    await _supabase
        .from('addresses')
        .update({'is_default': true})
        .eq('id', id);
  }
}

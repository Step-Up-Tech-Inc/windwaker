import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:windwaker/core/config/di_config.dart';
import 'package:windwaker/core/models/address.dart';
import 'package:windwaker/core/repositories/address_repository.dart';

/// Editor de dirección estilo Uber/DiDi: pin exacto en el mapa + distrito,
/// señas y punto de referencia. Devuelve la [Address] guardada al hacer pop.
class AddressEditorScreen extends StatefulWidget {
  const AddressEditorScreen({super.key});

  @override
  State<AddressEditorScreen> createState() => _AddressEditorScreenState();
}

class _AddressEditorScreenState extends State<AddressEditorScreen> {
  static const LatLng _tilaranCenter = LatLng(10.4626, -84.9718);

  static const List<String> _districts = [
    'Tilarán',
    'Quebrada Grande',
    'Tronadora',
    'Santa Rosa',
    'Líbano',
    'Tierras Morenas',
    'Arenal',
    'Cabeceras',
  ];

  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController(text: 'Casa');
  final _detailController = TextEditingController();
  final _referenceController = TextEditingController();
  final _mapController = MapController();

  String _district = _districts.first;
  LatLng _pin = _tilaranCenter;
  bool _isDefault = false;
  bool _saving = false;
  bool _locating = false;

  @override
  void dispose() {
    _labelController.dispose();
    _detailController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  /// Centra el mapa en la ubicación actual del dispositivo.
  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final here = LatLng(position.latitude, position.longitude);
      _mapController.move(here, 17);
      setState(() => _pin = here);
    } catch (_) {
      // Sin GPS no se bloquea: el usuario puede mover el mapa a mano
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final address = await getIt<AddressRepository>().saveAddress(
        label: _labelController.text.trim().isEmpty
            ? 'Casa'
            : _labelController.text.trim(),
        detail: _detailController.text.trim(),
        district: _district,
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        latitude: _pin.latitude,
        longitude: _pin.longitude,
        isDefault: _isDefault,
      );
      if (mounted) Navigator.of(context).pop(address);
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva dirección'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // ── Mapa con pin central (arrastra el mapa para ajustar) ──
          SizedBox(
            height: 260,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _tilaranCenter,
                    initialZoom: 15,
                    onPositionChanged: (camera, _) {
                      _pin = camera.center;
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.windwaker.tilaran',
                    ),
                  ],
                ),
                // Pin fijo al centro: el punto exacto es el centro del mapa
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 36),
                    child: Icon(
                      Icons.location_pin,
                      size: 44,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'my-location',
                    onPressed: _locating ? null : _useMyLocation,
                    child: _locating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Mueve el mapa hasta que el pin quede sobre tu entrada',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),

          // ── Formulario ──
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _labelController,
                          maxLength: 60,
                          decoration: const InputDecoration(
                            labelText: 'Etiqueta',
                            hintText: 'Casa, Trabajo…',
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _district,
                          decoration: const InputDecoration(
                            labelText: 'Distrito',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            for (final d in _districts)
                              DropdownMenuItem(value: d, child: Text(d)),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _district = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _detailController,
                    maxLines: 2,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Señas',
                      hintText: 'Ej: 200m Este del Banco Nacional, casa verde',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Las señas son obligatorias'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _referenceController,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Punto de referencia (opcional)',
                      hintText: 'Ej: frente al súper, portón negro',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Usar como dirección predeterminada'),
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar dirección'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

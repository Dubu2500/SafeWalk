import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/destination.dart';
import '../providers/account_provider.dart';
import '../services/geocoding_service.dart';

class DestinationEditor extends StatefulWidget {
  const DestinationEditor({super.key});
  @override
  State<DestinationEditor> createState() => _DestinationEditorState();
}

class _DestinationEditorState extends State<DestinationEditor> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _address = TextEditingController();
  bool _saving = false;
  String? _error;
  // Coordenadas del destino (si se eligió en el mapa).
  double? _lat;
  double? _lng;
  @override
  void dispose() {
    _title.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickOnMap() async {
    final picked = await Navigator.pushNamed(context, '/pick-destination');
    if (!mounted || picked is! Destination) return;
    setState(() {
      _address.text = picked.subtitle;
      _lat = picked.latitude;
      _lng = picked.longitude;
    });
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final account = context.read<AccountProvider>();
      // Si escribió la dirección a mano, se buscan sus coordenadas.
      if (_lat == null || _lng == null) {
        try {
          final places = await GeocodingService.search(_address.text);
          if (places.isNotEmpty) {
            _lat = places.first.point.latitude;
            _lng = places.first.point.longitude;
          }
        } catch (_) {
          // Se guarda sin coordenadas; el mapa intentará buscarlas después.
        }
      }
      await account.addDestination(
        _title.text,
        _address.text,
        lat: _lat,
        lng: _lng,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'No se pudo guardar el destino.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: const Text('Guardar destino'),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                enabled: !_saving,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Escribe un nombre.' : null,
              ),
              TextFormField(
                controller: _address,
                enabled: !_saving,
                maxLength: 300,
                decoration: const InputDecoration(labelText: 'Dirección'),
                onChanged: (_) {
                  _lat = null;
                  _lng = null;
                },
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Escribe una dirección.'
                    : null,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _saving ? null : _pickOnMap,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Elegir en el mapa'),
                ),
              ),
              if (_error != null) Text(_error!),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Guardando…' : 'Guardar'),
        ),
      ],
    ),
  );
}

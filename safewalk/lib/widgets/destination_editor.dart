import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_provider.dart';

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
  @override
  void dispose() {
    _title.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<AccountProvider>().addDestination(
        _title.text,
        _address.text,
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
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Escribe una dirección.'
                    : null,
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

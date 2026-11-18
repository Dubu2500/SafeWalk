import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trusted_contact.dart';
import '../providers/account_provider.dart';

class ContactEditor extends StatefulWidget {
  const ContactEditor({super.key, this.contact});
  final TrustedContact? contact;
  @override
  State<ContactEditor> createState() => _ContactEditorState();
}

class _ContactEditorState extends State<ContactEditor> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.contact?.name);
  late final _phone = TextEditingController(text: widget.contact?.phone);
  late final _relationship = TextEditingController(
    text: widget.contact?.relationship,
  );
  bool _saving = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _relationship.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<AccountProvider>().saveContact(
        TrustedContact(
          id: widget.contact?.id ?? '',
          name: _name.text,
          relationship: _relationship.text,
          phone: _phone.text,
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'No se pudo guardar. Revisa tu conexión e intenta de nuevo.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: Text(
        widget.contact == null ? 'Agregar contacto' : 'Editar contacto',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Nombre'),
                maxLength: 100,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Escribe el nombre.' : null,
              ),
              TextFormField(
                controller: _relationship,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Relación'),
                maxLength: 100,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Escribe la relación.'
                    : null,
              ),
              TextFormField(
                controller: _phone,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                maxLength: 25,
                validator: (v) =>
                    !RegExp(r'^[+0-9 ()-]{7,25}$').hasMatch(v?.trim() ?? '')
                    ? 'Escribe un teléfono válido.'
                    : null,
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
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

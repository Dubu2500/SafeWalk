import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/trusted_contact.dart';
import '../providers/account_provider.dart';
import '../widgets/contact_editor.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});
  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  bool _busy = false;
  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo completar la operación. Vuelve a intentar.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _edit([TrustedContact? contact]) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ContactEditor(contact: contact),
  );
  Future<void> _delete(TrustedContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: Text('¿Quieres eliminar a ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final account = context.read<AccountProvider>();
    await _run(() => account.deleteContact(contact.id));
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Contactos de confianza')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : () => _edit(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Agregar'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _run(account.refresh),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const Text(
              'Quienes te cuidan.',
              style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elige un contacto principal con la estrella. Desliza hacia abajo para actualizar.',
            ),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 20),
            if (account.contacts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aún no tienes contactos. Agrega el primero.'),
              ),
            for (final contact in account.contacts)
              Card(
                child: ListTile(
                  title: Text(contact.name),
                  subtitle: Text('${contact.relationship} · ${contact.phone}'),
                  leading: IconButton(
                    tooltip: 'Elegir como principal',
                    icon: Icon(
                      account.primaryContact?.id == contact.id
                          ? Icons.star
                          : Icons.star_border,
                    ),
                    onPressed: _busy
                        ? null
                        : () => _run(() => account.setPrimary(contact.id)),
                  ),
                  trailing: PopupMenuButton<String>(
                    enabled: !_busy,
                    onSelected: (action) {
                      if (action == 'edit') {
                        _edit(contact);
                      } else {
                        _delete(contact);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Editar')),
                      PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

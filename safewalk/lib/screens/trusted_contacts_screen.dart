import 'package:flutter/material.dart';

import '../data/profile_data.dart';
import '../models/trusted_contact.dart';
import '../widgets/contact_tile.dart';
import '../widgets/pending_dialog.dart';

class TrustedContactsScreen extends StatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  State<TrustedContactsScreen> createState() => _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends State<TrustedContactsScreen> {
  final List<TrustedContact> _contacts = [...trustedContacts];
  String _primaryId = trustedContacts.first.id;

  void _showSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void _setPrimary(TrustedContact contact) {
    setState(() => _primaryId = contact.id);
    _showSnackBar(
      SnackBar(
        content: Text('${contact.name} ahora es tu contacto principal.'),
      ),
    );
  }

  void _removeContact(TrustedContact contact, int index) {
    final previousPrimaryId = _primaryId;
    setState(() {
      _contacts.removeAt(index);
      if (_primaryId == contact.id && _contacts.isNotEmpty) {
        _primaryId = _contacts.first.id;
      }
    });
    _showSnackBar(
      SnackBar(
        content: Text('${contact.name} se quitó de tus contactos.'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () => setState(() {
            _contacts.insert(index, contact);
            _primaryId = previousPrimaryId;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contactos de confianza',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPendingDialog(
          context,
          'Aquí podrás agregar un contacto desde tu agenda para que te acompañe en tus trayectos. Funcionalidad pendiente.',
        ),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Agregar'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            children: [
              const Text(
                'Quienes te cuidan.',
                style: TextStyle(fontSize: 29, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca un contacto para hacerlo principal. Recibirá una alerta si algo no va bien en tu trayecto.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              for (final (index, contact) in _contacts.indexed)
                // Swipe left to remove a contact from the list.
                Dismissible(
                  key: ValueKey(contact.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _removeContact(contact, index),
                  background: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      decoration: BoxDecoration(
                        color: colors.error,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: colors.onError,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ContactTile(
                      contact: contact,
                      primary: contact.id == _primaryId,
                      onTap: () => _setPrimary(contact),
                      onCall: () => showPendingDialog(
                        context,
                        'Aquí se llamará a ${contact.name} al ${contact.phone}. Funcionalidad pendiente.',
                      ),
                    ),
                  ),
                ),
              if (_contacts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Text(
                    'Aún no tienes contactos de confianza.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Desliza un contacto hacia la izquierda para quitarlo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

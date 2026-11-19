import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

Future<bool> showPasswordResetDialog(BuildContext context, String email) async {
  final sent = await showDialog<bool>(
    context: context,
    builder: (_) => PasswordResetDialog(initialEmail: email),
  );
  return sent ?? false;
}

class PasswordResetDialog extends StatefulWidget {
  const PasswordResetDialog({super.key, required this.initialEmail});
  final String initialEmail;

  @override
  State<PasswordResetDialog> createState() => _PasswordResetDialogState();
}

class _PasswordResetDialogState extends State<PasswordResetDialog> {
  late final _email = TextEditingController(text: widget.initialEmail.trim());
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      setState(() => _error = 'Escribe un correo válido.');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await context.read<UserProvider>().sendPasswordReset(email);
      if (mounted) Navigator.pop(context, true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = switch (error.code) {
          'invalid-email' => 'El correo no es válido.',
          'user-not-found' => 'No hay una cuenta con ese correo.',
          'too-many-requests' => 'Demasiados intentos. Espera un momento.',
          _ => 'No se pudo enviar el correo. Intenta de nuevo.',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = 'No se pudo enviar el correo. Revisa tu conexión.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.lock_reset_rounded),
    title: const Text('Recuperar contraseña'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Te enviaremos un enlace para crear una contraseña nueva.'),
        const SizedBox(height: 16),
        TextField(
          controller: _email,
          enabled: !_sending,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            errorText: _error,
          ),
          onSubmitted: (_) => _send(),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: _sending ? null : () => Navigator.pop(context, false),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: _sending ? null : _send,
        child: _sending
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Enviar'),
      ),
    ],
  );
}

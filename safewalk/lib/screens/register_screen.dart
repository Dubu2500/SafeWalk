import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/auth_field.dart';
import '../widgets/auth_layout.dart';
import '../widgets/form_error_text.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _accepted = false;
  bool _loading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _termsError;
  String? _formError;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _email.text.trim();
    final password = _password.text;
    setState(() {
      _nameError = _name.text.trim().isEmpty ? 'Escribe tu nombre.' : null;
      _emailError = email.isEmpty ? 'Escribe tu correo electrónico.' : null;
      _passwordError = password.isEmpty
          ? 'Crea una contraseña.'
          : password.length < 6
          ? 'Debe tener al menos 6 caracteres.'
          : null;
      _confirmError = _confirm.text.isEmpty
          ? 'Repite tu contraseña.'
          : _confirm.text != password
          ? 'Las contraseñas no coinciden.'
          : null;
      _termsError = _accepted
          ? null
          : 'Acepta los términos y privacidad para continuar.';
      _formError = null;
    });
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null &&
        _termsError == null;
  }

  Future<void> _register() async {
    if (!_validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _email.text.trim(),
            password: _password.text,
          );
      await credential.user?.updateDisplayName(_name.text.trim());
      await credential.user?.reload();
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _formError = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
    back: true,
    title: 'Tu camino seguro\nempieza aquí.',
    subtitle:
        'Crea tu cuenta y comparte tus trayectos con quienes más te cuidan.',
    children: [
      AuthField(
        controller: _name,
        label: 'Nombre completo',
        hint: '¿Cómo te llamas?',
        icon: Icons.person_outline_rounded,
        autofillHints: const [AutofillHints.name],
        errorText: _nameError,
        onChanged: (_) {
          if (_nameError != null) setState(() => _nameError = null);
        },
      ),
      AuthField(
        controller: _email,
        label: 'Correo electrónico',
        hint: 'tu@correo.com',
        icon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.email],
        errorText: _emailError,
        onChanged: (_) {
          if (_emailError != null) setState(() => _emailError = null);
        },
      ),
      AuthField(
        controller: _password,
        label: 'Contraseña',
        hint: 'Crea una contraseña',
        icon: Icons.lock_outline_rounded,
        password: true,
        autofillHints: const [AutofillHints.newPassword],
        errorText: _passwordError,
        onChanged: (_) {
          if (_passwordError != null) setState(() => _passwordError = null);
        },
      ),
      AuthField(
        controller: _confirm,
        label: 'Confirmar contraseña',
        hint: 'Repite tu contraseña',
        icon: Icons.lock_outline_rounded,
        password: true,
        errorText: _confirmError,
        onChanged: (_) {
          if (_confirmError != null) setState(() => _confirmError = null);
        },
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: _accepted,
            isError: _termsError != null,
            onChanged: (value) => setState(() {
              _accepted = value ?? false;
              if (_accepted) _termsError = null;
            }),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'He leído y acepto los',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () => showPendingDialog(
                    context,
                    'Aquí se mostrarán los términos de uso y el aviso de privacidad de SafeWalk. El contenido legal está pendiente.',
                  ),
                  child: const Text('Términos y privacidad'),
                ),
              ],
            ),
          ),
        ],
      ),
      FormErrorText(_termsError),
      const SizedBox(height: 16),
      FormErrorText(_formError),
      PrimaryButton(
        label: 'CREAR CUENTA',
        loading: _loading,
        onPressed: _register,
      ),
      const SizedBox(height: 18),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('¿Ya tienes una cuenta?'),
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            child: const Text('Inicia sesión'),
          ),
        ],
      ),
    ],
  );
}

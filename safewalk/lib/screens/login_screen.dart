import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../data/current_user.dart';
import '../widgets/auth_field.dart';
import '../widgets/auth_layout.dart';
import '../widgets/form_error_text.dart';
import '../widgets/pending_dialog.dart';
import '../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _googleLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _email.text.trim();
    setState(() {
      _emailError = email.isEmpty ? 'Escribe tu correo electrónico.' : null;
      _passwordError = _password.text.isEmpty ? 'Escribe tu contraseña.' : null;
      _formError = null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _signIn() async {
    if (!_validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _formError = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _googleLoading = true;
      _formError = null;
    });
    try {
      await signInWithGoogle();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() => _formError = error.message);
    } on GoogleSignInException catch (error) {
      if (!mounted) return;
      setState(() => _formError = error.description ?? error.code.name);
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthLayout(
    title: 'Qué bueno verte\nde nuevo.',
    subtitle: 'Inicia sesión para que te acompañemos en tu trayecto.',
    children: [
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
        hint: 'Tu contraseña',
        icon: Icons.lock_outline_rounded,
        password: true,
        autofillHints: const [AutofillHints.password],
        errorText: _passwordError,
        onChanged: (_) {
          if (_passwordError != null) setState(() => _passwordError = null);
        },
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: () => showPendingDialog(
            context,
            'La recuperación de contraseña estará disponible próximamente.',
          ),
          child: const Text('¿Olvidaste tu contraseña?'),
        ),
      ),
      const SizedBox(height: 12),
      FormErrorText(_formError),
      PrimaryButton(
        label: 'INICIAR SESIÓN',
        loading: _loading,
        onPressed: _signIn,
      ),
      const SizedBox(height: 18),
      OutlinedButton.icon(
        onPressed: _googleLoading || _loading ? null : _signInWithGoogle,
        icon: _googleLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : SvgPicture.asset('assets/google_logo.svg', width: 22, height: 22),
        label: const Text(
          'Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      const SizedBox(height: 18),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('¿No tienes cuenta?'),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: const Text('Crea una'),
          ),
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.password = false,
    this.keyboardType,
    this.autofillHints,
    this.controller,
    this.errorText,
    this.onChanged,
  });
  final String label;
  final String hint;
  final IconData icon;
  final bool password;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _visible = false;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          obscureText: widget.password && !_visible,
          keyboardType: widget.keyboardType,
          autofillHints: widget.autofillHints,
          autocorrect: !widget.password,
          enableSuggestions: !widget.password,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            errorMaxLines: 2,
            prefixIcon: Icon(widget.icon, size: 21),
            suffixIcon: widget.password
                ? IconButton(
                    tooltip: _visible
                        ? 'Ocultar contraseña'
                        : 'Mostrar contraseña',
                    onPressed: () => setState(() => _visible = !_visible),
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        _visible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        key: ValueKey(_visible),
                        size: 21,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ],
    ),
  );
}

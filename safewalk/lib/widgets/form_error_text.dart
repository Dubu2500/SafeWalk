import 'package:flutter/material.dart';

class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key});
  final String? message;
  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    final color = Theme.of(context).colorScheme.error;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(message!, style: TextStyle(color: color, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

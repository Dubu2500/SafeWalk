import 'package:flutter/material.dart';

class ProfileInfoTile extends StatelessWidget {
  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.controller,
    required this.editing,
    this.keyboardType,
  });
  final IconData icon;
  final String label;
  final String value;
  final TextEditingController controller;
  final bool editing;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: colors.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 4),
                // Switches between the plain value and an input when editing.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, ?current],
                  ),
                  child: editing
                      ? TextField(
                          key: const ValueKey('editing'),
                          controller: controller,
                          keyboardType: keyboardType,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        )
                      : Text(
                          value,
                          key: const ValueKey('viewing'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

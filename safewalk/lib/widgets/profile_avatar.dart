import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/photo_provider.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.name, required this.size});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final photo = context.watch<PhotoProvider>().photo;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2C408F), Color(0xFF4C7AE0)],
        ),
      ),
      child: photo != null
          ? Image.file(
              photo,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initial(),
            )
          : _initial(),
    );
  }

  Widget _initial() => Text(
    name.isEmpty ? '?' : name.substring(0, 1).toUpperCase(),
    style: TextStyle(
      color: Colors.white,
      fontSize: size * 0.4,
      fontWeight: FontWeight.w700,
    ),
  );
}

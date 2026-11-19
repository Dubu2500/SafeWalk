import 'package:flutter/material.dart';

import 'profile_avatar.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.onPhotoTap,
  });
  final String name;
  final String email;
  final VoidCallback onPhotoTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: onPhotoTap,
              child: ProfileAvatar(name: name, size: 96),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Material(
                color: colors.primary,
                shape: CircleBorder(
                  side: BorderSide(color: colors.surface, width: 3),
                ),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  tooltip: 'Cambiar foto de perfil',
                  onPressed: onPhotoTap,
                  constraints: const BoxConstraints.tightFor(
                    width: 36,
                    height: 36,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.photo_camera_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}

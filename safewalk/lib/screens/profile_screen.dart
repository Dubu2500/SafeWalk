import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/photo_provider.dart';
import '../widgets/primary_button.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_info_tile.dart';
import '../widgets/profile_stat.dart';
import '../widgets/settings_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _saving = false;
  bool _editing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _fillControllers() {
    final profile = context.read<AccountProvider>().profile!;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _cityController.text = profile.city;
  }

  void _cancelEditing() {
    _fillControllers();
    setState(() => _editing = false);
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Escribe tu nombre.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<AccountProvider>().saveProfile(
        name,
        _phoneController.text,
        _cityController.text,
      );
      if (mounted) setState(() => _editing = false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudieron guardar los cambios.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final changed = await context.read<PhotoProvider>().pickFromGallery();
      if (changed) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Foto de perfil actualizada.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir la galería. Revisa los permisos.'),
        ),
      );
    }
  }

  Future<void> _removePhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PhotoProvider>().removePhoto();
      messenger.showSnackBar(
        const SnackBar(content: Text('Foto de perfil eliminada.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo quitar la foto.')),
      );
    }
  }

  void _showPhotoOptions() {
    final hasPhoto = context.read<PhotoProvider>().photo != null;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto();
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Quitar foto'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _removePhoto();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountProvider>();
    final profile = account.profile!;
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Perfil',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              children: [
                ProfileHeader(
                  name: profile.name,
                  email: profile.email,
                  onPhotoTap: _showPhotoOptions,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ProfileStat(
                        value: '${account.completedWalks}',
                        label: 'Trayectos',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileStat(
                        value: '${account.contacts.length}',
                        label: 'Contactos',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ProfileStat(
                        value: profile.memberSince,
                        label: 'Miembro desde',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SettingsSection(
                  title: 'Datos personales',
                  children: [
                    ProfileInfoTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Nombre',
                      value: profile.name,
                      controller: _nameController,
                      editing: _editing,
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ProfileInfoTile(
                      icon: Icons.mail_outline_rounded,
                      label: 'Correo electrónico',
                      value: profile.email,
                      controller: _emailController,
                      editing: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ProfileInfoTile(
                      icon: Icons.phone_outlined,
                      label: 'Teléfono',
                      value: profile.phone,
                      controller: _phoneController,
                      editing: _editing,
                      keyboardType: TextInputType.phone,
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    ProfileInfoTile(
                      icon: Icons.location_city_outlined,
                      label: 'Ciudad',
                      value: profile.city,
                      controller: _cityController,
                      editing: _editing,
                    ),
                  ],
                ),
                SettingsSection(
                  title: 'Tu red de confianza',
                  children: [
                    ListTile(
                      leading: const Icon(Icons.people_outline_rounded),
                      title: const Text('Contactos de confianza'),
                      subtitle: Text(
                        '${account.contacts.length} personas te acompañan',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.pushNamed(context, '/contacts'),
                    ),
                  ],
                ),
                if (_editing) ...[
                  PrimaryButton(
                    label: 'GUARDAR CAMBIOS',
                    loading: _saving,
                    onPressed: _saveChanges,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _saving ? null : _cancelEditing,
                    child: const Text('Cancelar'),
                  ),
                ] else
                  PrimaryButton(
                    label: 'EDITAR PERFIL',
                    onPressed: () {
                      _fillControllers();
                      setState(() => _editing = true);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

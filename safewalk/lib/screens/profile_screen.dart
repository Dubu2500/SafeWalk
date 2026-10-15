import 'package:flutter/material.dart';

import '../data/profile_data.dart';
import '../models/user_profile.dart';
import '../widgets/pending_dialog.dart';
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
  UserProfile _profile = userProfile;
  bool _editing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fillControllers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _fillControllers() {
    _nameController.text = _profile.name;
    _emailController.text = _profile.email;
    _phoneController.text = _profile.phone;
    _cityController.text = _profile.city;
  }

  void _cancelEditing() {
    _fillControllers();
    setState(() => _editing = false);
  }

  void _saveChanges() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Tu nombre no puede quedar vacío.')),
        );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _profile = UserProfile(
        name: name,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        memberSince: _profile.memberSince,
        completedWalks: _profile.completedWalks,
      );
      _editing = false;
    });
    showPendingDialog(
      context,
      'Tus cambios se muestran en esta pantalla. Aquí se guardarán en tu cuenta. Funcionalidad pendiente.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                name: _profile.name,
                email: _profile.email,
                onPhotoTap: () => showPendingDialog(
                  context,
                  'Aquí podrás tomar o elegir una foto de perfil. Funcionalidad pendiente.',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ProfileStat(
                      value: '${_profile.completedWalks}',
                      label: 'Trayectos',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileStat(
                      value: '${trustedContacts.length}',
                      label: 'Contactos',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileStat(
                      value: _profile.memberSince,
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
                    value: _profile.name,
                    controller: _nameController,
                    editing: _editing,
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  ProfileInfoTile(
                    icon: Icons.mail_outline_rounded,
                    label: 'Correo electrónico',
                    value: _profile.email,
                    controller: _emailController,
                    editing: _editing,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  ProfileInfoTile(
                    icon: Icons.phone_outlined,
                    label: 'Teléfono',
                    value: _profile.phone,
                    controller: _phoneController,
                    editing: _editing,
                    keyboardType: TextInputType.phone,
                  ),
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  ProfileInfoTile(
                    icon: Icons.location_city_outlined,
                    label: 'Ciudad',
                    value: _profile.city,
                    controller: _cityController,
                    editing: _editing,
                  ),
                ],
              ),
              if (_editing) ...[
                PrimaryButton(label: 'GUARDAR CAMBIOS', onPressed: _saveChanges),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _cancelEditing,
                  child: const Text('Cancelar'),
                ),
              ] else
                PrimaryButton(
                  label: 'EDITAR PERFIL',
                  onPressed: () => setState(() => _editing = true),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import '../models/trusted_contact.dart';
import '../models/user_profile.dart';
import 'home_data.dart';

// Temporary local data until profiles and contacts are connected.
const userProfile = UserProfile(
  name: userName,
  email: 'ruben@safewalk.app',
  phone: '33 1234 5678',
  city: 'Guadalajara, Jal.',
  memberSince: 'Sep 2026',
  completedWalks: 12,
);

const trustedContacts = [
  TrustedContact(
    id: 'maria',
    name: trustedContactName,
    relationship: 'Mamá',
    phone: '33 2345 6789',
  ),
  TrustedContact(
    id: 'carlos',
    name: 'Carlos',
    relationship: 'Hermano',
    phone: '33 3456 7890',
  ),
  TrustedContact(
    id: 'sofia',
    name: 'Sofía',
    relationship: 'Amiga',
    phone: '33 4567 8901',
    available: false,
  ),
];

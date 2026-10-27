class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.memberSince,
    required this.completedWalks,
  });

  final String name;
  final String email;
  final String phone;
  final String city;
  final String memberSince;
  final int completedWalks;
}

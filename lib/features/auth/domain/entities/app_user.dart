class AppUser {
  final String uid;
  final String? displayName;
  final String? email;
  final bool emailVerified;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    this.displayName,
    this.email,
    this.emailVerified = false,
    this.photoUrl,
  });
}

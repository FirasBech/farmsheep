String? validateEmail(String? v) =>
    (v == null || !v.contains('@')) ? 'Enter a valid email' : null;

String? validatePassword(String? v) {
  if (v == null || v.length < 8) return 'Min 8 characters';
  if (!v.contains(RegExp(r'[0-9]'))) return 'Include at least one number';
  return null;
}

String? validateTagNumber(String? v) {
  if (v == null || v.isEmpty) return 'Required';
  final n = int.tryParse(v);
  if (n == null || n <= 0) return 'Enter a valid positive number';
  return null;
}

String? validateRequired(String? v, [String label = 'Required']) =>
    (v == null || v.trim().isEmpty) ? label : null;

enum PasswordStrength { weak, medium, strong }

PasswordStrength checkPasswordStrength(String p) {
  if (p.length < 8 || !p.contains(RegExp(r'[0-9]'))) {
    return PasswordStrength.weak;
  }
  if (p.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
    return PasswordStrength.strong;
  }
  return PasswordStrength.medium;
}

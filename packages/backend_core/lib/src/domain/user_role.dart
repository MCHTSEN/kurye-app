/// Uygulama kullanıcı rolleri.
enum UserRole {
  musteriPersonel('musteri_personel'),
  operasyon('operasyon'),
  kurye('kurye');

  const UserRole(this.value);

  /// Supabase/DB'deki string değeri.
  final String value;

  static UserRole fromValue(String raw) {
    for (final role in UserRole.values) {
      if (role.value == raw) return role;
    }
    throw ArgumentError('Unknown UserRole value: $raw');
  }
}

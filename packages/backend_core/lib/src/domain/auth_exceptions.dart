/// Email onayı beklendiğinde fırlatılır.
class EmailConfirmationRequiredException implements Exception {
  const EmailConfirmationRequiredException(this.email);

  final String email;

  @override
  String toString() =>
      'Kayıt başarılı! $email adresine onay e-postası gönderildi. '
      'Lütfen e-postanızı kontrol edin.';
}

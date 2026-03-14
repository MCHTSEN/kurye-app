# Feature: Rol Seçimi

## Scope
Register sonrası kullanıcı rol seçer (Müşteri Personeli / Kurye).
Talep oluşturulur, operasyon onayına gider.
Onay beklerken "İnceleniyor" ekranı gösterilir.

## Routes
- `/role-selection` — Rol seçim + talep durumu ekranı

## States
- **NoRequest**: Rol seçim formu gösterilir
- **Pending**: "İnceleniyor" mesajı
- **Approved**: Otomatik yönlendirme
- **Rejected**: Red mesajı + tekrar talep

## Dependencies
- `RoleRequestRepository`
- `CurrentUserProfile` provider

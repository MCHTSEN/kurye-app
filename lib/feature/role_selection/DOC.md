# Feature: Rol Seçimi

## Scope
Register sonrası kullanıcı müşteri personeli hesabı açar.
Girişte iki onboarding yolu sunulur:
- yeni müşteri oluştur
- var olan müşteriye eleman olarak katıl

Talep oluşturulur ve operasyon onayına gider.
Başvuru oluşturulurken kullanıcı için `is_active=false` provisional profil
açılır.
- Yeni müşteri yolunda provisional `musteriler` kaydı da açılır ve kullanıcı bu
  müşteriye bağlanır.
- Var olan müşteri yolunda kullanıcı seçilen müşteriye provisional olarak
  bağlanır.

## Routes
- `/role-selection` — Hesap tipi seçimi + müşteri başvuru formu

## States
- **NoRequest**: Hesap tipi ve başvuru formu gösterilir
- **Pending/NewCustomer**: Provisional müşteri + provisional kullanıcı açılır
- **Pending/JoinExisting**: Provisional kullanıcı seçilen müşteriye bağlanır
- **Approved**: Otomatik yönlendirme
- **Rejected**: Red mesajı + tekrar talep

## Dependencies
- `RoleRequestRepository`
- `MusteriRepository`
- `CurrentUserProfile` provider
- `AppAccessGuard`

## Last Updated
- 2026-04-12

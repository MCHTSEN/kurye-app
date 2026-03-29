# Project

## What This Is

Moto kurye dispatch uygulaması. Operasyon, müşteri ve kurye rollerinin aynı sipariş yaşam döngüsünde çalıştığı Flutter + Supabase tabanlı bir mobil/web uygulama. Mevcut durumda çekirdek dispatch akışı, müşteri/uğrama yönetimi, kurye akışı, dashboard ve many-to-many uğrama modeli build edilmiş durumda; bu milestone bu sistemi iPhone 17 simulator ve browser üzerinden canlı doğrulamaya ve sertleştirmeye odaklanır.

## Core Value

Müşteri → operasyon → kurye → tamamlanma sipariş döngüsünün canlı ortamda gerçekten çalışması.

## Current State

- M001 tamamlandı: rol bazlı auth/routing, müşteri/personel/kurye CRUD, sipariş oluşturma, operasyon dispatch, kurye timestamp akışı, geçmiş, dashboard ve sesli uyarılar mevcut.
- M002 tamamlandı: uğramalar many-to-many köprü tablo modeline taşındı, müşteri uğrama talep sistemi eklendi.
- Supabase backend aktif; mock backend üzerinden smoke integration testleri de repo içinde mevcut.
- Önceki manuel UAT izi iPhone 15 Pro simulator üzerinde var, ancak bu milestone için doğrulama odağı iPhone 17 simulator.

## Architecture / Key Patterns

- Flutter app with `auto_route` and centralized guards
- Supabase auth + RLS enforced role isolation
- Riverpod 3 providers and stream-based realtime UI updates
- `core / product / feature` layer separation
- Repository contracts in `backend_core`, concrete Supabase adapters in `backend_supabase`
- Existing verification assets include widget tests, integration tests, UAT checklists, and MCP-driven mobile validation

## Capability Contract

See `.gsd/REQUIREMENTS.md` for the explicit capability contract, requirement status, and coverage mapping.

## Milestone Sequence

- [x] M001: Core Dispatch App — temel dispatch ürün döngüsü ve rol bazlı operasyon akışları canlı hale geldi
- [x] M002: Many-to-Many Uğrama Modeli ve Talep Sistemi — uğrama modeli çoklu müşteri atamasına ve talep/onay akışına taşındı
- [ ] M003: Live Verification and Hardening — iPhone 17 simulator ve browser üzerinden canlı cross-role loop doğrulanır, kırık yerler düzeltilir, tekrar edilebilir test yolu bırakılır

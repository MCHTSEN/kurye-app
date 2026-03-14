-- ============================================================
-- RLS sonsuz döngü düzeltmesi
-- app_users tablosu kendi kendini referans alamaz.
-- Çözüm: app_users için auth.jwt() claim kullanılır.
-- ============================================================

-- Önce app_users üzerindeki tüm policy'leri kaldır
DROP POLICY IF EXISTS operasyon_full_access ON app_users;
DROP POLICY IF EXISTS musteri_personel_self ON app_users;
DROP POLICY IF EXISTS kurye_self ON app_users;

-- app_users: Herkes kendi kaydını okuyabilir
CREATE POLICY app_users_self_read ON app_users
  FOR SELECT USING (id = auth.uid());

-- app_users: Operasyon tüm kayıtları okuyabilir
-- auth.jwt() ile role kontrol ediyoruz (döngü yok)
CREATE POLICY app_users_operasyon_read ON app_users
  FOR ALL USING (
    (SELECT role FROM app_users WHERE id = auth.uid()) = 'operasyon'
  );

-- Yukarıdaki hâlâ döngü yaratır, alternatif yaklaşım:
-- Security definer fonksiyon kullan
DROP POLICY IF EXISTS app_users_operasyon_read ON app_users;

CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS user_role
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = ''
AS $$
  SELECT role FROM public.app_users WHERE id = auth.uid();
$$;

-- Diğer tablolardaki operasyon policy'lerini güncelle
-- (app_users subquery yerine get_my_role() fonksiyonu kullan)

-- app_users: operasyon tüm kayıtları yönetir
CREATE POLICY app_users_operasyon_all ON app_users
  FOR ALL USING (public.get_my_role() = 'operasyon');

-- musteriler
DROP POLICY IF EXISTS operasyon_musteriler ON musteriler;
DROP POLICY IF EXISTS musteri_personel_musteri ON musteriler;

CREATE POLICY musteriler_operasyon ON musteriler
  FOR ALL USING (public.get_my_role() = 'operasyon');

CREATE POLICY musteriler_musteri_read ON musteriler
  FOR SELECT USING (
    id = (SELECT musteri_id FROM public.app_users WHERE id = auth.uid())
  );

-- musteri_personelleri
DROP POLICY IF EXISTS operasyon_personeller ON musteri_personelleri;
DROP POLICY IF EXISTS musteri_personel_personeller ON musteri_personelleri;

CREATE POLICY personeller_operasyon ON musteri_personelleri
  FOR ALL USING (public.get_my_role() = 'operasyon');

CREATE POLICY personeller_musteri_read ON musteri_personelleri
  FOR SELECT USING (
    musteri_id = (SELECT musteri_id FROM public.app_users WHERE id = auth.uid())
  );

-- ugramalar
DROP POLICY IF EXISTS operasyon_ugramalar ON ugramalar;
DROP POLICY IF EXISTS musteri_personel_ugramalar ON ugramalar;
DROP POLICY IF EXISTS kurye_ugramalar_read ON ugramalar;

CREATE POLICY ugramalar_operasyon ON ugramalar
  FOR ALL USING (public.get_my_role() = 'operasyon');

CREATE POLICY ugramalar_musteri_read ON ugramalar
  FOR SELECT USING (
    musteri_id = (SELECT musteri_id FROM public.app_users WHERE id = auth.uid())
  );

CREATE POLICY ugramalar_kurye_read ON ugramalar
  FOR SELECT USING (public.get_my_role() = 'kurye');

-- kuryeler
DROP POLICY IF EXISTS operasyon_kuryeler ON kuryeler;
DROP POLICY IF EXISTS kurye_kuryeler_self ON kuryeler;

CREATE POLICY kuryeler_operasyon ON kuryeler
  FOR ALL USING (public.get_my_role() = 'operasyon');

CREATE POLICY kuryeler_self ON kuryeler
  FOR ALL USING (user_id = auth.uid());

-- siparisler
DROP POLICY IF EXISTS operasyon_siparisler ON siparisler;
DROP POLICY IF EXISTS musteri_personel_siparisler_select ON siparisler;
DROP POLICY IF EXISTS musteri_personel_siparisler_insert ON siparisler;
DROP POLICY IF EXISTS kurye_siparisler ON siparisler;
DROP POLICY IF EXISTS kurye_siparisler_update ON siparisler;

CREATE POLICY siparisler_operasyon ON siparisler
  FOR ALL USING (public.get_my_role() = 'operasyon');

CREATE POLICY siparisler_musteri_read ON siparisler
  FOR SELECT USING (
    musteri_id = (SELECT musteri_id FROM public.app_users WHERE id = auth.uid())
  );

CREATE POLICY siparisler_musteri_insert ON siparisler
  FOR INSERT WITH CHECK (
    musteri_id = (SELECT musteri_id FROM public.app_users WHERE id = auth.uid())
  );

CREATE POLICY siparisler_kurye_read ON siparisler
  FOR SELECT USING (
    kurye_id = (SELECT id FROM public.kuryeler WHERE user_id = auth.uid())
  );

CREATE POLICY siparisler_kurye_update ON siparisler
  FOR UPDATE USING (
    kurye_id = (SELECT id FROM public.kuryeler WHERE user_id = auth.uid())
  );

-- siparis_log
DROP POLICY IF EXISTS operasyon_siparis_log ON siparis_log;

CREATE POLICY siparis_log_operasyon ON siparis_log
  FOR ALL USING (public.get_my_role() = 'operasyon');

-- kurye_konum
DROP POLICY IF EXISTS operasyon_kurye_konum ON kurye_konum;
DROP POLICY IF EXISTS kurye_konum_self ON kurye_konum;

CREATE POLICY kurye_konum_operasyon ON kurye_konum
  FOR ALL USING (public.get_my_role() = 'operasyon');

CREATE POLICY kurye_konum_self ON kurye_konum
  FOR ALL USING (
    kurye_id = (SELECT id FROM public.kuryeler WHERE user_id = auth.uid())
  );

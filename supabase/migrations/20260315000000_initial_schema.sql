-- ============================================================
-- Moto Kurye Sipariş & Takip — Başlangıç Şeması
-- ============================================================

-- PostGIS uzantısı (Geography tipi için)
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================================
-- 1. ENUM Tipleri
-- ============================================================

CREATE TYPE user_role AS ENUM ('musteri_personel', 'operasyon', 'kurye');

CREATE TYPE siparis_durum AS ENUM (
  'kurye_bekliyor',
  'devam_ediyor',
  'tamamlandi',
  'iptal'
);

-- ============================================================
-- 2. Müşteriler (Firmalar)
-- ============================================================

CREATE TABLE musteriler (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firma_kisa_ad TEXT NOT NULL,
  firma_tam_ad TEXT,
  telefon TEXT,
  adres TEXT,
  email TEXT,
  vergi_no TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 3. Uygulama Kullanıcıları (auth.users ile ilişkili)
-- ============================================================

CREATE TABLE app_users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role user_role NOT NULL,
  display_name TEXT NOT NULL,
  phone TEXT,
  is_active BOOLEAN DEFAULT true,
  musteri_id UUID REFERENCES musteriler(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 4. Müşteri Personelleri
-- ============================================================

CREATE TABLE musteri_personelleri (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  musteri_id UUID NOT NULL REFERENCES musteriler(id) ON DELETE CASCADE,
  user_id UUID REFERENCES app_users(id) ON DELETE SET NULL,
  ad TEXT NOT NULL,
  telefon TEXT,
  email TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 5. Uğramalar (güzergah noktaları, müşteriye ait)
-- ============================================================

CREATE TABLE ugramalar (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  musteri_id UUID NOT NULL REFERENCES musteriler(id) ON DELETE CASCADE,
  ugrama_adi TEXT NOT NULL,
  adres TEXT,
  lokasyon GEOGRAPHY(POINT, 4326),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 6. Kuryeler
-- ============================================================

CREATE TABLE kuryeler (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES app_users(id) ON DELETE SET NULL,
  ad TEXT NOT NULL,
  telefon TEXT,
  plaka TEXT,
  is_active BOOLEAN DEFAULT true,
  is_online BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 7. Siparişler
-- ============================================================

CREATE TABLE siparisler (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  musteri_id UUID NOT NULL REFERENCES musteriler(id) ON DELETE RESTRICT,
  personel_id UUID REFERENCES musteri_personelleri(id) ON DELETE SET NULL,
  kurye_id UUID REFERENCES kuryeler(id) ON DELETE SET NULL,
  cikis_id UUID NOT NULL REFERENCES ugramalar(id) ON DELETE RESTRICT,
  ugrama_id UUID NOT NULL REFERENCES ugramalar(id) ON DELETE RESTRICT,
  ugrama1_id UUID REFERENCES ugramalar(id) ON DELETE SET NULL,
  not_id UUID REFERENCES ugramalar(id) ON DELETE SET NULL,
  not1 TEXT,
  durum siparis_durum NOT NULL DEFAULT 'kurye_bekliyor',
  ucret NUMERIC(10,2),
  cikis_saat TIMESTAMPTZ,
  ugrama_saat TIMESTAMPTZ,
  ugrama1_saat TIMESTAMPTZ,
  atanma_saat TIMESTAMPTZ,
  bitis_saat TIMESTAMPTZ,
  olusturan_id UUID REFERENCES app_users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 8. Sipariş Log (durum değişiklik takibi)
-- ============================================================

CREATE TABLE siparis_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  siparis_id UUID NOT NULL REFERENCES siparisler(id) ON DELETE CASCADE,
  eski_durum siparis_durum,
  yeni_durum siparis_durum NOT NULL,
  degistiren_id UUID REFERENCES app_users(id) ON DELETE SET NULL,
  aciklama TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 9. Kurye Konum (günlük)
-- ============================================================

CREATE TABLE kurye_konum (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  kurye_id UUID NOT NULL REFERENCES kuryeler(id) ON DELETE CASCADE,
  lokasyon GEOGRAPHY(POINT, 4326) NOT NULL,
  tarih DATE DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- 10. Indexler
-- ============================================================

CREATE INDEX idx_app_users_role ON app_users(role);
CREATE INDEX idx_app_users_musteri ON app_users(musteri_id);
CREATE INDEX idx_musteri_personelleri_musteri ON musteri_personelleri(musteri_id);
CREATE INDEX idx_ugramalar_musteri ON ugramalar(musteri_id);
CREATE INDEX idx_kuryeler_user ON kuryeler(user_id);
CREATE INDEX idx_kuryeler_online ON kuryeler(is_active, is_online);
CREATE INDEX idx_siparisler_durum ON siparisler(durum);
CREATE INDEX idx_siparisler_musteri ON siparisler(musteri_id);
CREATE INDEX idx_siparisler_kurye ON siparisler(kurye_id);
CREATE INDEX idx_siparisler_created ON siparisler(created_at DESC);
CREATE INDEX idx_siparis_log_siparis ON siparis_log(siparis_id);
CREATE INDEX idx_kurye_konum_tarih ON kurye_konum(kurye_id, tarih);

-- ============================================================
-- 11. Updated_at trigger
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_musteriler_updated
  BEFORE UPDATE ON musteriler
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_app_users_updated
  BEFORE UPDATE ON app_users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_kuryeler_updated
  BEFORE UPDATE ON kuryeler
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_siparisler_updated
  BEFORE UPDATE ON siparisler
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- 12. Realtime aktifleştirme
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE siparisler;
ALTER PUBLICATION supabase_realtime ADD TABLE kuryeler;
ALTER PUBLICATION supabase_realtime ADD TABLE kurye_konum;

-- ============================================================
-- 13. RLS (Row Level Security) — Temel politikalar
-- ============================================================

ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE musteriler ENABLE ROW LEVEL SECURITY;
ALTER TABLE musteri_personelleri ENABLE ROW LEVEL SECURITY;
ALTER TABLE ugramalar ENABLE ROW LEVEL SECURITY;
ALTER TABLE kuryeler ENABLE ROW LEVEL SECURITY;
ALTER TABLE siparisler ENABLE ROW LEVEL SECURITY;
ALTER TABLE siparis_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE kurye_konum ENABLE ROW LEVEL SECURITY;

-- Operasyon: her şeye erişir
CREATE POLICY operasyon_full_access ON app_users
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

CREATE POLICY operasyon_musteriler ON musteriler
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

CREATE POLICY operasyon_personeller ON musteri_personelleri
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

CREATE POLICY operasyon_ugramalar ON ugramalar
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

CREATE POLICY operasyon_kuryeler ON kuryeler
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

CREATE POLICY operasyon_siparisler ON siparisler
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

CREATE POLICY operasyon_siparis_log ON siparis_log
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

CREATE POLICY operasyon_kurye_konum ON kurye_konum
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

-- Müşteri personeli: kendi müşterisinin verilerine erişir
CREATE POLICY musteri_personel_self ON app_users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY musteri_personel_musteri ON musteriler
  FOR SELECT USING (
    id = (SELECT musteri_id FROM app_users WHERE id = auth.uid())
  );

CREATE POLICY musteri_personel_personeller ON musteri_personelleri
  FOR SELECT USING (
    musteri_id = (SELECT musteri_id FROM app_users WHERE id = auth.uid())
  );

CREATE POLICY musteri_personel_ugramalar ON ugramalar
  FOR SELECT USING (
    musteri_id = (SELECT musteri_id FROM app_users WHERE id = auth.uid())
  );

CREATE POLICY musteri_personel_siparisler_select ON siparisler
  FOR SELECT USING (
    musteri_id = (SELECT musteri_id FROM app_users WHERE id = auth.uid())
  );

CREATE POLICY musteri_personel_siparisler_insert ON siparisler
  FOR INSERT WITH CHECK (
    musteri_id = (SELECT musteri_id FROM app_users WHERE id = auth.uid())
  );

-- Kurye: kendi verilerine erişir
CREATE POLICY kurye_self ON app_users
  FOR SELECT USING (id = auth.uid());

CREATE POLICY kurye_kuryeler_self ON kuryeler
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY kurye_siparisler ON siparisler
  FOR SELECT USING (
    kurye_id = (SELECT id FROM kuryeler WHERE user_id = auth.uid())
  );

CREATE POLICY kurye_siparisler_update ON siparisler
  FOR UPDATE USING (
    kurye_id = (SELECT id FROM kuryeler WHERE user_id = auth.uid())
  );

CREATE POLICY kurye_konum_self ON kurye_konum
  FOR ALL USING (
    kurye_id = (SELECT id FROM kuryeler WHERE user_id = auth.uid())
  );

-- Kurye: uğrama isimlerini görebilir (güzergah bilgisi için)
CREATE POLICY kurye_ugramalar_read ON ugramalar
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'kurye')
  );

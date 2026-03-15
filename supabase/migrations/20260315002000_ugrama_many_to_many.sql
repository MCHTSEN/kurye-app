-- ============================================================
-- M002/S01: Uğrama Many-to-Many Model + Talep Sistemi
-- ============================================================
-- Uğramalar artık bağımsız havuzda yaşar.
-- Müşteri-uğrama ilişkisi musteri_ugrama köprü tablosu üzerinden.
-- Müşteri personeli uğrama talebi gönderebilir.
-- ============================================================

-- ============================================================
-- 1. ENUM: Talep durumu (idempotent)
-- ============================================================

DO $$ BEGIN
  CREATE TYPE ugrama_talep_durum AS ENUM (
    'beklemede',
    'onaylandi',
    'reddedildi'
  );
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- ============================================================
-- 2. Cleanup: drop tables if they exist from partial prior run
-- ============================================================

DROP TABLE IF EXISTS musteri_ugrama CASCADE;
DROP TABLE IF EXISTS ugrama_talepleri CASCADE;

-- ============================================================
-- 3. Köprü tablosu: musteri_ugrama (many-to-many)
-- ============================================================

CREATE TABLE musteri_ugrama (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  musteri_id UUID NOT NULL REFERENCES musteriler(id) ON DELETE CASCADE,
  ugrama_id UUID NOT NULL REFERENCES ugramalar(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(musteri_id, ugrama_id)
);

CREATE INDEX idx_musteri_ugrama_musteri ON musteri_ugrama(musteri_id);
CREATE INDEX idx_musteri_ugrama_ugrama ON musteri_ugrama(ugrama_id);

-- ============================================================
-- 4. Data migration: mevcut musteri_id → köprü tablosuna
-- ============================================================

INSERT INTO musteri_ugrama (musteri_id, ugrama_id)
SELECT musteri_id, id
FROM ugramalar
WHERE musteri_id IS NOT NULL
ON CONFLICT (musteri_id, ugrama_id) DO NOTHING;

-- ============================================================
-- 5. ugramalar.musteri_id sütununu kaldır
-- ============================================================

-- Önce TÜM RLS politikalarını kaldır (musteri_id referans edenler dahil)
DROP POLICY IF EXISTS operasyon_ugramalar ON ugramalar;
DROP POLICY IF EXISTS musteri_personel_ugramalar ON ugramalar;
DROP POLICY IF EXISTS kurye_ugramalar_read ON ugramalar;
DROP POLICY IF EXISTS ugramalar_musteri_read ON ugramalar;

-- Mevcut index kaldır
DROP INDEX IF EXISTS idx_ugramalar_musteri;

-- FK constraint ve sütun kaldır
ALTER TABLE ugramalar DROP COLUMN musteri_id;

-- ============================================================
-- 6. Uğrama talepleri tablosu
-- ============================================================

CREATE TABLE ugrama_talepleri (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  musteri_id UUID NOT NULL REFERENCES musteriler(id) ON DELETE CASCADE,
  talep_eden_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  ugrama_adi TEXT NOT NULL,
  adres TEXT,
  durum ugrama_talep_durum NOT NULL DEFAULT 'beklemede',
  red_notu TEXT,
  islem_yapan_id UUID REFERENCES app_users(id) ON DELETE SET NULL,
  onaylanan_ugrama_id UUID REFERENCES ugramalar(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_ugrama_talepleri_musteri ON ugrama_talepleri(musteri_id);
CREATE INDEX idx_ugrama_talepleri_durum ON ugrama_talepleri(durum);

-- Updated_at trigger
CREATE TRIGGER trg_ugrama_talepleri_updated
  BEFORE UPDATE ON ugrama_talepleri
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- 7. RLS politikaları
-- ============================================================

-- 7a. musteri_ugrama RLS
ALTER TABLE musteri_ugrama ENABLE ROW LEVEL SECURITY;

-- Operasyon: tam erişim
CREATE POLICY operasyon_musteri_ugrama ON musteri_ugrama
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

-- Müşteri personeli: kendi müşterisinin atamalarını görebilir
CREATE POLICY musteri_personel_musteri_ugrama ON musteri_ugrama
  FOR SELECT USING (
    musteri_id = (SELECT musteri_id FROM app_users WHERE id = auth.uid())
  );

-- 7b. ugramalar RLS yeniden yazılıyor (köprü üzerinden)

-- Operasyon: tam erişim
CREATE POLICY operasyon_ugramalar ON ugramalar
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

-- Müşteri personeli: köprü tablosu üzerinden kendi müşterisine atanmış uğramaları görür
CREATE POLICY musteri_personel_ugramalar ON ugramalar
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM musteri_ugrama mu
      WHERE mu.ugrama_id = ugramalar.id
        AND mu.musteri_id = (SELECT musteri_id FROM app_users WHERE id = auth.uid())
    )
  );

-- Kurye: tüm uğramaları görebilir (teslimat için gerekli)
CREATE POLICY kurye_ugramalar_read ON ugramalar
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'kurye')
  );

-- 7c. ugrama_talepleri RLS
ALTER TABLE ugrama_talepleri ENABLE ROW LEVEL SECURITY;

-- Operasyon: tam erişim
CREATE POLICY operasyon_ugrama_talepleri ON ugrama_talepleri
  FOR ALL USING (
    EXISTS (SELECT 1 FROM app_users WHERE id = auth.uid() AND role = 'operasyon')
  );

-- Müşteri personeli: kendi müşterisinin taleplerini görebilir ve oluşturabilir
CREATE POLICY musteri_personel_ugrama_talepleri_select ON ugrama_talepleri
  FOR SELECT USING (
    musteri_id = (SELECT musteri_id FROM app_users WHERE id = auth.uid())
  );

CREATE POLICY musteri_personel_ugrama_talepleri_insert ON ugrama_talepleri
  FOR INSERT WITH CHECK (
    musteri_id = (SELECT musteri_id FROM app_users WHERE id = auth.uid())
    AND talep_eden_id = auth.uid()
  );

-- ============================================================
-- 8. Realtime: ugrama_talepleri için (operasyon bildirim alabilsin)
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE ugrama_talepleri;

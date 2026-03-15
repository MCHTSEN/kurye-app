-- Composite index for auto-pricing lookup performance.
-- Used by getRecentPricing(musteri_id, cikis_id, ugrama_id) to find the most
-- recent tamamlandi order with matching customer+route.
CREATE INDEX idx_siparisler_pricing
  ON siparisler(musteri_id, cikis_id, ugrama_id, durum, created_at DESC);

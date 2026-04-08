ALTER TABLE siparisler
ADD COLUMN IF NOT EXISTS faturalandirildi BOOLEAN NOT NULL DEFAULT false;

UPDATE siparisler
SET faturalandirildi = false
WHERE faturalandirildi IS NULL;

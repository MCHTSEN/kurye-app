-- Push notification altyapısı:
-- 1. user_devices: FCM token storage (multi-device per user)
-- 2. siparisler.kurye_gordu_at: kurye sipariş detayını açtığında set edilen timestamp

-- ============================================================================
-- user_devices
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL UNIQUE,
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android')),
  app_version TEXT,
  last_seen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS user_devices_user_id_idx ON user_devices(user_id);

-- updated_at otomatik güncelle (initial_schema'da trigger fonksiyonu varsayılıyor;
-- yoksa burada da tanımla)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'set_updated_at') THEN
    CREATE FUNCTION set_updated_at() RETURNS TRIGGER AS $func$
    BEGIN
      NEW.updated_at = now();
      RETURN NEW;
    END;
    $func$ LANGUAGE plpgsql;
  END IF;
END$$;

DROP TRIGGER IF EXISTS user_devices_set_updated_at ON user_devices;
CREATE TRIGGER user_devices_set_updated_at
  BEFORE UPDATE ON user_devices
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- RLS: kullanıcı sadece kendi token'larını yönetebilir
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_devices_self_select ON user_devices;
CREATE POLICY user_devices_self_select ON user_devices
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS user_devices_self_insert ON user_devices;
CREATE POLICY user_devices_self_insert ON user_devices
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS user_devices_self_update ON user_devices;
CREATE POLICY user_devices_self_update ON user_devices
  FOR UPDATE USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS user_devices_self_delete ON user_devices;
CREATE POLICY user_devices_self_delete ON user_devices
  FOR DELETE USING (user_id = auth.uid());

COMMENT ON TABLE user_devices IS
  'FCM device tokens per authenticated user. Edge Functions read via service_role to fan-out notifications.';

-- ============================================================================
-- siparisler.kurye_gordu_at
-- ============================================================================

ALTER TABLE siparisler
  ADD COLUMN IF NOT EXISTS kurye_gordu_at TIMESTAMPTZ;

COMMENT ON COLUMN siparisler.kurye_gordu_at IS
  'Kurye sipariş detayını ilk açtığı an. Operasyon panelinde "Görüldü" rozeti.';

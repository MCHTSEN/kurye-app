-- ============================================================
-- Rol talep sistemi
-- Kullanıcı register olduktan sonra rol seçer → onay bekler
-- ============================================================

CREATE TYPE role_request_status AS ENUM ('beklemede', 'onaylandi', 'reddedildi');

CREATE TABLE role_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  requested_role user_role NOT NULL,
  status role_request_status NOT NULL DEFAULT 'beklemede',
  display_name TEXT NOT NULL,
  phone TEXT,
  note TEXT, -- kullanıcının ek notu (ör: "X firmasında çalışıyorum")
  reviewed_by UUID REFERENCES app_users(id) ON DELETE SET NULL,
  reviewed_at TIMESTAMPTZ,
  reject_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_role_requests_status ON role_requests(status);
CREATE INDEX idx_role_requests_user ON role_requests(user_id);

-- Updated_at trigger
CREATE TRIGGER trg_role_requests_updated
  BEFORE UPDATE ON role_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Realtime (operasyon ekranına anlık düşmesi için)
ALTER PUBLICATION supabase_realtime ADD TABLE role_requests;

-- RLS
ALTER TABLE role_requests ENABLE ROW LEVEL SECURITY;

-- Herkes kendi talebini görebilir
CREATE POLICY role_requests_self_read ON role_requests
  FOR SELECT USING (user_id = auth.uid());

-- Herkes talep oluşturabilir (sadece kendi user_id'si ile)
CREATE POLICY role_requests_self_insert ON role_requests
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- Operasyon tüm talepleri yönetir
CREATE POLICY role_requests_operasyon ON role_requests
  FOR ALL USING (public.get_my_role() = 'operasyon');

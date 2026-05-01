ALTER TABLE role_requests
ADD COLUMN IF NOT EXISTS musteri_id UUID REFERENCES musteriler(id) ON DELETE SET NULL;

ALTER TABLE role_requests
ADD COLUMN IF NOT EXISTS account_type TEXT;

ALTER TABLE role_requests
ADD COLUMN IF NOT EXISTS company_name TEXT;

CREATE INDEX IF NOT EXISTS idx_role_requests_musteri_id
ON role_requests(musteri_id);

DROP POLICY IF EXISTS musteriler_authenticated_read ON musteriler;
CREATE POLICY musteriler_authenticated_read ON musteriler
  FOR SELECT USING (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS app_users_pending_self_insert ON app_users;
CREATE POLICY app_users_pending_self_insert ON app_users
  FOR INSERT WITH CHECK (
    id = auth.uid()
    AND role = 'musteri_personel'
    AND is_active = false
  );

DROP POLICY IF EXISTS musteriler_self_signup_insert ON musteriler;
CREATE POLICY musteriler_self_signup_insert ON musteriler
  FOR INSERT TO authenticated
  WITH CHECK (COALESCE(is_active, false) = false);

DROP POLICY IF EXISTS musteriler_pending_self_update ON musteriler;
CREATE POLICY musteriler_pending_self_update ON musteriler
  FOR UPDATE TO authenticated
  USING (
    id = (SELECT musteri_id FROM public.app_users WHERE id = auth.uid())
    AND COALESCE(
      (SELECT is_active FROM public.app_users WHERE id = auth.uid()),
      false
    ) = false
  )
  WITH CHECK (
    id = (SELECT musteri_id FROM public.app_users WHERE id = auth.uid())
  );

CREATE OR REPLACE FUNCTION public.create_role_request_with_provisioning(
  p_display_name TEXT,
  p_phone TEXT DEFAULT NULL,
  p_note TEXT DEFAULT NULL,
  p_account_type TEXT DEFAULT NULL,
  p_company_name TEXT DEFAULT NULL,
  p_musteri_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id UUID;
  v_resolved_musteri_id UUID;
  v_request role_requests%ROWTYPE;
BEGIN
  v_user_id := auth.uid();

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  IF trim(COALESCE(p_display_name, '')) = '' THEN
    RAISE EXCEPTION 'display_name is required';
  END IF;

  IF p_account_type = 'new_customer' THEN
    IF trim(COALESCE(p_company_name, '')) = '' THEN
      RAISE EXCEPTION 'company_name is required for new_customer';
    END IF;

    INSERT INTO public.musteriler (
      firma_kisa_ad,
      firma_tam_ad,
      telefon,
      is_active
    )
    VALUES (
      trim(p_company_name),
      trim(p_company_name),
      NULLIF(trim(COALESCE(p_phone, '')), ''),
      FALSE
    )
    RETURNING id INTO v_resolved_musteri_id;
  ELSIF p_account_type = 'existing_customer_employee' THEN
    IF p_musteri_id IS NULL THEN
      RAISE EXCEPTION 'musteri_id is required for existing_customer_employee';
    END IF;

    PERFORM 1
    FROM public.musteriler
    WHERE id = p_musteri_id;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Customer not found';
    END IF;

    v_resolved_musteri_id := p_musteri_id;
  ELSE
    RAISE EXCEPTION 'Invalid account_type';
  END IF;

  INSERT INTO public.role_requests (
    user_id,
    requested_role,
    status,
    display_name,
    account_type,
    company_name,
    musteri_id,
    phone,
    note
  )
  VALUES (
    v_user_id,
    'musteri_personel',
    'beklemede',
    trim(p_display_name),
    p_account_type,
    NULLIF(trim(COALESCE(p_company_name, '')), ''),
    v_resolved_musteri_id,
    NULLIF(trim(COALESCE(p_phone, '')), ''),
    NULLIF(trim(COALESCE(p_note, '')), '')
  )
  RETURNING * INTO v_request;

  INSERT INTO public.app_users (
    id,
    role,
    display_name,
    phone,
    is_active,
    musteri_id
  )
  VALUES (
    v_user_id,
    'musteri_personel',
    trim(p_display_name),
    NULLIF(trim(COALESCE(p_phone, '')), ''),
    FALSE,
    v_resolved_musteri_id
  )
  ON CONFLICT (id) DO NOTHING;

  RETURN to_jsonb(v_request);
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_role_request_with_provisioning(
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  TEXT,
  UUID
) TO authenticated;

-- Unified stop resolution RPC for customer and operation order forms.
-- Handles:
-- 1) exact name+address match,
-- 2) ambiguous same-name candidates,
-- 3) explicit existing selection,
-- 4) explicit create-new.
CREATE OR REPLACE FUNCTION resolve_or_create_ugrama_for_musteri(
  p_musteri_id UUID,
  p_ugrama_adi TEXT,
  p_adres TEXT DEFAULT NULL,
  p_strategy TEXT DEFAULT 'auto',
  p_preferred_ugrama_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_role user_role;
  v_user_musteri_id UUID;
  v_norm_name TEXT;
  v_norm_address TEXT;
  v_exact_id UUID;
  v_selected_id UUID;
  v_candidate_count INTEGER;
  v_candidates JSONB;
  v_created_id UUID;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  SELECT role, musteri_id
  INTO v_role, v_user_musteri_id
  FROM app_users
  WHERE id = auth.uid();

  IF v_role IS NULL THEN
    RAISE EXCEPTION 'User profile not found';
  END IF;

  IF v_role <> 'operasyon' AND v_user_musteri_id <> p_musteri_id THEN
    RAISE EXCEPTION 'Forbidden for target musteri';
  END IF;

  v_norm_name := lower(regexp_replace(trim(COALESCE(p_ugrama_adi, '')), '\s+', ' ', 'g'));
  v_norm_address := lower(regexp_replace(trim(COALESCE(p_adres, '')), '\s+', ' ', 'g'));

  IF v_norm_name = '' THEN
    RAISE EXCEPTION 'ugrama_adi cannot be empty';
  END IF;

  IF p_strategy NOT IN ('auto', 'use_existing', 'create_new') THEN
    RAISE EXCEPTION 'Invalid strategy: %', p_strategy;
  END IF;

  IF p_strategy = 'auto' THEN
    SELECT u.id
    INTO v_exact_id
    FROM ugramalar u
    WHERE lower(regexp_replace(trim(COALESCE(u.ugrama_adi, '')), '\s+', ' ', 'g')) = v_norm_name
      AND lower(regexp_replace(trim(COALESCE(u.adres, '')), '\s+', ' ', 'g')) = v_norm_address
    ORDER BY u.created_at ASC
    LIMIT 1;

    IF v_exact_id IS NOT NULL THEN
      INSERT INTO musteri_ugrama (musteri_id, ugrama_id)
      VALUES (p_musteri_id, v_exact_id)
      ON CONFLICT (musteri_id, ugrama_id) DO NOTHING;

      RETURN jsonb_build_object(
        'resolution_type', 'existing_exact',
        'resolved_ugrama_id', v_exact_id,
        'candidates', '[]'::jsonb
      );
    END IF;

    SELECT
      COUNT(*),
      COALESCE(
        jsonb_agg(
          jsonb_build_object(
            'id', u.id,
            'ugrama_adi', u.ugrama_adi,
            'adres', u.adres
          )
          ORDER BY u.created_at DESC
        ),
        '[]'::jsonb
      )
    INTO v_candidate_count, v_candidates
    FROM ugramalar u
    WHERE lower(regexp_replace(trim(COALESCE(u.ugrama_adi, '')), '\s+', ' ', 'g')) = v_norm_name;

    IF v_candidate_count > 0 THEN
      RETURN jsonb_build_object(
        'resolution_type', 'ambiguous_name',
        'resolved_ugrama_id', NULL,
        'candidates', v_candidates
      );
    END IF;

    RETURN jsonb_build_object(
      'resolution_type', 'not_found',
      'resolved_ugrama_id', NULL,
      'candidates', '[]'::jsonb
    );
  END IF;

  IF p_strategy = 'use_existing' THEN
    IF p_preferred_ugrama_id IS NULL THEN
      RAISE EXCEPTION 'preferred_ugrama_id is required for use_existing';
    END IF;

    SELECT u.id
    INTO v_selected_id
    FROM ugramalar u
    WHERE u.id = p_preferred_ugrama_id
      AND lower(regexp_replace(trim(COALESCE(u.ugrama_adi, '')), '\s+', ' ', 'g')) = v_norm_name
    LIMIT 1;

    IF v_selected_id IS NULL THEN
      RAISE EXCEPTION 'Preferred ugrama does not match provided name';
    END IF;

    INSERT INTO musteri_ugrama (musteri_id, ugrama_id)
    VALUES (p_musteri_id, v_selected_id)
    ON CONFLICT (musteri_id, ugrama_id) DO NOTHING;

    RETURN jsonb_build_object(
      'resolution_type', 'existing_selected',
      'resolved_ugrama_id', v_selected_id,
      'candidates', '[]'::jsonb
    );
  END IF;

  INSERT INTO ugramalar (ugrama_adi, adres, is_active)
  VALUES (trim(p_ugrama_adi), NULLIF(trim(COALESCE(p_adres, '')), ''), TRUE)
  RETURNING id INTO v_created_id;

  INSERT INTO musteri_ugrama (musteri_id, ugrama_id)
  VALUES (p_musteri_id, v_created_id)
  ON CONFLICT (musteri_id, ugrama_id) DO NOTHING;

  RETURN jsonb_build_object(
    'resolution_type', 'created_new',
    'resolved_ugrama_id', v_created_id,
    'candidates', '[]'::jsonb
  );
END;
$$;

-- Atomic approve function for ugrama talebi.
-- Wraps ugrama insert + bridge insert + talep update in a single transaction.
CREATE OR REPLACE FUNCTION approve_ugrama_talebi(
  p_talep_id UUID,
  p_islem_yapan_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_talep RECORD;
  v_ugrama_id UUID;
  v_result JSON;
BEGIN
  -- 1. Lock and read talep
  SELECT * INTO v_talep
  FROM ugrama_talepleri
  WHERE id = p_talep_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Talep bulunamadı: %', p_talep_id;
  END IF;

  IF v_talep.durum <> 'beklemede' THEN
    RAISE EXCEPTION 'Talep zaten işlenmiş: %', v_talep.durum;
  END IF;

  -- 2. Insert ugrama
  INSERT INTO ugramalar (ugrama_adi, adres, is_active)
  VALUES (v_talep.ugrama_adi, v_talep.adres, TRUE)
  RETURNING id INTO v_ugrama_id;

  -- 3. Insert bridge
  INSERT INTO musteri_ugrama (musteri_id, ugrama_id)
  VALUES (v_talep.musteri_id, v_ugrama_id);

  -- 4. Update talep
  UPDATE ugrama_talepleri
  SET durum = 'onaylandi',
      islem_yapan_id = p_islem_yapan_id,
      onaylanan_ugrama_id = v_ugrama_id
  WHERE id = p_talep_id;

  -- Return updated talep as JSON
  SELECT row_to_json(t) INTO v_result
  FROM (
    SELECT * FROM ugrama_talepleri WHERE id = p_talep_id
  ) t;

  RETURN v_result;
END;
$$;

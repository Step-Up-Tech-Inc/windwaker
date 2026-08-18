-- ============================================================================
-- RATE LIMITING - TILARÁN EN LÍNEA
-- ============================================================================
-- Ventana deslizante por (acción, identificador). Cada llamada registra el
-- intento y devuelve si está permitido. Usado por:
--   * login: 5 intentos / 15 min por identificador (correo/teléfono)
--   * registro SMS: 5 / 15 min
--   * check-account (edge): 20 / 15 min por IP
--   * subir comprobante: 10 / 15 min
-- Función SECURITY DEFINER callable por anon (el login ocurre pre-sesión).
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.rate_limit_attempts (
  id BIGSERIAL PRIMARY KEY,
  action TEXT NOT NULL,
  identifier TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_rate_limit_lookup
  ON public.rate_limit_attempts (action, identifier, created_at);

ALTER TABLE public.rate_limit_attempts ENABLE ROW LEVEL SECURITY;
-- Sin políticas: nadie accede directo; solo la función SECURITY DEFINER.

CREATE OR REPLACE FUNCTION public.check_rate_limit(
  p_action TEXT,
  p_identifier TEXT,
  p_max_attempts INTEGER,
  p_window_seconds INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count INTEGER;
BEGIN
  IF p_identifier IS NULL OR length(p_identifier) = 0 THEN
    RETURN true;
  END IF;

  -- Limpieza oportunista de registros viejos (fuera de cualquier ventana)
  DELETE FROM public.rate_limit_attempts
  WHERE created_at < now() - INTERVAL '1 day';

  SELECT count(*) INTO v_count
  FROM public.rate_limit_attempts
  WHERE action = p_action
    AND identifier = p_identifier
    AND created_at > now() - make_interval(secs => p_window_seconds);

  IF v_count >= p_max_attempts THEN
    RETURN false;
  END IF;

  INSERT INTO public.rate_limit_attempts (action, identifier)
  VALUES (p_action, p_identifier);

  RETURN true;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.check_rate_limit(TEXT, TEXT, INTEGER, INTEGER)
  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.check_rate_limit(TEXT, TEXT, INTEGER, INTEGER)
  TO anon, authenticated, service_role;

NOTIFY pgrst, 'reload schema';

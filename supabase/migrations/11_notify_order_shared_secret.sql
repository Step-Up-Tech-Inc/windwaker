-- ============================================================================
-- SECRETO COMPARTIDO PARA notify-order - TILARÁN EN LÍNEA
-- ============================================================================
-- La Edge Function notify-order tiene verify_jwt=off (la invoca pg_net, no un
-- usuario). Para que NADIE más pueda dispararla, el trigger firma la llamada
-- con un secreto compartido en el header `x-notify-secret`.
--
-- El VALOR del secreto NO se versiona: se inserta fuera de git vía Management
-- API y se registra como secreto de Edge Functions (NOTIFY_SECRET). Este
-- archivo solo crea la estructura y el trigger.
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS private;

CREATE TABLE IF NOT EXISTS private.app_secrets (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

-- Solo accesible por funciones SECURITY DEFINER; nunca por clientes.
REVOKE ALL ON private.app_secrets FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.notify_order_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $fn$
DECLARE
  v_secret TEXT;
BEGIN
  IF TG_OP = 'UPDATE' AND NEW.status = OLD.status THEN
    RETURN NEW;
  END IF;

  SELECT value INTO v_secret FROM private.app_secrets WHERE key = 'notify_secret';

  PERFORM net.http_post(
    url := 'https://carvqbtjhyyhpawponaq.supabase.co/functions/v1/notify-order',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-notify-secret', COALESCE(v_secret, '')
    ),
    body := jsonb_build_object(
      'order_id', NEW.id,
      'status', NEW.status,
      'store_id', NEW.store_id,
      'customer_id', NEW.customer_id,
      'driver_id', NEW.driver_id,
      'delivery_method', NEW.delivery_method,
      'event', TG_OP
    )
  );
  RETURN NEW;
END;
$fn$;

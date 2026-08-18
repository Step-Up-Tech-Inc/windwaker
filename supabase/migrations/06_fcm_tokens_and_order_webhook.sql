-- ============================================================================
-- FASE 5: TOKENS FCM Y WEBHOOK DE PEDIDOS - TILARÁN EN LÍNEA
-- ============================================================================
-- 1) profiles.fcm_token: token de push del dispositivo del usuario.
-- 2) Trigger sobre orders que invoca (async vía pg_net) la Edge Function
--    `notify-order`, la cual decide a quién enviar la notificación.
--    pg_net encola la llamada: si la función no está desplegada, los pedidos
--    NO se ven afectados.
-- ============================================================================

ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS fcm_token TEXT;

CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION public.notify_order_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- Solo notificar en inserciones o cambios de estado reales
  IF TG_OP = 'UPDATE' AND NEW.status = OLD.status THEN
    RETURN NEW;
  END IF;

  PERFORM net.http_post(
    url := 'https://carvqbtjhyyhpawponaq.supabase.co/functions/v1/notify-order',
    headers := jsonb_build_object('Content-Type', 'application/json'),
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
$$;

DROP TRIGGER IF EXISTS on_order_change_notify ON public.orders;
CREATE TRIGGER on_order_change_notify
  AFTER INSERT OR UPDATE ON public.orders
  FOR EACH ROW
  EXECUTE FUNCTION public.notify_order_change();

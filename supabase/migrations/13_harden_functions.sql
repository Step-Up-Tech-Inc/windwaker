-- ============================================================================
-- ENDURECIMIENTO DE FUNCIONES (auditoría de seguridad) - TILARÁN EN LÍNEA
-- ============================================================================
-- 1) Fijar search_path en funciones antiguas (evita secuestro de search_path
--    en funciones SECURITY DEFINER / triggers).
-- 2) Revocar EXECUTE de la función-trigger notify_order_change: un trigger no
--    necesita ser invocable por roles de API.
-- ============================================================================

ALTER FUNCTION public.update_profiles_updated_at() SET search_path = public;
ALTER FUNCTION public.update_stores_updated_at() SET search_path = public;
ALTER FUNCTION public.update_products_updated_at() SET search_path = public;
ALTER FUNCTION public.update_inventory_updated_at() SET search_path = public;
ALTER FUNCTION public.set_updated_at() SET search_path = public;
ALTER FUNCTION public.search_stores(text) SET search_path = public;
ALTER FUNCTION public.upsert_profile(uuid, text, text) SET search_path = public;

REVOKE EXECUTE ON FUNCTION public.notify_order_change() FROM PUBLIC, anon, authenticated;

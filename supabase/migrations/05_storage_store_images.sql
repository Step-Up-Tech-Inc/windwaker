-- ============================================================================
-- FASE 3: BUCKET DE IMÁGENES DE TIENDAS/PRODUCTOS - TILARÁN EN LÍNEA
-- ============================================================================
-- Bucket público de lectura; solo usuarios autenticados pueden subir.
-- Las rutas siguen el patrón: products/<store_id>/<archivo> y
-- stores/<store_id>/<archivo>.
-- ============================================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('store-images', 'store-images', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "store_images_public_read" ON storage.objects;
CREATE POLICY "store_images_public_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'store-images');

DROP POLICY IF EXISTS "store_images_auth_write" ON storage.objects;
CREATE POLICY "store_images_auth_write" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'store-images');

DROP POLICY IF EXISTS "store_images_owner_update" ON storage.objects;
CREATE POLICY "store_images_owner_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'store-images' AND owner = auth.uid());

DROP POLICY IF EXISTS "store_images_owner_delete" ON storage.objects;
CREATE POLICY "store_images_owner_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'store-images' AND owner = auth.uid());

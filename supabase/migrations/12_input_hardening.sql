-- ============================================================================
-- SANEAMIENTO DE ENTRADAS (defensa del lado servidor) - TILARÁN EN LÍNEA
-- ============================================================================
-- Límites de longitud en campos de texto libre (rechaza payloads enormes o
-- malformados aunque el cliente los evada) y límites de tamaño/tipo en los
-- buckets de Storage (rechaza cargas demasiado grandes).
-- ============================================================================

-- ── Longitud máxima en texto libre ──────────────────────────────────────────
ALTER TABLE public.orders
  DROP CONSTRAINT IF EXISTS orders_notes_len,
  ADD CONSTRAINT orders_notes_len CHECK (notes IS NULL OR length(notes) <= 500),
  DROP CONSTRAINT IF EXISTS orders_address_detail_len,
  ADD CONSTRAINT orders_address_detail_len
    CHECK (address_detail IS NULL OR length(address_detail) <= 500),
  DROP CONSTRAINT IF EXISTS orders_payment_reference_len,
  ADD CONSTRAINT orders_payment_reference_len
    CHECK (payment_reference IS NULL OR length(payment_reference) <= 100);

ALTER TABLE public.addresses
  DROP CONSTRAINT IF EXISTS addresses_label_len,
  ADD CONSTRAINT addresses_label_len CHECK (length(label) <= 60),
  DROP CONSTRAINT IF EXISTS addresses_detail_len,
  ADD CONSTRAINT addresses_detail_len CHECK (length(detail) <= 500),
  DROP CONSTRAINT IF EXISTS addresses_reference_len,
  ADD CONSTRAINT addresses_reference_len
    CHECK (reference IS NULL OR length(reference) <= 200);

ALTER TABLE public.products
  DROP CONSTRAINT IF EXISTS products_name_len,
  ADD CONSTRAINT products_name_len CHECK (length(name) <= 120),
  DROP CONSTRAINT IF EXISTS products_description_len,
  ADD CONSTRAINT products_description_len CHECK (length(description) <= 1000);

ALTER TABLE public.stores
  DROP CONSTRAINT IF EXISTS stores_name_len,
  ADD CONSTRAINT stores_name_len CHECK (length(name) <= 120),
  DROP CONSTRAINT IF EXISTS stores_description_len,
  ADD CONSTRAINT stores_description_len CHECK (length(description) <= 1000),
  DROP CONSTRAINT IF EXISTS stores_sinpe_len,
  ADD CONSTRAINT stores_sinpe_len
    CHECK (sinpe_number IS NULL OR length(sinpe_number) <= 20);

ALTER TABLE public.support_tickets
  DROP CONSTRAINT IF EXISTS support_tickets_message_len,
  ADD CONSTRAINT support_tickets_message_len CHECK (length(message) <= 2000);

-- ── Límites en Storage: 5 MB e imágenes solamente ───────────────────────────
UPDATE storage.buckets
SET file_size_limit = 5242880,
    allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp']
WHERE id IN ('store-images', 'payment-proofs');

NOTIFY pgrst, 'reload schema';

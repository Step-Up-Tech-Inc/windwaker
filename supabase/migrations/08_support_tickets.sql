-- ============================================================================
-- SOPORTE: TABLA DE REPORTES DE PROBLEMAS - TILARÁN EN LÍNEA
-- ============================================================================
CREATE TABLE IF NOT EXISTS public.support_tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('order', 'store', 'app')),
  message TEXT NOT NULL CHECK (length(trim(message)) > 0),
  status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'resolved')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_support_tickets_user_id
  ON public.support_tickets(user_id);

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS support_tickets_insert_own ON public.support_tickets;
CREATE POLICY support_tickets_insert_own ON public.support_tickets
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS support_tickets_select_own ON public.support_tickets;
CREATE POLICY support_tickets_select_own ON public.support_tickets
  FOR SELECT USING (
    user_id = auth.uid() OR public.current_user_role() = 'admin'
  );

NOTIFY pgrst, 'reload schema';

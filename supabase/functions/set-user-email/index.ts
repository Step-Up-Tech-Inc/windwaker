// Edge Function: set-user-email
// Asigna el email al usuario autenticado vía Admin API (queda confirmado sin
// correo de verificación) SIN exponer la service_role key en la app.
// Requiere sesión: el usuario se identifica por su JWT (no se confía en un
// userId enviado por el cliente).
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey",
};

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const authHeader = req.headers.get("Authorization") ?? "";
    const token = authHeader.replace("Bearer ", "");
    if (!token) return json({ error: "No autenticado" }, 401);

    const { email } = await req.json();
    if (typeof email !== "string" || email.length > 320 || !EMAIL_RE.test(email)) {
      return json({ error: "Correo inválido" }, 400);
    }

    const admin = createClient(SUPABASE_URL, SERVICE_KEY);

    // Identificar al usuario por su JWT (no por un id del cliente)
    const { data: userData, error: userErr } = await admin.auth.getUser(token);
    if (userErr || !userData.user) {
      return json({ error: "Sesión inválida" }, 401);
    }
    const userId = userData.user.id;

    // El correo no debe pertenecer a otra cuenta
    const { data: existing } = await admin
      .from("profiles")
      .select("id")
      .eq("email", email.toLowerCase())
      .neq("id", userId)
      .limit(1);
    if ((existing ?? []).length > 0) {
      return json({ error: "Ya existe una cuenta con este correo." }, 409);
    }

    const { error: updateErr } = await admin.auth.admin.updateUserById(userId, {
      email: email.toLowerCase(),
      email_confirm: true,
    });
    if (updateErr) throw updateErr;

    return json({ ok: true });
  } catch (e) {
    console.error("set-user-email error:", e);
    return json({ error: "No se pudo actualizar el correo" }, 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

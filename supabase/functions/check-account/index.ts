// Edge Function: check-account
// Verifica si ya existe una cuenta con un teléfono o email SIN exponer la
// service_role key en la app. Se llama ANTES de autenticar (registro/login),
// por eso es pública (verify_jwt=false), pero:
//   * solo devuelve un booleano (no filtra datos del usuario),
//   * está protegida por rate limit (check_rate_limit) por IP.
import { createClient } from "npm:@supabase/supabase-js@2";

const admin = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey",
};

function clientIp(req: Request): string {
  return (
    req.headers.get("x-forwarded-for")?.split(",")[0].trim() ??
    "unknown"
  );
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  try {
    const { identifier, isEmail } = await req.json();
    if (typeof identifier !== "string" || identifier.length > 320) {
      return json({ error: "Solicitud inválida" }, 400);
    }

    // Rate limit por IP: 20 verificaciones / 15 min
    const { data: allowed } = await admin.rpc("check_rate_limit", {
      p_action: "check_account",
      p_identifier: clientIp(req),
      p_max_attempts: 20,
      p_window_seconds: 900,
    });
    if (allowed === false) {
      return json({ error: "Demasiados intentos. Espera unos minutos." }, 429);
    }

    const column = isEmail === true ? "email" : "phone";
    const { data, error } = await admin
      .from("profiles")
      .select("id")
      .eq(column, identifier)
      .limit(1);
    if (error) throw error;

    return json({ exists: (data ?? []).length > 0 });
  } catch (e) {
    console.error("check-account error:", e);
    return json({ error: "Error verificando la cuenta" }, 500);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
}

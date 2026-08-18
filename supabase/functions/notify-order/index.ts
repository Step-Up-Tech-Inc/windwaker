// Edge Function: notify-order
// Recibe el webhook del trigger de `orders` y envía push (FCM HTTP v1) a:
//   * dueño del negocio  ← pedido nuevo (INSERT, pending)
//   * repartidores       ← pedido listo para recoger (ready + delivery)
//   * cliente            ← cada cambio de estado
// Secrets requeridos: FIREBASE_SERVICE_ACCOUNT (JSON de cuenta de servicio).
// SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY los inyecta Supabase.

import { createClient } from "npm:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose@5";

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

const STATUS_LABELS: Record<string, string> = {
  pending: "Tu pedido fue recibido y espera confirmación",
  accepted: "¡Tu pedido fue confirmado!",
  preparing: "Tu pedido está en preparación",
  ready: "Tu pedido está listo",
  picked_up: "¡Tu pedido va en camino!",
  delivered: "Tu pedido fue entregado. ¡Buen provecho!",
  rejected: "El negocio no pudo aceptar tu pedido",
  cancelled: "Tu pedido fue cancelado",
};

async function fcmAccessToken(): Promise<{ token: string; projectId: string }> {
  const sa = JSON.parse(Deno.env.get("FIREBASE_SERVICE_ACCOUNT")!);
  const key = await importPKCS8(sa.private_key, "RS256");
  const jwt = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256" })
    .setIssuer(sa.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(key);

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const data = await res.json();
  return { token: data.access_token, projectId: sa.project_id };
}

async function sendPush(
  auth: { token: string; projectId: string },
  fcmToken: string,
  title: string,
  body: string,
  orderId: string,
) {
  await fetch(
    `https://fcm.googleapis.com/v1/projects/${auth.projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${auth.token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: { title, body },
          data: { order_id: orderId },
        },
      }),
    },
  );
}

async function tokensFor(userIds: string[]): Promise<string[]> {
  if (userIds.length === 0) return [];
  const { data } = await supabase
    .from("profiles")
    .select("fcm_token")
    .in("id", userIds)
    .not("fcm_token", "is", null);
  return (data ?? []).map((r) => r.fcm_token as string).filter(Boolean);
}

Deno.serve(async (req) => {
  try {
    // Solo el trigger de la BD conoce este secreto (verify_jwt está off
    // porque la llamada viene de pg_net, no de un usuario).
    const expected = Deno.env.get("NOTIFY_SECRET");
    if (expected && req.headers.get("x-notify-secret") !== expected) {
      return new Response(JSON.stringify({ ok: false }), { status: 401 });
    }

    const payload = await req.json();
    const { order_id, status, store_id, customer_id, event } = payload;

    const auth = await fcmAccessToken();
    const jobs: Promise<void>[] = [];

    // Negocio: pedido nuevo
    if (event === "INSERT" && status === "pending") {
      const { data: store } = await supabase
        .from("stores")
        .select("owner_id, name")
        .eq("id", store_id)
        .single();
      if (store?.owner_id) {
        for (const t of await tokensFor([store.owner_id])) {
          jobs.push(
            sendPush(auth, t, "🛎️ Nuevo pedido", "Tienes un pedido nuevo por confirmar.", order_id),
          );
        }
      }
    }

    // Repartidores: pedido listo para recoger (solo delivery)
    if (status === "ready" && payload.delivery_method === "delivery") {
      const { data: drivers } = await supabase
        .from("profiles")
        .select("fcm_token")
        .eq("role", "driver")
        .not("fcm_token", "is", null);
      for (const d of drivers ?? []) {
        jobs.push(
          sendPush(auth, d.fcm_token, "📦 Pedido disponible", "Hay un pedido listo para entregar.", order_id),
        );
      }
    }

    // Cliente: cambios de estado (no el insert, que él mismo hizo)
    if (event === "UPDATE" && STATUS_LABELS[status]) {
      for (const t of await tokensFor([customer_id])) {
        jobs.push(
          sendPush(auth, t, "Tilarán en Línea", STATUS_LABELS[status], order_id),
        );
      }
    }

    await Promise.allSettled(jobs);
    return new Response(JSON.stringify({ ok: true }), { status: 200 });
  } catch (e) {
    console.error("notify-order error:", e);
    return new Response(JSON.stringify({ ok: false, error: String(e) }), {
      status: 500,
    });
  }
});

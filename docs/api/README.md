# Documentación de la API — Tilarán en Línea

La API completa del marketplace está documentada en
[`openapi.yaml`](openapi.yaml) (OpenAPI 3.0 / Swagger). Cubre las cuatro
superficies de Supabase que usa la app:

| Prefijo | Servicio | Endpoints documentados |
|---------|----------|------------------------|
| `/auth/v1` | Auth (GoTrue) | OTP, verificar, login, actualizar usuario |
| `/rest/v1` | PostgREST | profiles, stores, products, inventory, orders, order_items, order_status_history, addresses, reviews, support_tickets |
| `/rest/v1/rpc` | Funciones RPC | create_order, advance_order_status, claim_order, submit_payment_proof, review_sinpe_payment, search_stores |
| `/functions/v1` | Edge Functions | check-account, set-user-email, notify-order |
| `/storage/v1` | Storage | store-images (público), payment-proofs (privado) |

## Cómo verlo con Swagger UI

- **Online**: abre <https://editor.swagger.io> → *File → Import file* →
  `openapi.yaml`. Se renderiza el Swagger interactivo con todos los endpoints
  y esquemas.
- **VS Code**: extensión "Swagger Viewer" → abre `openapi.yaml` →
  `Shift+Alt+P` → *Preview Swagger*.
- **Redoc** (documentación de lectura): `npx @redocly/cli preview-docs openapi.yaml`.

## Principios de la API (para la defensa de tesis)

1. **RLS por rol** (`customer`, `business`, `driver`, `admin`): cada tabla
   filtra sus filas según quién consulta. La `anon key` es pública por diseño;
   no otorga acceso por sí sola.
2. **Mutaciones críticas por RPC `SECURITY DEFINER`**: los precios y la máquina
   de estados de los pedidos se validan **en el servidor**, nunca se confía en
   el cliente (`create_order`, `advance_order_status`, `claim_order`).
3. **Secretos solo en el servidor**: la `service_role` key vive en Edge
   Functions, nunca en la app (ver [../security-audit.md](../security-audit.md)).
4. **Realtime** en `orders` para el seguimiento en vivo del pedido.
5. **Pagos SINPE auditables**: comprobantes en bucket privado; el negocio los
   verifica antes de poder aceptar el pedido.

## Mantenimiento

Este archivo se actualiza a mano conforme evoluciona el esquema. Tras cambiar
tablas o RPCs, actualizar la sección correspondiente en `openapi.yaml`. La
fuente de verdad del esquema son las migraciones en `supabase/migrations/`.

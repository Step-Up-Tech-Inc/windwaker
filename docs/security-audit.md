# Auditoría de Seguridad — Tilarán en Línea

_Última ejecución: fase de hardening (Fase 6)._

Resumen de la auditoría de seguridad y las medidas aplicadas. La revisión
combinó: escaneo de secretos en el código, revisión de la superficie de la API,
y los **advisors de seguridad de Supabase** (linter de base de datos).

## 1. Secretos y credenciales

| Hallazgo | Severidad | Estado |
|----------|-----------|--------|
| `service_role` key embebida en la app (`app_config.dart`) | 🔴 Crítica | **Corregido** |
| `anon` key en el cliente | Informativa | Aceptado (por diseño) |
| Firebase `apiKey` en el cliente | Informativa | Aceptado (por diseño) |
| Access token de Supabase (`sbp_…`) | — | No está en el repo ni en el frontend |

- **service_role key**: era la fuga crítica — esa llave se salta todo el RLS.
  Se **eliminó del cliente** y la lógica que la usaba (verificar si una cuenta
  existe, asignar email confirmado) se movió a Edge Functions
  (`check-account`, `set-user-email`) donde la key se inyecta como secreto del
  servidor y nunca llega al dispositivo.
- **anon key** y **Firebase apiKey**: diseñadas por sus proveedores para vivir
  en el cliente; identifican el proyecto pero no otorgan acceso por sí solas
  (los datos están protegidos por RLS / reglas). Se leen desde `--dart-define`
  en release para no fijarlas en el binario.

## 2. Rate limiting

Tabla `rate_limit_attempts` + función `check_rate_limit` (ventana deslizante):

| Acción | Límite |
|--------|--------|
| Inicio de sesión (por identificador) | **5 / 15 min** |
| SMS de registro (por teléfono) | 5 / 15 min |
| `check-account` (por IP) | 20 / 15 min |

Defensa en profundidad: además se ajustaron los rate limits nativos de
Supabase Auth (GoTrue) y la rotación de refresh tokens.

## 3. Autenticación

- Longitud mínima de contraseña: **8** caracteres.
- Caracteres requeridos: al menos una letra y un número.
- Rotación de refresh tokens activada.
- Sign-ins anónimos **deshabilitados** (la app no los usa).
- Protección de contraseñas filtradas (HaveIBeenPwned): **requiere plan Pro** —
  recomendado activar al migrar a producción de pago.

## 4. Saneamiento de entradas

- **Servidor (autoritativo)**: límites de longitud como `CHECK` en todo el
  texto libre (`orders.notes`, `addresses.detail/reference`, `products`,
  `stores`, `support_tickets`, referencia de pago).
- **Storage**: buckets `store-images` y `payment-proofs` limitados a **5 MB** y
  solo `image/jpeg|png|webp` (rechaza cargas grandes o malformadas).
- **UI**: `maxLength` en los campos de texto principales (defensa adicional).
- Todas las mutaciones de pedido pasan por RPCs `SECURITY DEFINER` que validan
  montos, propiedad y máquina de estados en el servidor.

## 5. Edge Functions

- `notify-order`: protegida con un **secreto compartido** (`x-notify-secret`).
  Solo el trigger de la base de datos lo conoce (guardado en `private.app_secrets`,
  fuera de git); cualquier POST externo se rechaza con 401.
- `check-account` / `set-user-email`: validan longitud y formato de entrada;
  `set-user-email` identifica al usuario por su JWT (no confía en un id del
  cliente).

## 6. Row Level Security

RLS habilitado en todas las tablas. Cada rol ve solo lo suyo (cliente, negocio
dueño, repartidor asignado, admin). Comprobantes de pago en bucket **privado**.
Funciones antiguas: se fijó `search_path` (evita secuestro de search_path).

## 7. Hallazgos restantes (aceptados, con justificación)

| Advisor | Por qué se acepta |
|---------|-------------------|
| `pg_graphql_*_table_exposed` (22) | Solo expone la **forma** del esquema por GraphQL; los datos siguen protegidos por RLS. La app no usa GraphQL. |
| `*_security_definer_function_executable` (11) | Son los RPCs del negocio; **deben** ser invocables por `authenticated`. Cada uno valida `auth.uid()` y permisos internamente. |
| `auth_leaked_password_protection` | Requiere plan Pro (ver §3). |
| `public_bucket_allows_listing` | `store-images` son imágenes públicas de marketing (logos/productos); su enumeración no revela datos sensibles. |
| `auth_rls_initplan`, `multiple_permissive_policies` | **Rendimiento**, no seguridad. Optimización pendiente (envolver `auth.uid()` en subconsulta). |

## Cómo re-ejecutar la auditoría

Dashboard de Supabase → **Advisors** → Security / Performance, o vía Management
API: `GET /v1/projects/{ref}/advisors/security`.

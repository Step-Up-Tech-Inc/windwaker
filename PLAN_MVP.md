# Plan MVP — Tilarán en Línea (clon de Uber Eats para Tilarán, Guanacaste)

> Objetivo: llevar la app al punto de MVP presentable como tesis — un marketplace de
> delivery funcional con tres tipos de usuario (cliente, negocio, repartidor), pedidos
> reales end-to-end sobre Supabase, y buenas prácticas de código.

---

## 1. Estado actual (diagnóstico)

### Lo que ya existe y funciona (lado cliente)
- **Auth** (en refactor activo, rama `login-fixes`): selección de método, login,
  registro, verificación OTP por teléfono, verificación por email, completar perfil.
  Tres modos de ejecución (`bypass` / `testing` / `production`).
- **Home**: lista de negocios, carrusel de categorías y promociones.
- **Búsqueda**: por nombre/categoría con RPC `search_stores`.
- **Tienda y producto**: pantalla de productos por tienda, detalle de producto.
- **Carrito**: local (SharedPreferences), selector de método de entrega, códigos de descuento (UI).
- **Checkout**: formulario de dirección, selector de método de pago — **simulado, no persiste**.
- **Tracking de pedido**: pantalla con estados — **simulado, el pedido vive solo en SharedPreferences**.
- **Perfil**: pantalla básica.

### Arquitectura existente (se mantiene)
- GetIt para DI, GoRouter + Riverpod para navegación, Bloc/Cubit + Freezed para estado
  de pantalla, patrón Repository sobre Supabase.

### Base de datos actual
`profiles` (id, email, phone), `stores`, `products`, `inventory`. RLS habilitado:
perfiles editables solo por su dueño; stores/products/inventory de lectura pública
**sin políticas de escritura** (solo se escriben desde seed).

### Brechas críticas para ser "Uber Eats"
| # | Brecha | Impacto |
|---|--------|---------|
| 1 | No existen **roles** — todo usuario es cliente | Bloquea vistas de negocio y repartidor |
| 2 | Los **pedidos no existen en la BD** — `OrderRepository` usa SharedPreferences y el tracking es una simulación con timers | El core del negocio no es real |
| 3 | `stores` **no tiene dueño** (`owner_id`) | Un negocio no puede administrar su tienda |
| 4 | No hay **direcciones de entrega** persistidas | Checkout no reutilizable |
| 5 | No hay **vista de negocio** ni **vista de repartidor** | Faltan 2 de los 3 actores |
| 6 | No hay **pagos** (ni siquiera registro del método elegido) | — |
| 7 | No hay **notificaciones push** (`firebase_messaging` está comentado en pubspec) | Negocios no se enteran de pedidos nuevos |
| 8 | No hay **realtime** — el estado del pedido no se actualiza en vivo | — |
| 9 | No hay **calificaciones/reseñas** | — |
| 10 | **Cero tests**, sin CI | Débil para defensa de tesis |
| 11 | `MigrationService` corre SQL desde el cliente al arrancar | Antipatrón — migraciones deben vivir solo en `supabase/migrations` |

---

## 2. Modelo de datos objetivo (Fase 1)

### Nuevas columnas
```sql
-- profiles: rol + datos personales
ALTER TABLE profiles ADD COLUMN role TEXT NOT NULL DEFAULT 'customer'
  CHECK (role IN ('customer', 'business', 'driver', 'admin'));
ALTER TABLE profiles ADD COLUMN full_name TEXT;
ALTER TABLE profiles ADD COLUMN avatar_url TEXT;

-- stores: dueño y ubicación
ALTER TABLE stores ADD COLUMN owner_id UUID REFERENCES profiles(id);
ALTER TABLE stores ADD COLUMN address TEXT;
ALTER TABLE stores ADD COLUMN latitude NUMERIC(10,7);
ALTER TABLE stores ADD COLUMN longitude NUMERIC(10,7);
ALTER TABLE stores ADD COLUMN phone TEXT;
ALTER TABLE stores ADD COLUMN schedule JSONB; -- horario por día
```

### Nuevas tablas
```sql
-- Direcciones de entrega del cliente
CREATE TABLE addresses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  label TEXT NOT NULL,              -- "Casa", "Trabajo"
  detail TEXT NOT NULL,             -- señas (en Tilarán no hay direcciones exactas)
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Pedidos (el corazón del MVP)
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id UUID NOT NULL REFERENCES profiles(id),
  store_id UUID NOT NULL REFERENCES stores(id),
  driver_id UUID REFERENCES profiles(id),           -- null hasta asignación
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN (
    'pending',      -- creado, esperando que el negocio acepte
    'accepted',     -- negocio aceptó
    'preparing',    -- en preparación
    'ready',        -- listo para recoger (visible a repartidores)
    'picked_up',    -- repartidor lo recogió / en camino
    'delivered',    -- entregado
    'rejected',     -- negocio rechazó
    'cancelled'     -- cliente canceló (solo en 'pending')
  )),
  delivery_method TEXT NOT NULL DEFAULT 'delivery' CHECK (delivery_method IN ('delivery','pickup')),
  payment_method TEXT NOT NULL DEFAULT 'cash' CHECK (payment_method IN ('cash','sinpe')),
  address_label TEXT,               -- snapshot de la dirección al momento del pedido
  address_detail TEXT,
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  subtotal NUMERIC(10,2) NOT NULL,
  delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 0,
  total NUMERIC(10,2) NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Líneas del pedido (snapshot de precio y nombre — el menú puede cambiar)
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  product_name TEXT NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL,
  quantity INTEGER NOT NULL,
  notes TEXT
);

-- Historial de estados (auditable, alimenta la línea de tiempo del tracking)
CREATE TABLE order_status_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  changed_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Reseñas (Fase 6)
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL UNIQUE REFERENCES orders(id),
  store_id UUID NOT NULL REFERENCES stores(id),
  customer_id UUID NOT NULL REFERENCES profiles(id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### Políticas RLS clave
- `orders` SELECT: cliente ve los suyos (`customer_id = auth.uid()`), negocio los de su
  tienda (`store_id IN (SELECT id FROM stores WHERE owner_id = auth.uid())`), repartidor
  los asignados a él **más** los que están en `ready` sin repartidor.
- `orders` INSERT: solo el propio cliente. UPDATE: transiciones válidas por rol
  (idealmente vía función `RPC advance_order_status` con `SECURITY DEFINER` que valide
  la máquina de estados — más defendible en tesis que políticas UPDATE amplias).
- `stores` / `products` / `inventory` INSERT/UPDATE/DELETE: solo `owner_id = auth.uid()`.
- `addresses` / `reviews`: CRUD solo del propio usuario.
- Habilitar **Supabase Realtime** en `orders`.

---

## 3. Fases de trabajo

### Fase 0 — Estabilizar lo actual (rama `login-fixes`) · ✅ COMPLETADA
- [x] Flujo de auth reescrito: registro = teléfono → OTP → email + contraseña;
      login = correo o teléfono + contraseña (`signInWithPassword`).
- [x] Resuelto `isProfileBasicAsync` (eliminado; el criterio único es perfil completo).
- [x] Eliminado `MigrationService` del cliente; migraciones solo en `supabase/migrations/`.
- [x] `flutter analyze` en cero; suite de tests creada (mocktail + widget tests de auth).
- [ ] Merge a `main`. A partir de aquí: una rama por fase, PRs pequeños.

### Fase 1 — Roles y fundación multi-usuario · 🔄 EN CURSO
- [x] Migración `03_roles_and_marketplace_schema.sql` **aplicada al proyecto**:
      `role` en profiles, `owner_id`/ubicación en stores, tablas `addresses`,
      `orders`, `order_items`, `order_status_history`, `reviews`, RLS por rol
      (orders sin política UPDATE: transiciones solo vía RPC de Fase 2).
- [x] Modelo `Profile` (freezed) con `UserRole`; `UserRepository.getProfile()`;
      `AuthService.getCurrentProfileTyped()` con caché + `getCurrentRole()`.
- [x] Decisión MVP: el registro siempre crea `customer`; negocio y repartidor se
      activan cambiando `profiles.role` desde el panel de Supabase.
- [x] Router: `redirect` según rol → `/home` (cliente), `/business` (negocio),
      `/driver` (repartidor), con bloqueo de secciones ajenas (`RoleNavigation`).
      Los shells de negocio/repartidor son placeholders; su contenido llega en
      Fases 3 y 4 (ahí se evaluará `StatefulShellRoute` con bottom nav).
- [ ] Onboarding de negocio: crear su `store` (nombre, categoría, logo, horario,
      tarifa y tiempo de entrega). → se hace al inicio de la Fase 3.

### Fase 2 — Pedidos reales end-to-end (cliente) · ✅ COMPLETADA
- [x] Migración `04_order_rpcs_and_realtime.sql` **aplicada**: RPCs SECURITY DEFINER
      `create_order` (precios calculados en el servidor), `advance_order_status`
      (máquina de estados validada por rol) y `claim_order` (asignación atómica de
      repartidor); Realtime habilitado en `orders`.
- [x] `OrderRepository` sobre Supabase reemplaza al de SharedPreferences: crear
      (RPC), pedido activo, historial, stream realtime por id, timeline real.
- [x] Modelos `Order`/`OrderItem` reflejan la BD (8 estados); simulación con
      timers eliminada de `OrderService`.
- [x] Checkout real: crea pedido `pending` (el servidor valida tienda abierta y
      precios); pago efectivo o SINPE Móvil (tarjeta bloqueada con mensaje).
- [x] Tracking en vivo: `OrderTrackingCubit` suscrito a Realtime; línea de
      tiempo desde `order_status_history`; cancelación vía RPC.
- [x] `AddressRepository` + modelo `Address`: el checkout carga las direcciones
      guardadas, preselecciona la default, permite elegir otra o escribir una
      nueva (con opción de guardarla), y exige dirección antes de crear el pedido.
- [x] Historial de pedidos (`/order-history`, accesible desde el perfil):
      estados con color, "Seguir pedido" para activos y "Volver a pedir" para
      finalizados (re-agrega al carrito; los precios los recalcula el servidor
      en el checkout).

### Fase 3 — Vista de negocio · 🔄 EN CURSO
- [x] **Onboarding**: si el usuario `business` no tiene tienda, formulario para
      crearla (nombre, descripción, categoría, tarifa y tiempo de entrega).
- [x] **Pedidos**: pestañas Nuevos / En curso / Historial con recarga por
      Realtime. Acciones por estado: aceptar/rechazar (pending), iniciar
      preparación, pedido listo, y "entregado al cliente" para pickup. Todas
      las transiciones pasan por el RPC `advance_order_status`.
- [x] **Abierto/cerrado**: interruptor en el AppBar (una tienda cerrada no
      puede recibir pedidos — lo valida `create_order`).
- [x] **Menú**: CRUD de productos con foto vía Supabase Storage (bucket
      `store-images`, migración 05 aplicada), disponible/agotado, borrado suave.
- [x] **Dashboard básico** (pestaña Resumen): pedidos de hoy, ingresos de hoy y
      últimos 7 días, top 5 más vendidos — solo pedidos entregados.
- [ ] **Tienda**: editar perfil del comercio y horario (hoy solo abierto/cerrado).
- [ ] Sonido/notificación local al llegar un pedido nuevo (o esperar FCM en Fase 5).
- [ ] Gestión de inventario (tabla `inventory`) — opcional para el MVP.

### Fase 4 — Vista de repartidor · ✅ COMPLETADA
Panel en `/driver` (bottom nav: Disponibles · Mi entrega · Historial):
- [x] **Disponibles**: pedidos `ready` sin repartidor, actualizados por Realtime,
      con tienda, destino y tarifa. "Tomar pedido" usa `claim_order` (asignación
      atómica: si otro ganó, aviso y la lista se refresca). Con una entrega
      activa no se puede tomar otra.
- [x] **Mi entrega**: detalle del pedido, "Ya recogí el pedido" → "Pedido
      entregado" (RPC valida las transiciones), y abrir Google Maps con
      coordenadas o señas (`url_launcher`).
- [x] **Historial**: entregas completadas con ganancias acumuladas (suma de
      tarifas de envío).
- [ ] Interruptor en línea/fuera de línea — opcional, la lista de disponibles
      ya cumple ese rol en el MVP.
- [ ] Botón "llamar al cliente" (requiere exponer el teléfono del cliente
      en el pedido — decidir en Fase 6 por privacidad).

### Fase 5 — Notificaciones y tiempo real · ✅ COMPLETADA (falta 1 paso manual)
- [x] `firebase_messaging` activo; `NotificationService` sincroniza el token FCM
      en `profiles.fcm_token` en cada inicio de sesión (y en token refresh).
- [x] Migración 06 aplicada: trigger en `orders` → webhook async (pg_net) →
      Edge Function `notify-order` (desplegada, v1 ACTIVE) que envía push:
      negocio ← pedido nuevo · cliente ← cada cambio de estado ·
      repartidores ← pedido `ready` (solo delivery).
- [x] En primer plano no se muestra push (el usuario ya ve Realtime); solo log.
- [ ] **PASO MANUAL**: crear el secret `FIREBASE_SERVICE_ACCOUNT` en Supabase
      (Edge Functions → Secrets) con el JSON de la cuenta de servicio de
      Firebase (Console → Project Settings → Service accounts → Generate key).
      Sin esto la función responde error y las push no salen (los pedidos NO
      se ven afectados: la llamada es asíncrona).
- [ ] Endurecer: la función es pública (verify_jwt=false); añadir un secreto
      compartido entre el trigger y la función en Fase 6.

### Fase 6 — Calidad y cierre para tesis · 🔄 EN CURSO
- [x] **Bug crítico de sesión**: `SecureLocalStorage` corrompía la sesión al
      persistirla (split de un JSON como si fuera token) — reescrito; la
      sesión ahora sobrevive al cierre de la app.
- [x] **Perfil 100% funcional**: Direcciones Guardadas (CRUD en `/addresses`),
      Notificaciones (toggle que limpia/sincroniza `fcm_token`), Métodos de
      Pago (preferencia efectivo/SINPE preseleccionada en el checkout) e
      Idioma (es/en con gen-l10n; perfil y navegación traducidos, el resto de
      pantallas es traducción progresiva).
- [x] **Soporte**: "Reportar un problema" funcional (tabla `support_tickets`,
      migración 08, RLS propia + lectura admin); chat y llamada quedan como
      "próximamente" a propósito.
- [x] **Completar perfil con Google**: botón que rellena el email desde la
      cuenta Google (solo lectura del correo; el flujo sigue siendo teléfono
      verificado + contraseña).
- [x] Swagger/OpenAPI curado en `docs/api/openapi.yaml` + guía en README.
- [x] Limpieza: eliminados `test_store_screen.dart`, `SOLUTION_SUMMARY.md`
      (obsoleto), `analyze.txt`; mensajes informativos de `/auth` removidos.
- [x] **Auditoría de ciberseguridad** (reporte en `docs/security-audit.md`):
  - [x] service_role key eliminada del cliente → Edge Functions `check-account`
        y `set-user-email` (la key vive solo en el servidor).
  - [x] Rate limiting: login 5/15min, registro SMS 5/15min, check-account
        20/15min (tabla + RPC `check_rate_limit`).
  - [x] Escaneo de secretos: solo quedan anon key y Firebase apiKey (públicas
        por diseño); nada crítico en git/frontend.
  - [x] Saneamiento: CHECK de longitud en servidor, buckets a 5MB solo imágenes,
        maxLength en UI.
  - [x] Auth endurecido: contraseña ≥8 con letra+número, rotación de tokens,
        sign-ins anónimos off. (HIBP filtradas requiere plan Pro.)
  - [x] `notify-order` protegida con secreto compartido; search_path fijado en
        funciones antiguas. Advisors: 55 → 35 warnings (resto por diseño/perf/Pro).
- [x] **Aprobación de tiendas** (migración 07 aplicada): las tiendas nacen
      `pending`; los clientes no las ven (RLS + `search_stores`) ni pueden
      pedirles (`create_order` las rechaza). El panel del negocio muestra un
      aviso "en revisión" (puede preparar su menú mientras tanto). El admin
      aprueba cambiando `stores.status` a `approved` (Table Editor o, a
      futuro, consola admin in-app — el RLS ya permite al rol `admin`
      actualizar cualquier tienda).

- [ ] **Reseñas**: al entregarse, el cliente califica (1–5 + comentario); recalcular
      `stores.rating` con trigger.
- [ ] **Tests**: unit tests de cubits (checkout, pedidos negocio, tracking) y de la
      máquina de estados del pedido; widget tests de pantallas clave; mocks de
      repositorios (`mocktail`). Meta razonable: cubrir la lógica de dominio, no el 100%.
- [ ] **CI**: GitHub Actions con `flutter analyze` + `flutter test` en cada PR.
- [x] **Hardening de ciberseguridad** (auditoría completa, ver `docs/security-audit.md`):
      - service_role key ELIMINADA del cliente → movida a Edge Functions
        `check-account` y `set-user-email` (la key vive solo en el servidor).
      - Rate limiting: login 5/15min, registro SMS 5/15min, check-account 20/15min
        (tabla `rate_limit_attempts` + RPC `check_rate_limit`, migración 10).
      - `notify-order` protegida con secreto compartido `x-notify-secret`
        (migración 11; valor en `private.app_secrets`, fuera de git).
      - Saneamiento: CHECK de longitud en texto libre + buckets 5MB/solo imágenes
        (migración 12); `maxLength` en formularios; `search_path` fijado (migración 13).
      - Auth: min 8 chars, letra+número, rotación de tokens, anónimos deshabilitados.
      - Advisors de seguridad: de 55 → 35 warnings; los restantes son por diseño
        (RPCs), rendimiento, o plan Pro (HIBP). Reporte en `docs/security-audit.md`.
- [ ] **Docs**: actualizar CLAUDE.md/README, diagrama de arquitectura y ER para la
      memoria de tesis.
- [ ] Modo `production` verificado, seed de demo realista (5–8 negocios de Tilarán),
      guion de demo con 3 dispositivos/emuladores (cliente, negocio, repartidor).

---

## 4. Fuera del alcance del MVP (decir "no" explícitamente)
- Pasarela de pagos con tarjeta (efectivo + SINPE Móvil bastan para Tilarán).
- Tracking GPS en vivo del repartidor sobre mapa (solo estados discretos).
- Chat en la app (se sustituye con botón de llamada).
- Panel web de administración (se usa el dashboard de Supabase).
- Cupones/promociones reales, propinas, programación de pedidos, multi-idioma.

Cada uno de estos es un buen apartado de "trabajo futuro" en la tesis.

## 5. Buenas prácticas transversales
- Una rama y PR por fase/feature; commits pequeños.
- Toda mutación de pedido pasa por RPCs que validan la máquina de estados en el
  servidor — nunca confiar en el cliente.
- Estados de UI con Freezed sealed unions (`initial/loading/loaded/error`) como ya se
  hace en `HomeCubit`; repos detrás de interfaces registradas en GetIt.
- Snapshots inmutables en pedidos (nombre/precio copiados a `order_items`).
- Nunca editar `.freezed.dart`/`.g.dart`; correr `build_runner` tras tocar modelos.
- Secretos fuera del repo; verificar `AppMode.production` antes de builds de release.

## 6. Estimación total
| Fase | Duración |
|------|----------|
| 0 — Estabilización | 1 sem |
| 1 — Roles + BD | 1–2 sem |
| 2 — Pedidos reales | 2 sem |
| 3 — Vista negocio | 2 sem |
| 4 — Vista repartidor | 1–2 sem |
| 5 — Notificaciones | 1 sem |
| 6 — Calidad + cierre | 2 sem |
| **Total** | **~10–12 semanas** |

Orden recomendado estricto: 0 → 1 → 2 → 3 → 4 → 5 → 6. Las fases 2–4 son el corazón
demostrable de la tesis; si el tiempo aprieta, la Fase 5 (push) puede degradarse a
solo realtime in-app y la Fase 6 reducirse a tests de la lógica de pedidos.

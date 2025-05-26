# Instrucciones para la Migración y Consolidación de la Base de Datos

Este directorio contiene scripts SQL de migración para la aplicación. La migración más reciente (20240615_consolidate_database.sql) es especialmente importante ya que consolida las diferentes tablas y esquemas en una estructura unificada.

## Problema

La aplicación tenía problemas debido a que se utilizaban múltiples esquemas (public y marketplace) y tablas duplicadas (negocios/stores, products/inventory). Esto causaba inconsistencias y dificultades al consultar los datos.

## Solución

El script de migración `20240615_consolidate_database.sql` consolida todo en el esquema público (public) de la siguiente manera:

1. Unifica las tablas `stores` y `negocios` en una sola tabla `stores` en el esquema `public`
2. Migra todos los productos e inventario al esquema `public`
3. Asegura que los IDs de las tiendas principales sean consistentes
4. Crea una función para búsqueda de tiendas en el esquema público

## Cómo ejecutar la migración

Puedes ejecutar el script de migración de varias formas:

### Usando la interfaz de Supabase

1. Accede a la consola de administración de Supabase
2. Ve a la sección "SQL Editor"
3. Copia y pega el contenido del archivo `20240615_consolidate_database.sql`
4. Ejecuta el script

### Usando la CLI de Supabase

Si tienes configurada la CLI de Supabase, puedes ejecutar:

```bash
supabase db push
```

Esto aplicará todas las migraciones pendientes a tu base de datos.

## Estructura de la base de datos después de la migración

Después de ejecutar la migración, la estructura de la base de datos será la siguiente:

### Tabla `stores` (public)
- `id`: UUID (primary key)
- `name`: TEXT
- `description`: TEXT
- `image_url`: TEXT
- `category`: TEXT
- `rating`: NUMERIC(3,1)
- `delivery_time_minutes`: INTEGER
- `delivery_fee`: NUMERIC(7,2)
- `is_open`: BOOLEAN
- `is_featured`: BOOLEAN
- `ciudad`: TEXT
- `owner_id`: UUID
- `created_at`: TIMESTAMPTZ
- `updated_at`: TIMESTAMPTZ
- `is_deleted`: BOOLEAN

### Tabla `products` (public)
- `id`: UUID (primary key)
- `name`: TEXT
- `description`: TEXT
- `image_url`: TEXT
- `category`: TEXT
- `price`: DECIMAL(10,2)
- `unit`: TEXT
- `quantity`: DECIMAL(10,2)
- `store_id`: UUID (referencia a `stores`)
- `status`: SMALLINT
- `created_at`: TIMESTAMPTZ
- `updated_at`: TIMESTAMPTZ
- `is_deleted`: BOOLEAN

### Tabla `inventory` (public)
- `id`: UUID (primary key)
- `store_id`: UUID (referencia a `stores`)
- `product_id`: UUID (referencia a `products`)
- `current_stock`: DECIMAL(10,2)
- `min_stock`: DECIMAL(10,2)
- `max_stock`: DECIMAL(10,2)
- `created_at`: TIMESTAMPTZ
- `updated_at`: TIMESTAMPTZ
- `is_deleted`: BOOLEAN

## Tiendas principales

El script asegura que siempre existan las siguientes tiendas principales con sus respectivos IDs:

1. Restaurante El Buen Sabor (ID: 00000000-0000-0000-0000-000000000001)
2. Farmacia Santa María (ID: 00000000-0000-0000-0000-000000000002)
3. Supermercado La Esquina (ID: 00000000-0000-0000-0000-000000000003)

Estas tiendas son importantes para la funcionalidad principal de la aplicación. 
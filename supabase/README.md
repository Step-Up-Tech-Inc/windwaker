# Configuración de Supabase

Este directorio contiene las migraciones y configuraciones necesarias para Supabase.

## Configuración de la Base de Datos

### 1. Estructura de la Tabla de Tiendas

La aplicación requiere una tabla `stores` con la siguiente estructura:

```sql
CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL,
  category TEXT NOT NULL,
  rating NUMERIC(3,1) NOT NULL DEFAULT 0.0,
  delivery_time_minutes INTEGER NOT NULL DEFAULT 30,
  delivery_fee NUMERIC(5,2) NOT NULL DEFAULT 0.00,
  is_open BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

### 2. Función de Búsqueda

Para habilitar la búsqueda de tiendas, debes crear la siguiente función SQL:

```sql
CREATE OR REPLACE FUNCTION search_stores(search_query TEXT)
RETURNS SETOF stores AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM stores
  WHERE
    name ILIKE '%' || search_query || '%'
    OR description ILIKE '%' || search_query || '%'
    OR category ILIKE '%' || search_query || '%'
  ORDER BY
    CASE WHEN name ILIKE '%' || search_query || '%' THEN 0 ELSE 1 END,
    CASE WHEN category ILIKE '%' || search_query || '%' THEN 0 ELSE 1 END,
    CASE WHEN description ILIKE '%' || search_query || '%' THEN 0 ELSE 1 END,
    name;
END;
$$ LANGUAGE plpgsql;
```

## Datos de Ejemplo

Puedes insertar algunas tiendas de ejemplo con el siguiente SQL:

```sql
INSERT INTO stores (name, description, image_url, category, rating, delivery_time_minutes, delivery_fee, is_open)
VALUES
  ('Restaurante El Sabor', 'Comida tradicional con el mejor sabor', 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4', 'Restaurante', 4.7, 30, 2.5, true),
  ('Farmacia Salud', 'Tu salud es nuestra prioridad', 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de', 'Farmacia', 4.5, 20, 1.5, true),
  ('Supermercado Express', 'Todo lo que necesitas en un solo lugar', 'https://images.unsplash.com/photo-1601598851547-4302969d0614', 'Supermercado', 4.3, 40, 3.0, true),
  ('Café Aroma', 'El mejor café de la ciudad', 'https://images.unsplash.com/photo-1554118811-1e0d58224f24', 'Café', 4.8, 25, 2.0, true),
  ('Tienda de Mascotas Patitas', 'Todo para tu mascota', 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee', 'Mascotas', 4.6, 35, 2.8, false);
```

## Políticas de Seguridad

Las políticas de seguridad están configuradas para permitir que todos los usuarios puedan leer los datos de las tiendas, pero solo los administradores pueden crear, actualizar o eliminar tiendas.

```sql
-- Permitir lectura para todos
CREATE POLICY "Permitir lectura a todos" ON stores
  FOR SELECT USING (true);

-- Permitir inserción solo a administradores
CREATE POLICY "Permitir inserción a admins" ON stores
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() IN (SELECT id FROM users WHERE is_admin = true));

-- Permitir actualización solo a administradores
CREATE POLICY "Permitir actualización a admins" ON stores
  FOR UPDATE TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE is_admin = true));

-- Permitir eliminación solo a administradores
CREATE POLICY "Permitir eliminación a admins" ON stores
  FOR DELETE TO authenticated
  USING (auth.uid() IN (SELECT id FROM users WHERE is_admin = true));
```

## Aplicar Migraciones

Para aplicar estas migraciones:

1. Ve al panel de administración de Supabase
2. Navega a la sección "SQL Editor"
3. Copia y ejecuta los scripts de migración en el siguiente orden:
   - `migrations/20230801000001_stores_table.sql`
   - `migrations/20230801000000_stores_search_function.sql`

# Scripts de Migración para Consolidar la Base de Datos

Este directorio contiene scripts SQL para consolidar las tablas duplicadas en la base de datos, migrando todo al esquema `public`.

## Problema

Actualmente la base de datos tiene tablas duplicadas en diferentes esquemas:
- `public.stores` y `marketplace.stores`
- `public.products` y `marketplace.products`
- `public.inventory` y `marketplace.inventory`
- `public.negocios` (tabla duplicada de stores)

Esto causa inconsistencias y errores en la aplicación.

## Solución

Los scripts migran todos los datos al esquema `public` y eliminan las tablas duplicadas.

## Instrucciones de Ejecución

Ejecuta los scripts en el siguiente orden:

1. **Preparación y Consolidación**
   ```bash
   supabase db reset # Solo si quieres resetear la base de datos (CUIDADO: borra todos los datos)
   # O si prefieres mantener los datos:
   psql -h localhost -p 54322 -U postgres -d postgres -f supabase/migrations/20240615_simple_consolidate.sql
   ```

2. **Migración de Datos**
   ```bash
   psql -h localhost -p 54322 -U postgres -d postgres -f supabase/migrations/20240615_migrate_data.sql
   ```

3. **Verificación**
   - Verifica manualmente que los datos se hayan migrado correctamente
   - Puedes usar consultas como:
     ```sql
     SELECT COUNT(*) FROM public.stores;
     SELECT COUNT(*) FROM marketplace.stores;
     ```

4. **Limpieza**
   ```bash
   psql -h localhost -p 54322 -U postgres -d postgres -f supabase/migrations/20240615_cleanup.sql
   ```

## Diagnóstico

Si necesitas diagnosticar la estructura de la base de datos, puedes ejecutar:

```bash
psql -h localhost -p 54322 -U postgres -d postgres -f supabase/diagnose_database.sql
```

## Recomendaciones para el Futuro

1. Mantén todas las tablas en un solo esquema (`public`) para evitar duplicidad.
2. Usa la convención de nombres en inglés para todas las tablas.
3. Implementa migraciones utilizando el sistema de Supabase para mantener la consistencia.
4. Asegúrate de que todas las tablas tengan campos consistentes como `created_at`, `updated_at` e `is_deleted`. 
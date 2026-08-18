# Configuración de Supabase - Tilarán en Línea

Este directorio contiene las migraciones SQL necesarias para configurar completamente la base de datos de Supabase.

## 📋 Requisitos Previos

1. Tener una cuenta en [Supabase](https://supabase.com)
2. Crear un nuevo proyecto en Supabase
3. Obtener las credenciales del proyecto (URL y Anon Key)

## 🚀 Instrucciones de Configuración

### Paso 1: Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com) e inicia sesión
2. Haz clic en "New Project"
3. Completa la información:
   - **Name**: Tilaran en Linea (o el nombre que prefieras)
   - **Database Password**: Elige una contraseña segura
   - **Region**: Selecciona la región más cercana
4. Haz clic en "Create new project" y espera a que se complete la creación

### Paso 2: Obtener Credenciales

1. Una vez creado el proyecto, ve a **Project Settings** (ícono de engranaje en el menú lateral)
2. Selecciona **API** en el menú de configuración
3. Copia los siguientes valores:
   - **URL**: Algo como `https://xxxxxxxxxxxxx.supabase.co`
   - **anon/public key**: Un token JWT largo

### Paso 3: Actualizar Configuración en la App

Abre el archivo `lib/core/config/app_config.dart` y actualiza las siguientes líneas con tus credenciales:

```dart
static const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'TU_URL_AQUI', // Reemplaza con tu URL
);

static const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'TU_ANON_KEY_AQUI', // Reemplaza con tu Anon Key
);
```

### Paso 4: Ejecutar Scripts SQL

Ve al **SQL Editor** en Supabase y ejecuta los scripts en el siguiente orden:

#### 4.1. Ejecutar Script de Configuración de Base de Datos

1. En el SQL Editor, haz clic en "New query"
2. Abre el archivo `supabase/migrations/01_complete_database_setup.sql`
3. Copia todo el contenido y pégalo en el editor SQL
4. Haz clic en "Run" para ejecutar el script
5. Verifica que no haya errores (deberías ver "Success. No rows returned")

Este script crea:
- ✅ Tabla `profiles` para usuarios
- ✅ Tabla `stores` para tiendas
- ✅ Tabla `products` para productos
- ✅ Tabla `inventory` para control de stock
- ✅ Índices para mejorar rendimiento
- ✅ Funciones SQL (`search_stores`, `upsert_profile`)
- ✅ Triggers para actualización automática de timestamps
- ✅ Políticas de seguridad (RLS)

#### 4.2. Ejecutar Script de Datos Iniciales

1. En el SQL Editor, crea una nueva query
2. Abre el archivo `supabase/migrations/02_seed_stores_and_products.sql`
3. Copia todo el contenido y pégalo en el editor SQL
4. Haz clic en "Run" para ejecutar el script
5. Verifica que no haya errores

Este script inserta:
- ✅ 8 tiendas (3 supermercados, 1 farmacia, 1 tienda de mascotas, 3 restaurantes)
- ✅ Más de 150 productos distribuidos entre las tiendas
- ✅ Inventario inicial para todos los productos

### Paso 5: Verificar la Instalación

Ejecuta las siguientes consultas en el SQL Editor para verificar que todo se creó correctamente:

```sql
-- Verificar tiendas (debe retornar 8)
SELECT COUNT(*) as total_stores FROM stores;

-- Ver todas las tiendas
SELECT name, category, rating FROM stores ORDER BY category, name;

-- Verificar productos (debe retornar más de 150)
SELECT COUNT(*) as total_products FROM products;

-- Ver productos por tienda
SELECT s.name as store_name, COUNT(p.id) as product_count
FROM stores s
LEFT JOIN products p ON s.id = p.store_id
GROUP BY s.name
ORDER BY s.name;
```

## 📊 Estructura de las Tiendas

Las 8 tiendas creadas son:

1. **Mega Super Tilarán** (Supermercado) - 20 productos
2. **Pali Tilarán** (Supermercado) - 15 productos
3. **Compre Bien** (Supermercado) - 15 productos
4. **Farmacia Vida Sana** (Farmacia) - 18 productos
5. **Patitas Felices** (Mascotas) - 16 productos
6. **Sabor Tico** (Restaurante) - 16 productos
7. **Pizza Express** (Restaurante) - 17 productos
8. **Cafetería Aroma** (Cafetería) - 18 productos

## 🔧 Solución de Problemas

### Error: "relation does not exist"

Si ves este error, asegúrate de haber ejecutado primero el script `01_complete_database_setup.sql` antes de `02_seed_stores_and_products.sql`.

### Error: "duplicate key value violates unique constraint"

Si ves este error al ejecutar el script de datos, significa que ya existen datos en las tablas. Puedes:

1. Eliminar los datos existentes:
```sql
DELETE FROM inventory;
DELETE FROM products;
DELETE FROM stores;
```

2. Volver a ejecutar `02_seed_stores_and_products.sql`

### Las imágenes no se cargan en la app

Las URLs de imágenes usan Unsplash, que es un servicio gratuito. Si algunas imágenes no cargan, es normal. Puedes reemplazar las URLs con tus propias imágenes si lo deseas.

## 📱 Probar la Aplicación

Una vez completados todos los pasos:

1. Abre el proyecto Flutter
2. Ejecuta:
```bash
flutter pub get
flutter run
```

3. La app debería conectarse a Supabase y mostrar las 8 tiendas
4. Puedes navegar a cada tienda y ver sus productos

## 🔄 Resetear la Base de Datos

Si necesitas empezar de cero:

```sql
-- CUIDADO: Esto eliminará TODOS los datos
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS stores CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP FUNCTION IF EXISTS search_stores CASCADE;
DROP FUNCTION IF EXISTS upsert_profile CASCADE;
```

Luego vuelve a ejecutar los scripts en orden.

## 📝 Notas Importantes

- Las políticas RLS están configuradas para permitir lectura pública de tiendas y productos
- Los usuarios solo pueden modificar su propio perfil
- Todos los productos tienen un inventario inicial de 50 unidades
- Las tiendas destacadas (`is_featured = true`) son: Mega Super, Farmacia Vida Sana y Sabor Tico
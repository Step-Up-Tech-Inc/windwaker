# Tilarán en Línea (Proyecto WindWaker)

Marketplace móvil para promover la economía local de Tilarán, Guanacaste, Costa Rica.

## Descripción

Tilarán en Línea es una aplicación móvil diseñada para conectar a compradores y vendedores locales en la región de Tilarán, Guanacaste. La aplicación facilita el comercio local y fortalece la economía de la comunidad.

## Requisitos Técnicos

- Flutter SDK: ^3.7.2
- Dart SDK: ^3.7.2
- iOS 11.0 o superior
- Android 5.0 (API 21) o superior

## Configuración del Proyecto

1. Clonar el repositorio:
```bash
git clone <url-del-repositorio>
cd windwaker
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Configurar Firebase:
   - Crear un proyecto en Firebase Console
   - Agregar aplicación iOS con bundle ID: `dev.stepup.windwaker`
   - Agregar aplicación Android con package name: `dev.stepup.windwaker`
   - Descargar y agregar los archivos de configuración:
     - iOS: `ios/Runner/GoogleService-Info.plist`
     - Android: `android/app/google-services.json`

4. Configurar Supabase:
   - Crear proyecto en Supabase
   - Actualizar las variables de entorno en `lib/core/config/app_config.dart`

5. Ejecutar la aplicación:
```bash
flutter run
```

## Estructura del Proyecto

```
lib/
├── core/
│   ├── config/       # Configuraciones de la aplicación
│   ├── errors/       # Manejo de errores
│   ├── network/      # Configuración de red
│   ├── storage/      # Almacenamiento local
│   ├── theme/        # Temas de la aplicación
│   └── utils/        # Utilidades generales
├── features/
│   └── auth/         # Autenticación
├── shared/
│   ├── widgets/      # Widgets compartidos
│   ├── models/       # Modelos de datos
│   └── services/     # Servicios compartidos
└── main.dart         # Punto de entrada de la aplicación
```

## Características Principales

- Autenticación de usuarios
- Listado de productos y servicios
- Búsqueda y filtrado
- Chat entre usuarios
- Sistema de valoraciones
- Notificaciones push
- Modo offline

## Tecnologías Utilizadas

- Flutter & Dart
- Firebase (Analytics, Crashlytics, Cloud Messaging)
- Supabase (Base de datos, Autenticación)
- BLoC (Gestión de estado)
- Clean Architecture
- Material Design 3

## Contribución

1. Crear un branch: `git checkout -b feature/nueva-caracteristica`
2. Commit de cambios: `git commit -m 'Agregar nueva caracteristica'`
3. Push al branch: `git push origin feature/nueva-caracteristica`
4. Crear Pull Request

## Licencia

Este proyecto está bajo la licencia [MIT](LICENSE).

## Configuración de Supabase

### Creación de la tabla de negocios

Para crear la tabla de negocios en Supabase, sigue estos pasos:

1. Inicia sesión en tu cuenta de Supabase y selecciona tu proyecto.
2. Ve a la sección "SQL Editor" en el panel lateral.
3. Crea un nuevo script SQL.
4. Copia y pega el contenido del archivo `supabase/migrations/20240523_create_negocios_table.sql`.
5. Ejecuta el script haciendo clic en "Run".

El script creará:
- La tabla `negocios` con todos los campos necesarios.
- Índices para mejorar el rendimiento.
- Un trigger para actualizar automáticamente el campo `updated_at`.
- Dos registros de ejemplo para probar la aplicación.
- Políticas de seguridad (RLS) para controlar el acceso a los datos.

### Conexión con la aplicación

La aplicación ya está configurada para conectarse a Supabase. Los detalles de conexión se encuentran en `lib/core/config/app_config.dart`.

## Desarrollo

### Ejecutar la aplicación

```bash
flutter pub get
flutter run
```

### Regenerar código generado

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

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

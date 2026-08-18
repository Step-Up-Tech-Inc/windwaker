# Configuración de Modos de la Aplicación

## Resumen

La aplicación ahora soporta tres modos de operación que facilitan el desarrollo, testing y despliegue a producción:

## 🔧 Modos Disponibles

### 1. **Modo Bypass** (`AppMode.bypass`)
- **Propósito**: Desarrollo rápido sin complicaciones
- **Autenticación**: Código fijo `000000` + usuario temporal en Supabase
- **Base de datos**: Solo tabla `profiles` de Supabase
- **Logging**: Habilitado y detallado
- **UI**: Muestra información de debug

### 2. **Modo Testing** (`AppMode.testing`)
- **Propósito**: Testing completo que simula producción
- **Autenticación**: Código fijo `123456` + crea usuarios reales en Supabase
- **Base de datos**: Tabla `profiles` + autenticación real de Supabase
- **Logging**: Habilitado para debugging
- **UI**: Muestra información de debug

### 3. **Modo Production** (`AppMode.production`)
- **Propósito**: Aplicación en producción
- **Autenticación**: SMS real de Supabase
- **Base de datos**: Funcionalidad completa
- **Logging**: Mínimo (solo errores)
- **UI**: Sin información de debug

## 🚀 Cómo Cambiar de Modo

### Método 1: Archivo de Configuración (Recomendado)

Edita `lib/core/config/environment.dart` línea 6:

```dart
class Environment {
  // CAMBIAR ESTE VALOR PARA ALTERNAR ENTRE MODOS
  static const AppMode _currentMode = AppMode.bypass;    // ← DESARROLLO
  //static const AppMode _currentMode = AppMode.testing;  // ← TESTING
  //static const AppMode _currentMode = AppMode.production; // ← PRODUCCIÓN
}
```

### Método 2: Variables de Entorno

Ejecuta la app con variables de entorno:

```bash
# Modo bypass (por defecto)
flutter run

# Modo testing
flutter run --dart-define=APP_MODE=testing

# Modo production
flutter run --dart-define=APP_MODE=production
```

### Método 3: Compilación para Producción

Para producción, simplemente compila en modo release:

```bash
flutter build apk --release
# o
flutter build ios --release
```

El modo se detecta automáticamente usando `kDebugMode`.

## 📱 Experiencia de Usuario por Modo

### Modo Bypass
1. Abrir app → Ver banner naranja "BYPASS"
2. Ir a autenticación → Código `000000` mostrado
3. Ingresar cualquier teléfono + `000000`
4. Se crea usuario temporal en Supabase
5. Completar perfil → Navegar normalmente

### Modo Testing
1. Abrir app → Ver banner azul "TESTING"
2. Ir a autenticación → Código `123456` mostrado
3. Ingresar teléfono + `123456`
4. Se crea usuario real en Supabase Auth
5. Completar perfil → Funcionalidad completa

### Modo Production
1. Abrir app → Sin banners de debug
2. Ir a autenticación → Sin códigos mostrados
3. Ingresar teléfono → SMS real enviado
4. Completar flujo normal de producción

## 🔍 Características por Modo

| Característica | Bypass | Testing | Production |
|---|---|---|---|
| **Código SMS** | `000000` | `123456` | SMS real |
| **Supabase Auth** | ✅ (temporal) | ✅ (real) | ✅ (real) |
| **Tabla profiles** | ✅ | ✅ | ✅ |
| **SharedPreferences** | ❌ | ❌ | ❌ |
| **Logging detallado** | ✅ | ✅ | ❌ |
| **UI de debug** | ✅ | ✅ | ❌ |
| **Firebase Crashlytics** | ❌ | ❌ | ✅ |
| **Duplicados prevención** | ✅ | ✅ | ✅ |

## 🛠️ Desarrollo

### Para desarrollo diario:
```dart
static const AppMode _currentMode = AppMode.bypass;
```

### Para testing antes de release:
```dart
static const AppMode _currentMode = AppMode.testing;
```

### Para compilar release:
```dart
static const AppMode _currentMode = AppMode.production;
// o dejar que se detecte automáticamente
```

## 🐛 Debugging

### Ver logs del modo actual:
Los logs aparecen en la consola cuando `AppConfig.logAuthFlow` es `true`:

```
=== VERIFICACIÓN DE AUTENTICACIÓN ===
Modo: Desarrollo - Bypass sin Supabase Auth
Usuario Supabase: 12345-67890-abcdef
Perfil encontrado: true
```

### Limpiar datos para testing:
En modo bypass y testing, hay un botón "Limpiar datos" que:
- Cierra sesión de Supabase Auth
- Elimina usuario temporal (si aplica)
- Regresa a pantalla inicial

## ⚠️ Importantes

1. **Siempre verifica el modo** antes de hacer commits
2. **Para releases**, usar `AppMode.production` o compilación release
3. **Los códigos bypass** aparecen visualmente en desarrollo para facilidad
4. **Solo Supabase** - Se eliminó SharedPreferences para simplicidad
5. **La tabla `profiles`** es la única fuente de verdad

## 📋 Checklist de Release

- [ ] Cambiar a `AppMode.production` en `environment.dart`
- [ ] Verificar que `kDebugMode = false` en builds release
- [ ] Confirmar URLs de Supabase para producción
- [ ] Testear flujo completo en modo testing primero
- [ ] Compilar en modo release
- [ ] Verificar que no aparecen banners de debug

## 🆘 Troubleshooting

### Problema: "Usuario ya existe" en modo testing
**Solución**: Eliminar usuario de Supabase Auth Dashboard o usar teléfono diferente

### Problema: Códigos no funcionan
**Solución**: Verificar que estás en el modo correcto y usando el código correcto

### Problema: No detecta perfiles existentes
**Solución**: Verificar que el perfil se guardó en la tabla `profiles` de Supabase

### Problema: Logs no aparecen
**Solución**: Verificar que `AppConfig.enableDetailedLogging` es `true` para tu modo

### Problema: "No hay usuario autenticado"
**Solución**: El usuario debe autenticarse primero a través del flujo SMS/bypass 
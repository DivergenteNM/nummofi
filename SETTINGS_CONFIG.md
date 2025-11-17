# Sistema de Configuración - NummoFi

## 📋 Descripción

Se ha implementado un sistema completo de configuración de usuario que permite personalizar:

- **Tema de la aplicación**: Modo claro, modo oscuro, o predeterminado del sistema
- **Idioma**: Español o Inglés

## 🎯 Características

### 1. Persistencia de Configuración
- Las preferencias del usuario se guardan localmente usando `SharedPreferences`
- La configuración se mantiene incluso después de cerrar la aplicación
- Carga automática al iniciar la app

### 2. Botón de Configuración
- **Ubicación**: Esquina superior derecha del AppBar
- **Diseño**: Solo icono de engranaje (⚙️), sin texto
- **Interacción**: Menú desplegable al hacer clic

### 3. Menú de Opciones

#### Apariencia
- ☀️ **Modo Claro**: Tema claro para entornos iluminados
- 🌙 **Modo Oscuro**: Tema oscuro para reducir fatiga visual
- 🔄 **Predeterminado del Sistema**: Se adapta automáticamente a la configuración del dispositivo

#### Idioma
- 🇪🇸 **Español**: Interfaz completa en español
- 🇬🇧 **English**: Complete interface in English

## 🏗️ Arquitectura

### Archivos Creados/Modificados

1. **`lib/core/providers/settings_provider.dart`**
   - Provider para gestionar configuraciones
   - Métodos para cambiar tema e idioma
   - Persistencia con SharedPreferences

2. **`lib/screens/home_screen.dart`**
   - Agregado botón de configuración en AppBar
   - Implementado menú desplegable con opciones
   - Feedback visual con checkmarks en opción activa

3. **`lib/main.dart`**
   - Inicialización de SettingsProvider antes de la app
   - Configuración de tema dinámico basado en preferencias
   - Configuración de idioma dinámico basado en preferencias

4. **`lib/l10n/app_es.arb` y `lib/l10n/app_en.arb`**
   - Agregadas 10 nuevas traducciones:
     - settings, appearance, language
     - lightMode, darkMode, systemMode
     - spanish, english
     - themeChanged, languageChanged

5. **`pubspec.yaml`**
   - Agregada dependencia: `shared_preferences: ^2.3.3`

## 🎨 Diseño UI/UX

### Menú de Configuración
- **Estructura limpia**: Títulos en negrita para separar secciones
- **Indicadores visuales**: 
  - Color azul (AppColors.info) para opción seleccionada
  - Checkmark (✓) junto a la opción activa
- **Iconos descriptivos**:
  - ☀️ Modo claro
  - 🌙 Modo oscuro
  - 🔄 Modo sistema
  - 🌐 Idioma

### Feedback al Usuario
- **SnackBar**: Mensaje de confirmación al cambiar configuración
- **Duración**: 2 segundos
- **Estilo**: Floating SnackBar para no obstruir contenido

## 🔧 Uso

### Para el Usuario
1. Abre la aplicación
2. Toca el icono de engranaje (⚙️) en la esquina superior derecha
3. Selecciona tu preferencia de tema o idioma
4. Los cambios se aplican inmediatamente
5. La configuración se guarda automáticamente

### Para el Desarrollador

#### Acceder al Provider en cualquier pantalla:
```dart
final settingsProvider = Provider.of<SettingsProvider>(context);

// Obtener configuración actual
ThemeMode currentTheme = settingsProvider.themeMode;
Locale currentLocale = settingsProvider.locale;

// Cambiar configuración
await settingsProvider.setThemeMode(ThemeMode.dark);
await settingsProvider.setLocale(const Locale('en', ''));
```

#### Agregar nuevas traducciones:
1. Edita `lib/l10n/app_es.arb` (español)
2. Edita `lib/l10n/app_en.arb` (inglés)
3. Ejecuta `flutter gen-l10n` o reinicia la app
4. Usa en código: `AppLocalizations.of(context)!.tuClave`

## 📱 Flujo de Inicialización

```
main()
  ↓
Firebase.initializeApp()
  ↓
SettingsProvider.initialize()
  ↓
ChangeNotifierProvider(SettingsProvider)
  ↓
MyApp (escucha settingsProvider)
  ↓
themeMode y locale se aplican automáticamente
```

## ✅ Pruebas Recomendadas

1. **Cambio de Tema**:
   - Cambia entre claro/oscuro/sistema
   - Verifica que el tema se aplica inmediatamente
   - Cierra y reabre la app → debe mantener el tema

2. **Cambio de Idioma**:
   - Cambia entre español/inglés
   - Verifica que todos los textos cambian
   - Cierra y reabre la app → debe mantener el idioma

3. **Modo Sistema**:
   - Selecciona "Predeterminado del Sistema"
   - Cambia el tema del dispositivo
   - La app debe seguir el tema del sistema

## 🚀 Próximos Pasos Opcionales

- Agregar más idiomas (Francés, Portugués, etc.)
- Implementar temas personalizados (colores custom)
- Agregar configuración de tamaño de fuente
- Implementar modo de alto contraste para accesibilidad
- Sincronizar configuraciones con Firebase (multi-dispositivo)

## 🐛 Solución de Problemas

### El tema no se aplica
- Verifica que `SettingsProvider` está inicializado antes de `MyApp`
- Revisa que el `themeMode` se pasa correctamente a `MaterialApp`

### Las traducciones no aparecen
- Ejecuta `flutter gen-l10n`
- Verifica que el código de idioma está en `supportedLocales`
- Confirma que las claves existen en ambos archivos `.arb`

### La configuración no persiste
- Verifica que `SharedPreferences` está instalado
- Revisa que `initialize()` se llama antes de usar el provider
- Comprueba permisos de escritura en el dispositivo

---

**Implementado el 15 de noviembre de 2025**
**Versión: 1.0.0**

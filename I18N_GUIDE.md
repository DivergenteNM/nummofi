# Guía de Internacionalización (i18n) - NummoFi

## 📋 Configuración Completada

La aplicación NummoFi ahora soporta **español** e **inglés** usando el sistema oficial de Flutter (`flutter_localizations` y archivos ARB).

## 📁 Estructura de Archivos

```
nummofi/
├── l10n.yaml                    # Configuración de localización
├── lib/
│   └── l10n/
│       ├── app_es.arb          # Traducciones en español
│       └── app_en.arb          # Traducciones en inglés
└── pubspec.yaml                # Dependencias configuradas
```

## 🔧 Archivos Modificados

### 1. `pubspec.yaml`
- ✅ Agregado `flutter_localizations: sdk: flutter`
- ✅ Actualizado `intl` a versión 0.20.2
- ✅ Agregado `generate: true` en la sección `flutter`

### 2. `l10n.yaml`
Configuración de generación de localizaciones:
```yaml
arb-dir: lib/l10n
template-arb-file: app_es.arb
output-localization-file: app_localizations.dart
```

### 3. `lib/main.dart`
- ✅ Importado `flutter_localizations` y `AppLocalizations`
- ✅ Configurado `localizationsDelegates`
- ✅ Definido `supportedLocales` (es, en)
- ✅ Actualizado textos para usar localizaciones

### 4. `lib/screens/home_screen.dart`
- ✅ Importado `AppLocalizations`
- ✅ Actualizado BottomNavigationBar con textos localizados
- ✅ Actualizado meses con traducciones

## 🌍 Idiomas Soportados

| Idioma | Código | Archivo ARB |
|--------|--------|-------------|
| Español | `es` | `app_es.arb` |
| Inglés | `en` | `app_en.arb` |

El idioma por defecto es **español**.

## 💡 Cómo Usar las Traducciones en el Código

### Importar AppLocalizations
```dart
import '../l10n/app_localizations.dart';
// o si estás en la raíz de lib:
import 'l10n/app_localizations.dart';
```

### Usar en un Widget
```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.dashboard);  // Muestra "Dashboard" o según idioma
}
```

### Ejemplos de Uso

```dart
// Textos simples
Text(l10n.income)           // "Ingreso" / "Income"
Text(l10n.expense)          // "Gasto" / "Expense"
Text(l10n.save)             // "Guardar" / "Save"

// En botones
ElevatedButton(
  onPressed: () {},
  child: Text(l10n.save),
)

// En AppBar
AppBar(
  title: Text(l10n.transactions),
)

// En BottomNavigationBar
BottomNavigationBarItem(
  icon: Icon(Icons.dashboard),
  label: l10n.dashboard,
)
```

## 📝 Claves Disponibles

Las siguientes claves están disponibles en ambos idiomas:

### Navegación
- `dashboard`, `transactions`, `budgets`, `reports`, `history`, `goals`

### Meses
- `january` a `december`

### Acciones
- `save`, `cancel`, `edit`, `delete`, `add`, `confirm`, `yes`, `no`, `retry`

### Transacciones
- `income`, `expense`, `amount`, `category`, `description`, `date`
- `addTransaction`, `editTransaction`, `deleteTransaction`, `noTransactions`

### Presupuestos
- `setBudgets`, `editBudgets`, `viewSummary`, `budgetSummary`
- `spent`, `remaining`, `exceeded`, `noBudgets`

### Reportes
- `monthlyReport`, `expensesByCategory`, `incomeVsExpenses`, `trend`

### Metas
- `createGoal`, `editGoal`, `goalName`, `targetAmount`, `currentAmount`
- `deadline`, `progress`, `completed`, `inProgress`, `noGoals`

### Categorías
- `food`, `transport`, `entertainment`, `health`, `education`
- `shopping`, `bills`, `salary`, `other`

### Estados
- `loading`, `error`, `success`, `authenticationError`, `notAuthenticated`

### Totales
- `totalIncome`, `totalExpenses`, `balance`, `savings`

## ➕ Agregar Nuevas Traducciones

### 1. Editar archivos ARB
Agrega la nueva clave en **ambos** archivos:

**lib/l10n/app_es.arb:**
```json
{
  "newKey": "Nuevo Texto",
  "@newKey": {
    "description": "Descripción del nuevo texto"
  }
}
```

**lib/l10n/app_en.arb:**
```json
{
  "newKey": "New Text",
  "@newKey": {
    "description": "Description of the new text"
  }
}
```

### 2. Regenerar localizaciones
```bash
flutter gen-l10n
```

O simplemente:
```bash
flutter run
```
(Se genera automáticamente al compilar)

### 3. Usar en el código
```dart
Text(l10n.newKey)
```

## 🌐 Traducciones con Parámetros

Para textos con variables:

**app_es.arb:**
```json
{
  "welcome": "Bienvenido, {name}!",
  "@welcome": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**app_en.arb:**
```json
{
  "welcome": "Welcome, {name}!",
  "@welcome": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

**Uso:**
```dart
Text(l10n.welcome('Juan'))  // "Bienvenido, Juan!" o "Welcome, Juan!"
```

## 🔄 Cambiar Idioma de la App

### Opción 1: Detectar automáticamente del sistema
Ya está configurado por defecto.

### Opción 2: Selector manual de idioma
```dart
MaterialApp(
  locale: Locale('en', ''), // Forzar inglés
  // ... resto de configuración
)
```

Para cambiar dinámicamente, puedes usar un Provider o setState:
```dart
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('es', '');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      // ... resto
    );
  }
}
```

## 🚀 Comandos Útiles

```bash
# Generar localizaciones manualmente
flutter gen-l10n

# Limpiar y reconstruir
flutter clean
flutter pub get

# Ver paquetes desactualizados
flutter pub outdated

# Ejecutar la app
flutter run
```

## ✅ Verificación

Para verificar que todo funciona:

1. **Compilar la app:** `flutter run`
2. **Cambiar idioma del dispositivo** y reiniciar la app
3. **Verificar** que los textos cambien según el idioma

## 📱 Próximos Pasos

Para completar la internacionalización en toda la app:

1. Revisar todas las pantallas (`dashboard_screen.dart`, `transactions_screen.dart`, etc.)
2. Reemplazar strings hardcodeados por `l10n.clave`
3. Agregar las claves faltantes en los archivos ARB
4. Regenerar con `flutter gen-l10n`

## 🐛 Solución de Problemas

### Error: "Target of URI doesn't exist"
- Ejecuta `flutter pub get`
- Ejecuta `flutter gen-l10n` o `flutter run`

### Los cambios en ARB no se reflejan
- Ejecuta `flutter clean`
- Ejecuta `flutter pub get`
- Reinicia la app

### El idioma no cambia
- Verifica que el idioma del dispositivo esté en los `supportedLocales`
- Reinicia la aplicación completamente

## 📚 Recursos

- [Flutter Internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [ARB File Format](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [intl Package](https://pub.dev/packages/intl)

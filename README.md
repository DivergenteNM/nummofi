# NumMoFi - Gestión Financiera Personal 🎉

Aplicación Flutter completa de gestión financiera personal con soporte de Firebase.

## ✨ Estado del Proyecto

**🎊 PROYECTO 100% COMPLETO 🎊**

Todas las pantallas implementadas y funcionales:
- ✅ **HomeScreen** - Navegación principal con bottom nav
- ✅ **DashboardScreen** - Resumen financiero con gráficas
- ✅ **TransactionsScreen** - CRUD completo de transacciones
- ✅ **BudgetsScreen** - Planificación y seguimiento de presupuestos
- ✅ **ReportsScreen** - Análisis con gráficas de dona y líneas
- ✅ **HistoryScreen** - Cierres mensuales y historial

## 🚀 Características Principales

### 💰 Gestión de Transacciones
- Registro de ingresos, egresos y transferencias
- Categorización automática
- Múltiples canales (Nequi, NuBank, Efectivo)
- Edición y eliminación de transacciones
- Fecha y descripción personalizables

### 📊 Dashboard Inteligente
- Resumen de saldos por canal
- Gráficas de barras de movimientos mensuales
- Indicadores de ingresos y egresos
- Actualización en tiempo real

### 🎯 Presupuestos
- Definición de presupuestos por categoría
- Comparación real vs planificado
- Indicadores visuales de progreso
- Alertas de sobrepresupuestación
- Modo vista y edición

### 📈 Reportes Avanzados
- Selector de período (mes/trimestre/año)
- Estadísticas generales (4 KPIs)
- Gráfica de dona: distribución de egresos
- Gráfica de líneas: evolución temporal
- Top 5 categorías (ingresos y egresos)
- Comparativa por canal de pago

### 📚 Historial y Cierres
- Cierre mensual automático
- Comparación de saldos iniciales vs finales
- Tasa de ahorro calculada
- Comparación con presupuesto
- Resúmenes permanentes
- Visualización histórica expandible

### 🔄 Sincronización
- Firebase Firestore para almacenamiento
- Actualización en tiempo real
- Streams reactivos
- Persistencia automática
- Autenticación anónima

## 📋 Requisitos

- Flutter SDK 3.9.2 o superior
- Cuenta de Firebase
- Android Studio / VS Code
- Git

## 🛠️ Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/DivergenteNM/nummofi.git
cd nummofi
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

#### Opción A: Usando FlutterFire CLI (Recomendado)

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase (sigue las instrucciones)
flutterfire configure
```

#### Opción B: Configuración Manual

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Agrega una app Android:
   - Nombre del paquete: `com.example.nummofi` (o el que prefieras)
   - Descarga `google-services.json`
   - Colócalo en `android/app/`

4. Agrega una app iOS (opcional):
   - Bundle ID: `com.example.nummofi`
   - Descarga `GoogleService-Info.plist`
   - Colócalo en `ios/Runner/`

5. Habilita **Firestore** y **Authentication** en Firebase Console:
   - Ve a **Firestore Database** → Crear base de datos (modo prueba)
   - Ve a **Authentication** → Sign-in method → Habilitar "Anónimo"

### 4. Configurar reglas de Firestore

En Firebase Console → Firestore Database → Reglas, agrega:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir acceso solo a usuarios autenticados
    match /artifacts/{appId}/users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5. Ejecutar la aplicación

```bash
# Para Android
flutter run

# Para iOS
flutter run -d ios

# Para Web
flutter run -d chrome
```

## 📱 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/       # Constantes de la app
│   ├── providers/       # Provider para manejo de estado
│   ├── services/        # Servicios (Firebase, Auth)
│   ├── theme/          # Tema y colores
│   └── utils/          # Utilidades
├── data/
│   ├── models/         # Modelos de datos
│   └── repositories/   # (Futuro: Repositorios)
├── screens/            # Pantallas de la app
│   ├── dashboard_screen.dart
│   ├── transactions_screen.dart
│   ├── budgets_screen.dart
│   ├── reports_screen.dart
│   └── history_screen.dart
└── main.dart
```

## 🎨 Tecnologías Utilizadas

- **Flutter** - Framework UI
- **Firebase Auth** - Autenticación
- **Cloud Firestore** - Base de datos en tiempo real
- **Provider** - Gestión de estado
- **fl_chart** - Gráficas y visualizaciones
- **intl** - Formateo de moneda

## 🔄 Migración desde JSX/React

Esta aplicación fue originalmente desarrollada en React con JSX y ha sido convertida a Flutter. Las principales diferencias:

| React/JSX | Flutter |
|-----------|---------|
| `useState` | `ChangeNotifier` + `Provider` |
| `useEffect` | `initState` + `StreamBuilder` |
| Componentes JSX | Widgets |
| CSS/Tailwind | `Theme` + `styled widgets` |
| Chart.js | fl_chart |

## 🔐 Firebase vs Supabase

**¿Por qué elegimos Firestore?**

✅ **Ventajas de Firestore:**
- Integración nativa con Flutter
- Listeners en tiempo real
- Autenticación simplificada
- Escalabilidad automática
- Plan gratuito generoso

❌ **Desventajas:**
- NoSQL (menos flexible que SQL)
- Consultas limitadas vs PostgreSQL

**Cuándo usar Supabase:**
- Necesitas SQL complejo
- Prefieres control total del backend
- Quieres row-level security con PostgreSQL

## 📝 Próximas Funcionalidades

- [ ] Completar pantallas de Presupuestos, Reportes e Historial
- [ ] Gráficas de dona y líneas temporales
- [ ] Exportar reportes a PDF
- [ ] Modo oscuro
- [ ] Notificaciones push
- [ ] Sincronización offline
- [ ] Autenticación con Google/Apple

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT.

## 👤 Autor

**DivergenteNM**
- GitHub: [@DivergenteNM](https://github.com/DivergenteNM)

## 🙏 Agradecimientos

- Inspirado en la necesidad de gestionar finanzas personales
- Convertido desde un diseño generado con IA en Canva

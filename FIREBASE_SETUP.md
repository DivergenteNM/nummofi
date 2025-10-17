# Guía de Configuración de Firebase para NumMoFi

## 📱 Configuración Paso a Paso

### 1. Crear Proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Nombre del proyecto: `nummofi` (o el que prefieras)
4. Acepta los términos y crea el proyecto

### 2. Configurar Firebase para Flutter

#### Opción A: FlutterFire CLI (Recomendado)

```powershell
# 1. Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# 2. Asegúrate de estar en la raíz del proyecto
cd "C:\Users\nicol\OneDrive\Documentos\Dev movil\Flutter_app\nummofi"

# 3. Ejecutar configuración automática
flutterfire configure

# Sigue las instrucciones:
# - Selecciona tu proyecto de Firebase
# - Selecciona las plataformas (android, ios, web, etc.)
# - Confirma la configuración
```

#### Opción B: Configuración Manual

**Para Android:**

1. En Firebase Console, ve a "Configuración del proyecto"
2. Haz clic en el ícono de Android
3. Registra tu app:
   - Nombre del paquete Android: `com.example.nummofi`
   - Nombre de la app: NumMoFi
   - Certificado SHA-1: (opcional por ahora)
4. Descarga el archivo `google-services.json`
5. Coloca el archivo en: `android/app/google-services.json`
6. Edita `android/build.gradle.kts`:
   ```kotlin
   dependencies {
       classpath("com.google.gms:google-services:4.4.0")
   }
   ```
7. Edita `android/app/build.gradle.kts` al final del archivo:
   ```kotlin
   plugins {
       id("com.google.gms.google-services")
   }
   ```

**Para iOS:**

1. En Firebase Console, agrega una app iOS
2. Bundle ID: `com.example.nummofi`
3. Descarga `GoogleService-Info.plist`
4. Abre el proyecto en Xcode: `open ios/Runner.xcworkspace`
5. Arrastra `GoogleService-Info.plist` a la carpeta `Runner` en Xcode
6. Asegúrate de marcar "Copy items if needed"

### 3. Habilitar Servicios de Firebase

#### A. Habilitar Authentication (Anónimo)

1. En Firebase Console, ve a **Authentication**
2. Haz clic en "Comenzar"
3. Ve a la pestaña "Sign-in method"
4. Habilita el proveedor "Anónimo"
5. Guarda los cambios

#### B. Crear Firestore Database

1. En Firebase Console, ve a **Firestore Database**
2. Haz clic en "Crear base de datos"
3. Selecciona "Comenzar en modo de prueba" (para desarrollo)
4. Elige una ubicación (por ejemplo, `us-central`)
5. Haz clic en "Habilitar"

### 4. Configurar Reglas de Seguridad de Firestore

1. En Firestore Database, ve a la pestaña "Reglas"
2. Reemplaza el contenido con:

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

3. Haz clic en "Publicar"

### 5. Estructura de Datos en Firestore

La app creará automáticamente las siguientes colecciones:

```
artifacts/
└── {appId}/
    └── users/
        └── {userId}/
            ├── transactions/        # Transacciones del usuario
            │   └── {transactionId}
            ├── budgets/             # Presupuestos mensuales
            │   └── {month}-{year}
            └── monthlySummaries/    # Resúmenes de meses cerrados
                └── {month}-{year}
```

### 6. Verificar Configuración

```powershell
# Desde la raíz del proyecto
flutter pub get
flutter doctor

# Ejecutar la app
flutter run
```

### 7. Solución de Problemas Comunes

#### Error: "google-services.json not found"

**Solución:**
- Asegúrate de que `google-services.json` está en `android/app/`
- Verifica que agregaste el plugin en `android/app/build.gradle.kts`

#### Error: "FirebaseApp is not initialized"

**Solución:**
- Asegúrate de que `Firebase.initializeApp()` está en `main()` antes de `runApp()`
- Verifica que tienes `firebase_core` en `pubspec.yaml`

#### Error de permisos en Firestore

**Solución:**
- Verifica las reglas de seguridad en Firestore
- Asegúrate de que el usuario está autenticado antes de hacer consultas

#### La app no carga datos

**Solución:**
- Verifica la conexión a internet
- Revisa la consola de Firebase → Firestore → Datos
- Verifica que el `appId` y `userId` son correctos

### 8. Configuración de Producción

Cuando estés listo para producción:

1. **Actualiza las reglas de Firestore:**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /artifacts/{appId}/users/{userId}/{document=**} {
         allow read, write: if request.auth != null 
                           && request.auth.uid == userId;
       }
     }
   }
   ```

2. **Configura índices compuestos** (si es necesario):
   - Firebase te lo indicará en los logs si necesitas crear índices

3. **Habilita AppCheck** (opcional pero recomendado):
   - En Firebase Console → App Check
   - Registra tu app

4. **Configura el plan de facturación** según tu uso esperado

### 9. Variables de Entorno (Opcional)

Si quieres usar diferentes configuraciones para desarrollo y producción:

1. Crea `lib/firebase_options.dart` con FlutterFire CLI
2. Usa flavors de Flutter para diferentes entornos

### 10. Testing

Para probar con el emulador de Firestore:

```powershell
# Instalar Firebase CLI
npm install -g firebase-tools

# Iniciar emuladores
firebase emulators:start
```

## 📚 Recursos Adicionales

- [Documentación de FlutterFire](https://firebase.flutter.dev/)
- [Firestore Getting Started](https://firebase.google.com/docs/firestore/quickstart)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

## ✅ Checklist de Configuración

- [ ] Proyecto de Firebase creado
- [ ] FlutterFire configurado (o configuración manual completada)
- [ ] `google-services.json` en `android/app/`
- [ ] Authentication anónimo habilitado
- [ ] Firestore Database creado
- [ ] Reglas de seguridad configuradas
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] App ejecutándose sin errores
- [ ] Datos guardándose en Firestore

¡Listo! Tu app NumMoFi está configurada con Firebase. 🎉

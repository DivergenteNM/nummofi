import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'core/services/firestore_service.dart';
import 'core/providers/finance_provider.dart';
import 'core/providers/settings_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preservar el splash screen hasta que la app esté lista
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Crear e inicializar SettingsProvider
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: settingsProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return MaterialApp(
      title: 'NummoFi',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, 
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.themeMode,
      
      // Configuración de localización
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Español
        Locale('en', ''), // Inglés
      ],
      locale: settingsProvider.locale,
      
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Intentar login anónimo
      await _authService.signInAnonymously();
      setState(() {
        _isLoading = false;
      });

      // Remover el splash screen cuando la autenticación esté lista
      FlutterNativeSplash.remove();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      // Remover el splash screen incluso si hay error
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n?.authenticationError ?? 'Error de autenticación'),
              const SizedBox(height: 8),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeAuth,
                child: Text(l10n?.retry ?? 'Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final userId = snapshot.data!.uid;
          final appId = 'default-app-id'; // Puedes configurar esto

          return ChangeNotifierProvider(
            create: (_) =>
                FinanceProvider(FirestoreService(appId: appId, userId: userId)),
            child: const HomeScreen(),
          );
        }

        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n?.notAuthenticated ?? 'No autenticado'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeAuth,
                  child: Text(l10n?.signIn ?? 'Iniciar sesión'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

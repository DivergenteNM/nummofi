import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;
  
  // Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login anónimo
  Future<UserCredential> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      throw Exception('Error al iniciar sesión anónima: $e');
    }
  }

  // Login con token personalizado
  Future<UserCredential> signInWithCustomToken(String token) async {
    try {
      return await _auth.signInWithCustomToken(token);
    } catch (e) {
      throw Exception('Error al iniciar sesión con token: $e');
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

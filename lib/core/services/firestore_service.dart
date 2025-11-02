import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/monthly_summary_model.dart';
import '../../data/models/goal_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String appId;
  final String userId;

  FirestoreService({
    required this.appId,
    required this.userId,
  });

  // Obtener la ruta de colección
  String _getCollectionPath(String collectionName) {
    return 'artifacts/$appId/users/$userId/$collectionName';
  }

  // ==================== TRANSACCIONES ====================
  
  // Stream de transacciones
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _firestore
        .collection(_getCollectionPath('transactions'))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  // Agregar transacción
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(_getCollectionPath('transactions'))
          .add(transaction.toMap());
    } catch (e) {
      throw Exception('Error al agregar transacción: $e');
    }
  }

  // Actualizar transacción
  Future<void> updateTransaction(String id, TransactionModel transaction) async {
    try {
      await _firestore
          .collection(_getCollectionPath('transactions'))
          .doc(id)
          .update(transaction.toMap());
    } catch (e) {
      throw Exception('Error al actualizar transacción: $e');
    }
  }

  // Eliminar transacción
  Future<void> deleteTransaction(String id) async {
    try {
      await _firestore
          .collection(_getCollectionPath('transactions'))
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar transacción: $e');
    }
  }

  // ==================== PRESUPUESTOS ====================
  
  // Stream de presupuestos
  Stream<List<BudgetModel>> getBudgetsStream() {
    return _firestore
        .collection(_getCollectionPath('budgets'))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BudgetModel.fromFirestore(doc))
            .toList());
  }

  // Guardar presupuesto
  Future<void> saveBudget(BudgetModel budget) async {
    try {
      String docId = '${budget.month}-${budget.year}';
      await _firestore
          .collection(_getCollectionPath('budgets'))
          .doc(docId)
          .set(budget.toMap());
    } catch (e) {
      throw Exception('Error al guardar presupuesto: $e');
    }
  }

  // ==================== RESÚMENES MENSUALES ====================
  
  // Stream de resúmenes mensuales
  Stream<List<MonthlySummaryModel>> getMonthlySummariesStream() {
    return _firestore
        .collection(_getCollectionPath('monthlySummaries'))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MonthlySummaryModel.fromFirestore(doc))
            .toList());
  }

  // Guardar resumen mensual
  Future<void> saveMonthlySummary(MonthlySummaryModel summary) async {
    try {
      String docId = '${summary.month}-${summary.year}';
      await _firestore
          .collection(_getCollectionPath('monthlySummaries'))
          .doc(docId)
          .set(summary.toMap());
    } catch (e) {
      throw Exception('Error al guardar resumen mensual: $e');
    }
  }

  // Cerrar mes (transacción atómica)
  Future<void> closeMonth(MonthlySummaryModel summary) async {
    try {
      await _firestore.runTransaction((transaction) async {
        String docId = '${summary.month}-${summary.year}';
        DocumentReference summaryRef = _firestore
            .collection(_getCollectionPath('monthlySummaries'))
            .doc(docId);
        
        transaction.set(summaryRef, summary.toMap());
      });
    } catch (e) {
      throw Exception('Error al cerrar mes: $e');
    }
  }

  // ==================== METAS ====================
  
  // Stream de metas
  Stream<List<GoalModel>> getGoalsStream() {
    return _firestore
        .collection(_getCollectionPath('goals'))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GoalModel.fromFirestore(doc))
            .toList());
  }

  // Agregar meta
  Future<void> addGoal(GoalModel goal) async {
    try {
      await _firestore
          .collection(_getCollectionPath('goals'))
          .add(goal.toMap());
    } catch (e) {
      throw Exception('Error al agregar meta: $e');
    }
  }

  // Actualizar meta
  Future<void> updateGoal(String id, GoalModel goal) async {
    try {
      await _firestore
          .collection(_getCollectionPath('goals'))
          .doc(id)
          .update(goal.toMap());
    } catch (e) {
      throw Exception('Error al actualizar meta: $e');
    }
  }

  // Eliminar meta
  Future<void> deleteGoal(String id) async {
    try {
      await _firestore
          .collection(_getCollectionPath('goals'))
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Error al eliminar meta: $e');
    }
  }

  // Actualizar monto actual de una meta
  Future<void> updateGoalProgress(String id, double newAmount) async {
    try {
      await _firestore
          .collection(_getCollectionPath('goals'))
          .doc(id)
          .update({'currentAmount': newAmount});
    } catch (e) {
      throw Exception('Error al actualizar progreso: $e');
    }
  }
}

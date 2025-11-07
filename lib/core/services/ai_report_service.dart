import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/monthly_ai_report_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/goal_model.dart';

/// Servicio para generar reportes mensuales para análisis de IA
class AIReportService {
  final String appId;
  final String userId;

  AIReportService({
    required this.appId,
    required this.userId,
  });

  /// Genera un reporte completo del mes especificado
  Future<MonthlyAIReportModel> generateMonthlyReport({
    required int month,
    required int year,
  }) async {
    // 1. Obtener todas las transacciones del mes
    final transactions = await _getMonthTransactions(month, year);

    // 2. Obtener el presupuesto del mes (si existe)
    final budget = await _getMonthBudget(month, year);

    // 3. Obtener las metas activas
    final goals = await _getActiveGoals();

    // 4. Calcular ingresos por categoría
    final ingresosPorCategoria = _calculateIncomeByCategory(transactions);
    final ingresosTotal = ingresosPorCategoria.values.fold(0.0, (a, b) => a + b);

    // 5. Calcular egresos por categoría
    final egresosPorCategoria = _calculateExpensesByCategory(transactions);
    final egresosTotal = egresosPorCategoria.values.fold(0.0, (a, b) => a + b);

    // 6. Calcular saldo por canal (banco/efectivo)
    final saldoPorCanal = await _calculateChannelBalances();

    // 7. Análisis de transacciones
    final totalTransacciones = transactions.length;
    final diasDelMes = DateTime(year, month + 1, 0).day;
    final promedioGastoDiario = egresosTotal / diasDelMes;

    // Encontrar categoría con más gastos
    String categoriaConMasGastos = 'Ninguna';
    double maxGasto = 0;
    egresosPorCategoria.forEach((categoria, monto) {
      if (monto > maxGasto) {
        maxGasto = monto;
        categoriaConMasGastos = categoria;
      }
    });

    // 8. Calcular porcentaje de ahorro
    final balanceNeto = ingresosTotal - egresosTotal;
    final porcentajeAhorro = ingresosTotal > 0 
        ? (balanceNeto / ingresosTotal * 100).toDouble()
        : 0.0;

    // 9. Calcular metas de ahorro
    final metaAhorroTotal = goals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
    final ahorradoEnMetas = goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);

    final metasSummary = goals.map((goal) => GoalSummary(
      titulo: goal.title,
      montoObjetivo: goal.targetAmount,
      montoActual: goal.currentAmount,
      porcentajeCompletado: goal.progressPercentage,
      fechaObjetivo: goal.targetDate,
      completada: goal.isCompleted,
    )).toList();

    // 10. Comparar con mes anterior
    final previousMonth = month == 1 ? 12 : month - 1;
    final previousYear = month == 1 ? year - 1 : year;
    final previousReport = await _getPreviousMonthReport(previousMonth, previousYear);

    double? ingresosMesAnterior;
    double? egresosMesAnterior;
    double? variacionIngresos;
    double? variacionEgresos;

    if (previousReport != null) {
      ingresosMesAnterior = previousReport.ingresosTotal;
      egresosMesAnterior = previousReport.egresosTotal;
      
      variacionIngresos = ingresosMesAnterior > 0
          ? ((ingresosTotal - ingresosMesAnterior) / ingresosMesAnterior * 100)
          : 0;
      
      variacionEgresos = egresosMesAnterior > 0
          ? ((egresosTotal - egresosMesAnterior) / egresosMesAnterior * 100)
          : 0;
    }

    // 11. Verificar cumplimiento de presupuesto
    bool? cumplioPresupuesto;
    if (budget != null) {
      final presupuestoIngresosTotal = budget.totalIncome;
      final presupuestoEgresosTotal = budget.totalExpense;
      
      cumplioPresupuesto = ingresosTotal >= presupuestoIngresosTotal &&
          egresosTotal <= presupuestoEgresosTotal;
    }

    // 12. Crear el modelo del reporte
    final report = MonthlyAIReportModel(
      mes: '${_getMonthName(month)} $year',
      month: month,
      year: year,
      ingresosTotal: ingresosTotal,
      ingresosPorCategoria: ingresosPorCategoria,
      egresosTotal: egresosTotal,
      egresosPorCategoria: egresosPorCategoria,
      presupuestoIngresos: budget?.incomes,
      presupuestoEgresos: budget?.expenses,
      metaAhorroTotal: metaAhorroTotal,
      ahorradoEnMetas: ahorradoEnMetas,
      metas: metasSummary,
      saldoPorCanal: saldoPorCanal,
      totalTransacciones: totalTransacciones,
      promedioGastoDiario: promedioGastoDiario,
      categoriaConMasGastos: categoriaConMasGastos,
      porcentajeAhorro: porcentajeAhorro,
      ingresosMesAnterior: ingresosMesAnterior,
      egresosMesAnterior: egresosMesAnterior,
      variacionIngresos: variacionIngresos,
      variacionEgresos: variacionEgresos,
      balanceNeto: balanceNeto,
      cumplioPresupuesto: cumplioPresupuesto,
      fechaGeneracion: DateTime.now(),
      userId: userId,
    );

    return report;
  }

  /// Guarda el reporte en Firestore para mantener historial
  Future<void> saveReport(MonthlyAIReportModel report) async {
    final docId = '${report.year}_${report.month.toString().padLeft(2, '0')}';
    
    await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('ai_reports')
        .doc(docId)
        .set(report.toFirestore());
  }

  /// Obtiene un reporte guardado previamente
  Future<MonthlyAIReportModel?> getReport(int month, int year) async {
    final docId = '${year}_${month.toString().padLeft(2, '0')}';
    
    final doc = await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('ai_reports')
        .doc(docId)
        .get();

    if (doc.exists) {
      return MonthlyAIReportModel.fromFirestore(doc);
    }
    return null;
  }

  /// Obtiene todos los reportes del usuario (historial)
  Stream<List<MonthlyAIReportModel>> getReportsStream() {
    return FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('ai_reports')
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MonthlyAIReportModel.fromFirestore(doc))
            .toList());
  }

  // ============ MÉTODOS PRIVADOS ============

  Future<List<TransactionModel>> _getMonthTransactions(int month, int year) async {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0, 23, 59, 59);

    final snapshot = await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  Future<BudgetModel?> _getMonthBudget(int month, int year) async {
    final docId = '${year}_${month.toString().padLeft(2, '0')}';

    final doc = await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(docId)
        .get();

    if (doc.exists) {
      return BudgetModel.fromFirestore(doc);
    }
    return null;
  }

  Future<List<GoalModel>> _getActiveGoals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();

    return snapshot.docs
        .map((doc) => GoalModel.fromFirestore(doc))
        .toList();
  }

  Map<String, double> _calculateIncomeByCategory(List<TransactionModel> transactions) {
    final Map<String, double> incomes = {};

    for (var transaction in transactions) {
      if (transaction.type == 'Ingreso') {
        final category = transaction.category ?? 'Sin categoría';
        incomes[category] = (incomes[category] ?? 0) + transaction.amount;
      }
    }

    return incomes;
  }

  Map<String, double> _calculateExpensesByCategory(List<TransactionModel> transactions) {
    final Map<String, double> expenses = {};

    for (var transaction in transactions) {
      if (transaction.type == 'Egreso') {
        final category = transaction.category ?? 'Sin categoría';
        expenses[category] = (expenses[category] ?? 0) + transaction.amount;
      }
    }

    return expenses;
  }

  Future<Map<String, double>> _calculateChannelBalances() async {
    final Map<String, double> balances = {};

    // Obtener todas las transacciones del usuario (o solo las recientes si quieres)
    final snapshot = await FirebaseFirestore.instance
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();

    final transactions = snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();

    // Calcular balance por canal
    for (var transaction in transactions) {
      if (transaction.type == 'Ingreso' && transaction.channel != null) {
        balances[transaction.channel!] = 
            (balances[transaction.channel!] ?? 0) + transaction.amount;
      } else if (transaction.type == 'Egreso' && transaction.channel != null) {
        balances[transaction.channel!] = 
            (balances[transaction.channel!] ?? 0) - transaction.amount;
      } else if (transaction.type == 'Transferencia') {
        if (transaction.channelFrom != null) {
          balances[transaction.channelFrom!] = 
              (balances[transaction.channelFrom!] ?? 0) - transaction.amount;
        }
        if (transaction.channelTo != null) {
          balances[transaction.channelTo!] = 
              (balances[transaction.channelTo!] ?? 0) + transaction.amount;
        }
      }
    }

    return balances;
  }

  Future<MonthlyAIReportModel?> _getPreviousMonthReport(int month, int year) async {
    return await getReport(month, year);
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return monthNames[month - 1];
  }
}

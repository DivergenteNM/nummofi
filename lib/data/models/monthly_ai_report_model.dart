import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo para el reporte mensual que será enviado a la IA
class MonthlyAIReportModel {
  final String mes; // "Octubre 2025"
  final int month; // 10
  final int year; // 2025
  
  // Ingresos totales
  final double ingresosTotal;
  final Map<String, double> ingresosPorCategoria;
  
  // Egresos detallados por categoría
  final double egresosTotal;
  final Map<String, double> egresosPorCategoria;
  
  // Presupuesto (si existe)
  final Map<String, double>? presupuestoIngresos;
  final Map<String, double>? presupuestoEgresos;
  
  // Metas de ahorro
  final double metaAhorroTotal; // Suma de todas las metas activas
  final double ahorradoEnMetas; // Suma del progreso en las metas
  final List<GoalSummary> metas;
  
  // Canales (bancos/efectivo)
  final Map<String, double> saldoPorCanal;
  
  // Análisis de transacciones
  final int totalTransacciones;
  final double promedioGastoDiario;
  final String categoriaConMasGastos;
  final double porcentajeAhorro; // (ingresos - egresos) / ingresos * 100
  
  // Comparación con mes anterior (opcional)
  final double? ingresosMesAnterior;
  final double? egresosMesAnterior;
  final double? variacionIngresos; // Porcentaje
  final double? variacionEgresos; // Porcentaje
  
  // Balance final
  final double balanceNeto; // ingresos - egresos
  final bool? cumplioPresupuesto;
  
  // Metadatos
  final DateTime fechaGeneracion;
  final String? userId;

  MonthlyAIReportModel({
    required this.mes,
    required this.month,
    required this.year,
    required this.ingresosTotal,
    required this.ingresosPorCategoria,
    required this.egresosTotal,
    required this.egresosPorCategoria,
    this.presupuestoIngresos,
    this.presupuestoEgresos,
    required this.metaAhorroTotal,
    required this.ahorradoEnMetas,
    required this.metas,
    required this.saldoPorCanal,
    required this.totalTransacciones,
    required this.promedioGastoDiario,
    required this.categoriaConMasGastos,
    required this.porcentajeAhorro,
    this.ingresosMesAnterior,
    this.egresosMesAnterior,
    this.variacionIngresos,
    this.variacionEgresos,
    required this.balanceNeto,
    this.cumplioPresupuesto,
    required this.fechaGeneracion,
    this.userId,
  });

  /// Convertir a JSON para enviar a la API de IA
  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'periodo': {
        'month': month,
        'year': year,
      },
      'ingresos': {
        'total': ingresosTotal,
        'por_categoria': ingresosPorCategoria,
      },
      'egresos': {
        'total': egresosTotal,
        'por_categoria': egresosPorCategoria,
      },
      if (presupuestoIngresos != null)
        'presupuesto': {
          'ingresos': presupuestoIngresos,
          'egresos': presupuestoEgresos,
          'cumplio_presupuesto': cumplioPresupuesto,
        },
      'metas_ahorro': {
        'meta_total': metaAhorroTotal,
        'ahorrado': ahorradoEnMetas,
        'porcentaje_cumplimiento': metaAhorroTotal > 0 
            ? (ahorradoEnMetas / metaAhorroTotal * 100).clamp(0, 100) 
            : 0,
        'metas_activas': metas.map((m) => m.toJson()).toList(),
      },
      'canales': saldoPorCanal,
      'analisis': {
        'total_transacciones': totalTransacciones,
        'promedio_gasto_diario': promedioGastoDiario,
        'categoria_mas_gastada': categoriaConMasGastos,
        'porcentaje_ahorro': porcentajeAhorro,
        'balance_neto': balanceNeto,
      },
      if (ingresosMesAnterior != null && egresosMesAnterior != null)
        'comparacion_mes_anterior': {
          'ingresos_anterior': ingresosMesAnterior,
          'egresos_anterior': egresosMesAnterior,
          'variacion_ingresos_porcentaje': variacionIngresos,
          'variacion_egresos_porcentaje': variacionEgresos,
        },
      'metadata': {
        'fecha_generacion': fechaGeneracion.toIso8601String(),
        'user_id': userId,
      },
    };
  }

  /// Convertir a Map para guardar en Firestore (historial)
  Map<String, dynamic> toFirestore() {
    return {
      'mes': mes,
      'month': month,
      'year': year,
      'ingresosTotal': ingresosTotal,
      'ingresosPorCategoria': ingresosPorCategoria,
      'egresosTotal': egresosTotal,
      'egresosPorCategoria': egresosPorCategoria,
      'presupuestoIngresos': presupuestoIngresos,
      'presupuestoEgresos': presupuestoEgresos,
      'metaAhorroTotal': metaAhorroTotal,
      'ahorradoEnMetas': ahorradoEnMetas,
      'metas': metas.map((m) => m.toJson()).toList(),
      'saldoPorCanal': saldoPorCanal,
      'totalTransacciones': totalTransacciones,
      'promedioGastoDiario': promedioGastoDiario,
      'categoriaConMasGastos': categoriaConMasGastos,
      'porcentajeAhorro': porcentajeAhorro,
      'ingresosMesAnterior': ingresosMesAnterior,
      'egresosMesAnterior': egresosMesAnterior,
      'variacionIngresos': variacionIngresos,
      'variacionEgresos': variacionEgresos,
      'balanceNeto': balanceNeto,
      'cumplioPresupuesto': cumplioPresupuesto,
      'fechaGeneracion': Timestamp.fromDate(fechaGeneracion),
      'userId': userId,
    };
  }

  /// Crear desde Firestore
  factory MonthlyAIReportModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MonthlyAIReportModel(
      mes: data['mes'] ?? '',
      month: data['month'] ?? 0,
      year: data['year'] ?? 0,
      ingresosTotal: (data['ingresosTotal'] ?? 0).toDouble(),
      ingresosPorCategoria: Map<String, double>.from(data['ingresosPorCategoria'] ?? {}),
      egresosTotal: (data['egresosTotal'] ?? 0).toDouble(),
      egresosPorCategoria: Map<String, double>.from(data['egresosPorCategoria'] ?? {}),
      presupuestoIngresos: data['presupuestoIngresos'] != null
          ? Map<String, double>.from(data['presupuestoIngresos'])
          : null,
      presupuestoEgresos: data['presupuestoEgresos'] != null
          ? Map<String, double>.from(data['presupuestoEgresos'])
          : null,
      metaAhorroTotal: (data['metaAhorroTotal'] ?? 0).toDouble(),
      ahorradoEnMetas: (data['ahorradoEnMetas'] ?? 0).toDouble(),
      metas: (data['metas'] as List<dynamic>?)
              ?.map((m) => GoalSummary.fromJson(m))
              .toList() ??
          [],
      saldoPorCanal: Map<String, double>.from(data['saldoPorCanal'] ?? {}),
      totalTransacciones: data['totalTransacciones'] ?? 0,
      promedioGastoDiario: (data['promedioGastoDiario'] ?? 0).toDouble(),
      categoriaConMasGastos: data['categoriaConMasGastos'] ?? '',
      porcentajeAhorro: (data['porcentajeAhorro'] ?? 0).toDouble(),
      ingresosMesAnterior: data['ingresosMesAnterior']?.toDouble(),
      egresosMesAnterior: data['egresosMesAnterior']?.toDouble(),
      variacionIngresos: data['variacionIngresos']?.toDouble(),
      variacionEgresos: data['variacionEgresos']?.toDouble(),
      balanceNeto: (data['balanceNeto'] ?? 0).toDouble(),
      cumplioPresupuesto: data['cumplioPresupuesto'],
      fechaGeneracion: (data['fechaGeneracion'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'],
    );
  }
}

/// Resumen simplificado de una meta para el reporte
class GoalSummary {
  final String titulo;
  final double montoObjetivo;
  final double montoActual;
  final double porcentajeCompletado;
  final DateTime? fechaObjetivo;
  final bool completada;

  GoalSummary({
    required this.titulo,
    required this.montoObjetivo,
    required this.montoActual,
    required this.porcentajeCompletado,
    this.fechaObjetivo,
    required this.completada,
  });

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'monto_objetivo': montoObjetivo,
      'monto_actual': montoActual,
      'porcentaje_completado': porcentajeCompletado,
      'fecha_objetivo': fechaObjetivo?.toIso8601String(),
      'completada': completada,
      'monto_faltante': montoObjetivo - montoActual,
    };
  }

  factory GoalSummary.fromJson(Map<String, dynamic> json) {
    return GoalSummary(
      titulo: json['titulo'] ?? '',
      montoObjetivo: (json['monto_objetivo'] ?? 0).toDouble(),
      montoActual: (json['monto_actual'] ?? 0).toDouble(),
      porcentajeCompletado: (json['porcentaje_completado'] ?? 0).toDouble(),
      fechaObjetivo: json['fecha_objetivo'] != null
          ? DateTime.parse(json['fecha_objetivo'])
          : null,
      completada: json['completada'] ?? false,
    );
  }
}

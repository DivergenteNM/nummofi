import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/monthly_ai_report_model.dart';

/// Servicio para comunicarse con la API de IA
/// Este es un EJEMPLO de cómo integrar la IA cuando esté lista
class AIAnalysisService {
  // TODO: Reemplazar con tu endpoint real cuando tengas el servidor de IA
  static const String aiApiUrl = 'https://nummofi-ia.vercel.app/api/analyze';
  
  // TODO: Configurar tu API key de forma segura (usar variables de entorno)
  static const String apiKey = 'AIzaSyAqLktvzvKpi4BiuDRq9qjnDJBheW_fGM4';

  /// Envía el reporte mensual a la IA y obtiene insights
  Future<AIInsightsResponse> analyzeReport(MonthlyAIReportModel report) async {
    try {
      final jsonData = report.toJson();
      
      final response = await http.post(
        Uri.parse(aiApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(jsonData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AIInsightsResponse.fromJson(responseData);
      } else {
        throw Exception('Error al analizar con IA: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión con IA: $e');
    }
  }

  /// Ejemplo alternativo usando OpenAI GPT-4
  Future<AIInsightsResponse> analyzeWithOpenAI(MonthlyAIReportModel report) async {
    const openAiUrl = 'https://api.openai.com/v1/chat/completions';
    const openAiKey = 'sk-...'; // TODO: Usar tu API key de OpenAI

    final jsonData = report.toJson();
    final jsonString = jsonEncode(jsonData);

    final prompt = '''
Eres un asesor financiero personal experto y amigable. Analiza el siguiente reporte financiero mensual de un usuario y proporciona:

1. **Insights Clave** (3-5 observaciones importantes sobre sus hábitos financieros)
2. **Alertas** (categorías que aumentaron significativamente o están por encima del presupuesto)
3. **Proyecciones** (estimación realista de cuándo alcanzará sus metas de ahorro)
4. **Recomendaciones** (2-3 acciones específicas y accionables para mejorar sus finanzas)

Reporte financiero:
$jsonString

IMPORTANTE: 
- Responde SOLO en formato JSON válido
- Usa formato de moneda colombiano (pesos COP)
- Sé específico con números y porcentajes
- Sé motivador pero realista

Formato de respuesta esperado:
{
  "insights": [
    {
      "tipo": "positivo|neutro|alerta",
      "categoria": "nombre_categoria",
      "mensaje": "descripción clara",
      "impacto_financiero": 50000
    }
  ],
  "alertas": [
    {
      "categoria": "Entretenimiento",
      "mensaje": "Tus gastos aumentaron 25%",
      "recomendacion": "Intenta reducir en 10%",
      "ahorro_potencial": 40000
    }
  ],
  "proyecciones": {
    "metas": [
      {
        "nombre_meta": "Comprar Laptop",
        "fecha_estimada": "2025-11-15",
        "meses_restantes": 1.5,
        "confianza": 0.85,
        "sugerencia": "mantener el ritmo actual"
      }
    ]
  },
  "recomendaciones": [
    {
      "prioridad": "alta|media|baja",
      "accion": "descripción de la acción",
      "beneficio_esperado": "ahorro mensual estimado o beneficio"
    }
  ],
  "resumen_general": "Un párrafo motivador resumiendo la situación financiera del mes"
}
''';

    try {
      final response = await http.post(
        Uri.parse(openAiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini', // o 'gpt-4' si tienes acceso
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un asesor financiero experto que analiza datos financieros en formato JSON.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final aiText = responseData['choices'][0]['message']['content'];
        
        // Extraer el JSON de la respuesta
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(aiText);
        if (jsonMatch != null) {
          final aiJson = jsonDecode(jsonMatch.group(0)!);
          return AIInsightsResponse.fromJson(aiJson);
        } else {
          throw Exception('No se pudo parsear la respuesta de la IA');
        }
      } else {
        throw Exception('Error OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al analizar con OpenAI: $e');
    }
  }

  /// Ejemplo con Google Gemini (cuando esté disponible)
  Future<AIInsightsResponse> analyzeWithGemini(MonthlyAIReportModel report) async {
    // TODO: Implementar cuando tengas acceso a Gemini API
    throw UnimplementedError('Gemini API aún no implementada');
  }
}

/// Modelo para la respuesta de la IA (actualizado para tu backend)
class AIInsightsResponse {
  final bool success;
  final String resumenEjecutivo;
  final List<AIInsight> insights;
  final List<AIProjection> proyecciones;
  final List<String> recomendaciones;
  final int puntuacionSaludFinanciera;
  final List<String> areasMejora;
  final List<String> fortalezas;
  final String timestamp;

  AIInsightsResponse({
    required this.success,
    required this.resumenEjecutivo,
    required this.insights,
    required this.proyecciones,
    required this.recomendaciones,
    required this.puntuacionSaludFinanciera,
    required this.areasMejora,
    required this.fortalezas,
    required this.timestamp,
  });

  factory AIInsightsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    return AIInsightsResponse(
      success: json['success'] ?? true,
      resumenEjecutivo: data['resumen_ejecutivo'] ?? '',
      insights: (data['insights'] as List<dynamic>?)
              ?.map((i) => AIInsight.fromJson(i))
              .toList() ??
          [],
      proyecciones: (data['proyecciones'] as List<dynamic>?)
              ?.map((p) => AIProjection.fromJson(p))
              .toList() ??
          [],
      recomendaciones: (data['recomendaciones'] as List<dynamic>?)
              ?.map((r) => r.toString())
              .toList() ??
          [],
      puntuacionSaludFinanciera: data['puntuacion_salud_financiera'] ?? 0,
      areasMejora: (data['areas_mejora'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          [],
      fortalezas: (data['fortalezas'] as List<dynamic>?)
              ?.map((f) => f.toString())
              .toList() ??
          [],
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }
}

/// Insight individual de la IA
class AIInsight {
  final String tipo; // alerta, felicitacion, recomendacion, info
  final String categoria;
  final String mensaje;
  final String recomendacion;
  final String impactoEstimado;

  AIInsight({
    required this.tipo,
    required this.categoria,
    required this.mensaje,
    required this.recomendacion,
    required this.impactoEstimado,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      tipo: json['tipo'] ?? 'info',
      categoria: json['categoria'] ?? '',
      mensaje: json['mensaje'] ?? '',
      recomendacion: json['recomendacion'] ?? '',
      impactoEstimado: json['impacto_estimado'] ?? '',
    );
  }
}

/// Proyección de la IA
class AIProjection {
  final String descripcion;
  final String fechaEstimada;
  final double confianza;
  final String detalles;

  AIProjection({
    required this.descripcion,
    required this.fechaEstimada,
    required this.confianza,
    required this.detalles,
  });

  factory AIProjection.fromJson(Map<String, dynamic> json) {
    return AIProjection(
      descripcion: json['descripcion'] ?? '',
      fechaEstimada: json['fecha_estimada'] ?? '',
      confianza: (json['confianza'] ?? 0.5).toDouble(),
      detalles: json['detalles'] ?? '',
    );
  }
}

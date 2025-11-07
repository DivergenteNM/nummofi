import 'package:flutter/material.dart';
import '../core/services/ai_analysis_service.dart';

/// Pantalla para mostrar los insights de IA
class AIInsightsScreen extends StatelessWidget {
  final AIInsightsResponse insights;

  const AIInsightsScreen({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis Financiero IA'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con puntuación
            _buildHealthScoreCard(),
            const SizedBox(height: 24),

            // Resumen Ejecutivo
            _buildSectionTitle('📊 Resumen Ejecutivo'),
            const SizedBox(height: 12),
            _buildResumenCard(),
            const SizedBox(height: 24),

            // Fortalezas
            if (insights.fortalezas.isNotEmpty) ...[
              _buildSectionTitle('💪 Tus Fortalezas'),
              const SizedBox(height: 12),
              _buildFortalezasList(),
              const SizedBox(height: 24),
            ],

            // Insights
            if (insights.insights.isNotEmpty) ...[
              _buildSectionTitle('💡 Análisis Detallado'),
              const SizedBox(height: 12),
              _buildInsightsList(),
              const SizedBox(height: 24),
            ],

            // Proyecciones
            if (insights.proyecciones.isNotEmpty) ...[
              _buildSectionTitle('🔮 Proyecciones'),
              const SizedBox(height: 12),
              _buildProyeccionesList(),
              const SizedBox(height: 24),
            ],

            // Recomendaciones
            if (insights.recomendaciones.isNotEmpty) ...[
              _buildSectionTitle('🎯 Recomendaciones'),
              const SizedBox(height: 12),
              _buildRecomendacionesList(),
              const SizedBox(height: 24),
            ],

            // Áreas de Mejora
            if (insights.areasMejora.isNotEmpty) ...[
              _buildSectionTitle('📈 Áreas de Mejora'),
              const SizedBox(height: 12),
              _buildAreasMejoraList(),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHealthScoreCard() {
    final score = insights.puntuacionSaludFinanciera;
    Color color;
    String message;
    IconData icon;

    if (score >= 80) {
      color = Colors.green;
      message = '¡Excelente!';
      icon = Icons.stars;
    } else if (score >= 60) {
      color = Colors.blue;
      message = 'Muy Bien';
      icon = Icons.thumb_up;
    } else if (score >= 40) {
      color = Colors.orange;
      message = 'Puede Mejorar';
      icon = Icons.warning_amber;
    } else {
      color = Colors.red;
      message = 'Necesita Atención';
      icon = Icons.error_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 64, color: Colors.white),
          const SizedBox(height: 12),
          const Text(
            'Salud Financiera',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$score/100',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          insights.resumenEjecutivo,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildFortalezasList() {
    return Column(
      children: insights.fortalezas.map((fortaleza) {
        return Card(
          elevation: 1,
          color: Colors.green[50],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green),
            ),
            title: Text(
              fortaleza,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInsightsList() {
    return Column(
      children: insights.insights.map((insight) {
        return _buildInsightCard(insight);
      }).toList(),
    );
  }

  Widget _buildInsightCard(AIInsight insight) {
    Color color;
    IconData icon;
    Color bgColor;

    switch (insight.tipo.toLowerCase()) {
      case 'alerta':
        color = Colors.orange;
        icon = Icons.warning_amber;
        bgColor = Colors.orange[50]!;
        break;
      case 'felicitacion':
        color = Colors.green;
        icon = Icons.celebration;
        bgColor = Colors.green[50]!;
        break;
      case 'recomendacion':
        color = Colors.blue;
        icon = Icons.lightbulb_outline;
        bgColor = Colors.blue[50]!;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info_outline;
        bgColor = Colors.grey[50]!;
    }

    return Card(
      elevation: 2,
      color: bgColor,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.categoria,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              insight.mensaje,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (insight.recomendacion.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.arrow_forward, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.recomendacion,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (insight.impactoEstimado.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Impacto: ${insight.impactoEstimado}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProyeccionesList() {
    return Column(
      children: insights.proyecciones.map((proyeccion) {
        return _buildProyeccionCard(proyeccion);
      }).toList(),
    );
  }

  Widget _buildProyeccionCard(AIProjection proyeccion) {
    final confianzaPercent = (proyeccion.confianza * 100).toInt();
    final confianzaColor = proyeccion.confianza >= 0.8
        ? Colors.green
        : proyeccion.confianza >= 0.6
            ? Colors.blue
            : Colors.orange;

    return Card(
      elevation: 2,
      color: Colors.purple[50],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    proyeccion.descripcion,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purple[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event, size: 16, color: Colors.purple),
                      const SizedBox(width: 4),
                      Text(
                        _formatFecha(proyeccion.fechaEstimada),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: confianzaColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: confianzaColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.show_chart, size: 16, color: confianzaColor),
                      const SizedBox(width: 4),
                      Text(
                        '$confianzaPercent% confianza',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: confianzaColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              proyeccion.detalles,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecomendacionesList() {
    return Column(
      children: insights.recomendaciones.asMap().entries.map((entry) {
        final index = entry.key + 1;
        final recomendacion = entry.value;
        return Card(
          elevation: 1,
          color: Colors.amber[50],
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recomendacion,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAreasMejoraList() {
    return Column(
      children: insights.areasMejora.map((area) {
        return Card(
          elevation: 1,
          color: Colors.red[50],
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.trending_up, color: Colors.red, size: 20),
            ),
            title: Text(
              area,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${date.day} ${meses[date.month - 1]} ${date.year}';
    } catch (e) {
      return fecha;
    }
  }
}

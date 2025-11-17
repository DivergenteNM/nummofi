import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;
import '../core/providers/finance_provider.dart';
import '../core/services/ai_report_service.dart';
import '../core/services/ai_analysis_service.dart';
import '../core/services/auth_service.dart';
import '../core/utils/currency_formatter.dart';
import '../data/models/monthly_ai_report_model.dart';
import 'ai_insights_screen.dart';
import '../l10n/app_localizations.dart';

/// Pantalla para cerrar el mes y generar el reporte para IA
class CloseMonthScreen extends StatefulWidget {
  const CloseMonthScreen({super.key});

  @override
  State<CloseMonthScreen> createState() => _CloseMonthScreenState();
}

class _CloseMonthScreenState extends State<CloseMonthScreen> {
  bool _isGenerating = false;
  MonthlyAIReportModel? _generatedReport;
  String? _jsonOutput;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final currentMonth = provider.currentMonth;
    final currentYear = provider.currentYear;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.monthlyAIReport),
        backgroundColor: Colors.deepPurple,
      ),
      body: _generatedReport == null
          ? _buildGenerateView(context, currentMonth, currentYear)
          : _buildReportView(context),
    );
  }

  Widget _buildGenerateView(BuildContext context, int month, int year) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 100,
              color: Colors.deepPurple[300],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.generateMonthlyAIReport,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.generateCompleteReport,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              intl.DateFormat('MMMM y', Localizations.localeOf(context).toString())
                  .format(DateTime(year, month, 1)),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 32),
            
            if (!_isGenerating)
              ElevatedButton.icon(
                onPressed: () => _generateReport(context, month, year),
                icon: const Icon(Icons.play_arrow),
                label: Text(AppLocalizations.of(context)!.generateMonthlyAIReport),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              )
            else
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.generating),
                ],
              ),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.whatIncludes,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(AppLocalizations.of(context)!.summaryIncomeExpenses),
                  _buildInfoItem(AppLocalizations.of(context)!.categoryBreakdown),
                  _buildInfoItem(AppLocalizations.of(context)!.savingsGoalsTracking),
                  _buildInfoItem(AppLocalizations.of(context)!.channelAnalysis),
                  _buildInfoItem(AppLocalizations.of(context)!.aiIntelligentAnalysis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildReportView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con éxito
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green[400]!, Colors.green[600]!],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 64),
                const SizedBox(height: 12),
                Text(
                  AppLocalizations.of(context)!.reportGeneratedSuccessfully,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.yourDataIsReady,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Resumen visual
          _buildSummaryCard(),
          const SizedBox(height: 16),

          // Detalles por categorías (reemplaza la sección JSON)
          _buildCategoriesBreakdown(),
          const SizedBox(height: 16),

          // Información de canales
          _buildChannelsInfo(),
          const SizedBox(height: 24),

          // Botones de acción
          // Botón principal: Analizar con IA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _analyzeWithAI(context),
              icon: const Icon(Icons.psychology, size: 24),
              label: Text(AppLocalizations.of(context)!.analyzeWithAI),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Botón secundario: Ver Historial
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Navegar a pantalla de historial de reportes
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.viewReportsHistory),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: Text(AppLocalizations.of(context)!.viewReportsHistory),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Opciones avanzadas en un menú desplegable
          ExpansionTile(
            leading: const Icon(Icons.more_horiz),
            title: Text(AppLocalizations.of(context)!.advancedOptions),
            children: [
              ListTile(
                leading: const Icon(Icons.code),
                title: Text(AppLocalizations.of(context)!.copyTechnicalData),
                onTap: _copyJsonToClipboard,
              ),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: Text(AppLocalizations.of(context)!.generateAIReport),
                onTap: () {
                  setState(() {
                    _generatedReport = null;
                    _jsonOutput = null;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final report = _generatedReport!;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.summary} - ${report.mes}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              '💵 ${AppLocalizations.of(context)!.totalIncome}',
              CurrencyFormatter.formatCurrency(report.ingresosTotal),
              Colors.green,
            ),
            _buildSummaryRow(
              '💸 ${AppLocalizations.of(context)!.totalExpenses}',
              CurrencyFormatter.formatCurrency(report.egresosTotal),
              Colors.red,
            ),
            _buildSummaryRow(
              '💰 ${AppLocalizations.of(context)!.balance}',
              CurrencyFormatter.formatCurrency(report.balanceNeto),
              report.balanceNeto >= 0 ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              '🎯 ${AppLocalizations.of(context)!.savingsGoals}',
              '${report.metas.length} ${AppLocalizations.of(context)!.activeSavings}',
              Colors.blue,
            ),
            _buildSummaryRow(
              '📊 ${AppLocalizations.of(context)!.savedInGoals}',
              CurrencyFormatter.formatCurrency(report.ahorradoEnMetas),
              Colors.purple,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              '🔢 ${AppLocalizations.of(context)!.totalTransactions}',
              '${report.totalTransacciones}',
              Colors.orange,
            ),
            _buildSummaryRow(
              '📈 ${AppLocalizations.of(context)!.savingsPercentage}',
              '${report.porcentajeAhorro.toStringAsFixed(1)}%',
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesBreakdown() {
    final report = _generatedReport!;
    
    // Top 5 categorías de egresos
    final topExpenses = report.egresosPorCategoria.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5Expenses = topExpenses.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.topCategories,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (top5Expenses.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    AppLocalizations.of(context)!.noExpensesRecorded,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...top5Expenses.map((entry) {
                final percentage = report.egresosTotal > 0 
                    ? (entry.value / report.egresosTotal * 100) 
                    : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.formatCurrency(entry.value),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              color: Colors.red[400],
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelsInfo() {
    final report = _generatedReport!;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.channelDistribution,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (report.saldoPorCanal.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    AppLocalizations.of(context)!.noChannelsRecorded,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...report.saldoPorCanal.entries.map((entry) {
                final isPositive = entry.value >= 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPositive ? Colors.green[200]! : Colors.red[200]!,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getChannelIcon(entry.key),
                              color: isPositive ? Colors.green[700] : Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyFormatter.formatCurrency(entry.value),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isPositive ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  IconData _getChannelIcon(String channel) {
    switch (channel.toLowerCase()) {
      case 'nequi':
        return Icons.phone_android;
      case 'nubank':
        return Icons.credit_card;
      case 'efectivo':
        return Icons.money;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Future<void> _generateReport(BuildContext context, int month, int year) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final userId = AuthService().currentUser?.uid;
      if (userId == null) {
        throw Exception(AppLocalizations.of(context)!.notAuthenticated);
      }

      final aiReportService = AIReportService(
        appId: 'default-app-id', // Mismo que usas en tu app
        userId: userId,
      );

      // Generar el reporte
      final report = await aiReportService.generateMonthlyReport(
        month: month,
        year: year,
      );

      // Guardar en Firestore para historial
      await aiReportService.saveReport(report);

      // Convertir a JSON formateado
      final jsonMap = report.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);

      setState(() {
        _generatedReport = report;
        _jsonOutput = jsonString;
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.reportGeneratedSuccess),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorGeneratingReport}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyJsonToClipboard() {
    if (_jsonOutput != null) {
      Clipboard.setData(ClipboardData(text: _jsonOutput!));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.technicalDataCopied),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _analyzeWithAI(BuildContext context) async {
    if (_generatedReport == null) return;

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.analyzingWithAI),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.pleaseWait,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final aiService = AIAnalysisService();
      final insights = await aiService.analyzeReport(_generatedReport!);

      if (context.mounted) {
        // Cerrar diálogo de carga
        Navigator.pop(context);

        // Navegar a la pantalla de insights
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIInsightsScreen(insights: insights),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Cerrar diálogo de carga
        Navigator.pop(context);

        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorAnalyzingAI}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: AppLocalizations.of(context)!.viewDetails,
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(AppLocalizations.of(context)!.errorAnalyzingAI),
                    content: SingleChildScrollView(
                      child: Text(e.toString()),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }
}

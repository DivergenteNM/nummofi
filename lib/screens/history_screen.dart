import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/finance_provider.dart';
import '../core/utils/currency_formatter.dart';
import '../data/models/monthly_summary_model.dart';
import 'package:intl/intl.dart' as intl;
import '../l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? expandedSummaryId;
  bool isClosingMonth = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.history),
        actions: [
          // Botón para cerrar el mes actual
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton.icon(
              onPressed: isClosingMonth
                  ? null
                  : () => _showCloseMonthDialog(context, provider),
              icon: isClosingMonth
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.lock_clock),
              label: Text(isClosingMonth ? AppLocalizations.of(context)!.pleaseWait : AppLocalizations.of(context)!.monthlyReport),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: provider.monthlySummaries.isEmpty
          ? _buildEmptyState(context)
          : _buildSummariesList(context, provider, theme),
    );
  }

  // Estado vacío cuando no hay cierres mensuales
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noTransactions,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.viewReportsHistory,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCloseMonthDialog(context, Provider.of<FinanceProvider>(context, listen: false)),
            icon: const Icon(Icons.lock_clock),
            label: Text(AppLocalizations.of(context)!.monthlyReport),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // Lista de resúmenes mensuales
  Widget _buildSummariesList(BuildContext context, FinanceProvider provider, ThemeData theme) {
    // Ordenar por año y mes descendente (más reciente primero)
    final sortedSummaries = List<MonthlySummaryModel>.from(provider.monthlySummaries)
      ..sort((a, b) {
        if (a.year != b.year) return b.year.compareTo(a.year);
        return b.month.compareTo(a.month);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedSummaries.length,
      itemBuilder: (context, index) {
        final summary = sortedSummaries[index];
        final isExpanded = expandedSummaryId == summary.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Column(
            children: [
              // Encabezado del resumen (siempre visible)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getMonthColor(summary.month).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: _getMonthColor(summary.month),
                  ),
                ),
                title: Text(
                  _getMonthName(context, summary.month, summary.year),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  _getSummarySubtitle(summary),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Balance del mes
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.balance,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatCurrency(summary.totalIncome - summary.totalExpenses),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: (summary.totalIncome - summary.totalExpenses) >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Icono expandir/colapsar
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    expandedSummaryId = isExpanded ? null : summary.id;
                  });
                },
              ),

              // Detalles expandibles
              if (isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildSummaryDetails(context, summary, theme),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Detalles del resumen mensual
  Widget _buildSummaryDetails(BuildContext context, MonthlySummaryModel summary, ThemeData theme) {
    final balance = summary.totalIncome - summary.totalExpenses;
    final savingsRate = summary.totalIncome > 0
        ? ((balance / summary.totalIncome) * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumen financiero
        Text(
          AppLocalizations.of(context)!.generalSummary,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow(
          context,
          AppLocalizations.of(context)!.totalIncome,
          CurrencyFormatter.formatCurrency(summary.totalIncome),
          Icons.arrow_downward,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          AppLocalizations.of(context)!.totalExpenses,
          CurrencyFormatter.formatCurrency(summary.totalExpenses),
          Icons.arrow_upward,
          Colors.red,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          AppLocalizations.of(context)!.balance,
          CurrencyFormatter.formatCurrency(balance),
          Icons.account_balance_wallet,
          balance >= 0 ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          context,
          AppLocalizations.of(context)!.savingsPercentage,
          '${savingsRate.toStringAsFixed(1)}%',
          Icons.savings,
          savingsRate >= 20 ? Colors.green : Colors.orange,
        ),

        const Divider(height: 24),

        // Saldos por canal
        Text(
          AppLocalizations.of(context)!.currentBalances,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildBalancesComparison(context, summary),

        // Comparación con presupuesto (si existe)
        if (summary.budgetComparison.isNotEmpty) ...[
          const Divider(height: 24),
          Text(
            AppLocalizations.of(context)!.budgetSummary,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildBudgetComparison(context, summary),
        ],
      ],
    );
  }

  // Fila de detalle
  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
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
    );
  }

  // Comparación de saldos por canal
  Widget _buildBalancesComparison(BuildContext context, MonthlySummaryModel summary) {
    final channels = {...summary.initialBalances.keys, ...summary.finalBalances.keys}.toList();

    if (channels.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noBalancesAvailable,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      );
    }

    return Column(
      children: channels.map((channel) {
        final initial = summary.initialBalances[channel] ?? 0;
        final final_ = summary.finalBalances[channel] ?? 0;
        final difference = final_ - initial;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getChannelIcon(channel),
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      channel,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.planned,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatCurrency(initial),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.actual,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatCurrency(final_),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: difference >= 0 ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${difference >= 0 ? '+' : ''}${CurrencyFormatter.formatCurrency(difference)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: difference >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Comparación con presupuesto
  Widget _buildBudgetComparison(BuildContext context, MonthlySummaryModel summary) {
    if (summary.budgetComparison.isEmpty) {
      return Text(
        AppLocalizations.of(context)!.noBudgets,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      );
    }

    // Extraer datos de la comparación presupuestaria
    final incomeBudget = summary.budgetComparison['income'] as Map<String, dynamic>? ?? {};
    final expenseBudget = summary.budgetComparison['expense'] as Map<String, dynamic>? ?? {};
    
    final plannedIncome = (incomeBudget['planned'] ?? 0).toDouble();
    final actualIncome = (incomeBudget['actual'] ?? 0).toDouble();
    final plannedExpense = (expenseBudget['planned'] ?? 0).toDouble();
    final actualExpense = (expenseBudget['actual'] ?? 0).toDouble();
    
    final expensePercentage = plannedExpense > 0 ? (actualExpense / plannedExpense * 100) : 0;

    return Column(
      children: [
        // Comparación de ingresos
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.incomes,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.planned, style: const TextStyle(fontSize: 12)),
                  Text(
                    CurrencyFormatter.formatCurrency(plannedIncome),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.actual, style: const TextStyle(fontSize: 12)),
                  Text(
                    CurrencyFormatter.formatCurrency(actualIncome),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Comparación de egresos
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: expensePercentage > 100 ? Colors.red[50] : Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: expensePercentage > 100 ? Colors.red[200]! : Colors.green[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.expenses,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.planned, style: const TextStyle(fontSize: 12)),
                  Text(
                    CurrencyFormatter.formatCurrency(plannedExpense),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.actual, style: const TextStyle(fontSize: 12)),
                  Text(
                    CurrencyFormatter.formatCurrency(actualExpense),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: expensePercentage > 100 ? Colors.red : Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (expensePercentage / 100).clamp(0, 1),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  expensePercentage > 100 ? Colors.red : Colors.green,
                ),
                minHeight: 8,
              ),
              const SizedBox(height: 4),
              Text(
                '${expensePercentage.toStringAsFixed(1)}% ${AppLocalizations.of(context)!.budgetSummary}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: expensePercentage > 100 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Diálogo para confirmar cierre de mes
  void _showCloseMonthDialog(BuildContext context, FinanceProvider provider) {
    final now = DateTime.now();
    final monthName = _getMonthName(context, now.month, now.year);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_clock, color: Colors.orange),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.monthlyReport),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿${AppLocalizations.of(context)!.confirm}? $monthName',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta acción creará un resumen permanente con:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildBulletPoint(AppLocalizations.of(context)!.allTransactions),
            _buildBulletPoint(AppLocalizations.of(context)!.channels),
            _buildBulletPoint(AppLocalizations.of(context)!.budgetSummary),
            _buildBulletPoint(AppLocalizations.of(context)!.savings),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.viewDetails,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _closeMonth(context, provider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.monthlyReport),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Cerrar el mes actual
  Future<void> _closeMonth(BuildContext context, FinanceProvider provider) async {
    setState(() => isClosingMonth = true);

    try {
      // Llamar al método del provider que maneja toda la lógica
      await provider.closeMonth();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.success),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('${AppLocalizations.of(context)!.error}: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isClosingMonth = false);
      }
    }
  }

  // Utilidades
  String _getMonthName(BuildContext context, int month, int year) {
    final locale = Localizations.localeOf(context).toString();
    return intl.DateFormat('MMMM y', locale).format(DateTime(year, month, 1));
  }

  String _getSummarySubtitle(MonthlySummaryModel summary) {
    final balance = summary.totalIncome - summary.totalExpenses;
    if (balance >= 0) {
      return 'Superávit • ${summary.initialBalances.length} canales';
    } else {
      return 'Déficit • ${summary.initialBalances.length} canales';
    }
  }

  Color _getMonthColor(int month) {
    final colors = [
      Colors.blue, Colors.purple, Colors.green, Colors.orange,
      Colors.red, Colors.teal, Colors.indigo, Colors.pink,
      Colors.amber, Colors.cyan, Colors.lime, Colors.deepOrange,
    ];
    return colors[(month - 1) % colors.length];
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
}

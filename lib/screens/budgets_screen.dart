import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/providers/finance_provider.dart';
import '../data/models/budget_model.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/number_formatter.dart';
import '../core/theme/app_theme.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  Map<String, double> _incomeBudget = {};
  Map<String, double> _expenseBudget = {};
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBudget();
  }

  void _loadCurrentBudget() {
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    final currentBudget = provider.currentMonthBudget;

    setState(() {
      _incomeBudget = currentBudget?.incomes ?? {};
      _expenseBudget = currentBudget?.expenses ?? {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    // Calcular totales
    final totalPlannedIncome = _incomeBudget.values.fold(0.0, (sum, val) => sum + val);
    final totalActualIncome = provider.totalIncome;

    final totalPlannedExpense = _expenseBudget.values.fold(0.0, (sum, val) => sum + val);
    final totalActualExpense = provider.totalExpenses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            l10n.monthlyBudgets,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),

          // Resumen de Ingresos y Egresos
          _buildSummaryCards(
            context,
            totalPlannedIncome,
            totalActualIncome,
            totalPlannedExpense,
            totalActualExpense,
          ),
          const SizedBox(height: 24),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
                  label: Text(_isEditing ? 'Ver Resumen' : 'Editar Presupuestos'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveBudgets,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          // Contenido según modo
          if (_isEditing)
            _buildEditMode()
          else
            _buildViewMode(provider),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    double plannedIncome,
    double actualIncome,
    double plannedExpense,
    double actualExpense,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.incomes,
            plannedIncome,
            actualIncome,
            AppColors.income,
            Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            l10n.expenses,
            plannedExpense,
            actualExpense,
            AppColors.expense,
            Icons.arrow_upward,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    double planned,
    double actual,
    Color color,
    IconData icon,
  ) {
    final percentage = planned > 0 ? (actual / planned * 100) : 0.0;
    final isOverBudget = actual > planned && planned > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  l10n.planned,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
            Text(
              CurrencyFormatter.formatCurrency(planned),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Text(
                  l10n.actual,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                );
              },
            ),
            Text(
              CurrencyFormatter.formatCurrency(actual),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isOverBudget ? AppColors.error : AppColors.success,
              ),
            ),
            if (planned > 0) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                color: isOverBudget ? AppColors.error : color,
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isOverBudget ? AppColors.error : Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Presupuestos de Ingresos
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.incomeBudget,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                ...AppConstants.categoriasIngreso.map((category) {
                  return _buildBudgetInput(
                    category,
                    _incomeBudget[category] ?? 0,
                    (value) {
                      setState(() {
                        _incomeBudget[category] = value;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Presupuestos de Egresos
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.expenseBudget,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                ...AppConstants.categoriasEgreso.map((category) {
                  return _buildBudgetInput(
                    category,
                    _expenseBudget[category] ?? 0,
                    (value) {
                      setState(() {
                        _expenseBudget[category] = value;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetInput(
    String category,
    double currentValue,
    Function(double) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              category,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: currentValue > 0 ? formatAmountWithThousands(currentValue.toInt()) : '',
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsSeparatorFormatter()],
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                prefixText: '\$ ',
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                final numValue = value.isEmpty ? 0.0 : parseAmountFromFormatted(value);
                onChanged(numValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMode(FinanceProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Comparación de Egresos
        _buildCategoryComparison(
          context,
          l10n.expenseComparison,
          AppConstants.categoriasEgreso,
          _expenseBudget,
          provider.expensesByCategory,
          AppColors.expense,
        ),
        const SizedBox(height: 24),
        // Comparación de Ingresos
        _buildCategoryComparison(
          context,
          l10n.incomeComparison,
          AppConstants.categoriasIngreso,
          _incomeBudget,
          _getIncomeByCategory(provider),
          AppColors.income,
        ),
      ],
    );
  }

  Map<String, double> _getIncomeByCategory(FinanceProvider provider) {
    Map<String, double> result = {};
    for (var transaction in provider.currentMonthTransactions) {
      if (transaction.type == 'Ingreso' && transaction.category != null) {
        result[transaction.category!] = 
            (result[transaction.category!] ?? 0) + transaction.amount;
      }
    }
    return result;
  }

  Widget _buildCategoryComparison(
    BuildContext context,
    String title,
    List<String> categories,
    Map<String, double> budgetMap,
    Map<String, double> actualMap,
    Color color,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            if (budgetMap.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.edit_note, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noBudgets,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                        child: Text(l10n.setBudgets),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...categories.where((cat) => budgetMap[cat] != null && budgetMap[cat]! > 0).map((category) {
                final budgeted = budgetMap[category] ?? 0;
                final actual = actualMap[category] ?? 0;
                final percentage = budgeted > 0 ? (actual / budgeted * 100) : 0.0;
                final isOverBudget = actual > budgeted;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '${CurrencyFormatter.formatCurrency(actual)} / ${CurrencyFormatter.formatCurrency(budgeted)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isOverBudget ? AppColors.error : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: (percentage / 100).clamp(0.0, 1.0),
                              backgroundColor: Colors.grey[200],
                              color: isOverBudget ? AppColors.error : color,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 50,
                            child: Text(
                              '${percentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isOverBudget ? AppColors.error : Colors.grey[700],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      if (isOverBudget)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Sobrepresupuesto: ${CurrencyFormatter.formatCurrency(actual - budgeted)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
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

  Future<void> _saveBudgets() async {
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    try {
      final budget = BudgetModel(
        month: provider.currentMonth,
        year: provider.currentYear,
        incomes: _incomeBudget,
        expenses: _expenseBudget,
      );

      await provider.saveBudget(budget);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.budgetsSavedSuccessfully),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorSaving}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/providers/finance_provider.dart';
import '../core/utils/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../data/models/transaction_model.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'month'; // month, 3months, year
  
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título
          Text(
            'Reportes y Gráficas',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Selector de período
          _buildPeriodSelector(),
          const SizedBox(height: 24),

          // Estadísticas generales
          _buildGeneralStats(provider),
          const SizedBox(height: 24),

          // Gráfica de distribución de egresos (Dona)
          _buildExpenseDistributionChart(provider),
          const SizedBox(height: 24),

          // Gráfica de evolución temporal (Líneas)
          _buildTemporalEvolutionChart(provider),
          const SizedBox(height: 24),

          // Top categorías
          _buildTopCategories(provider),
          const SizedBox(height: 24),

          // Comparativa de canales
          _buildChannelComparison(provider),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Período de Análisis',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'month',
                  label: Text('Este Mes', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.calendar_today, size: 16),
                ),
                ButtonSegment(
                  value: '3months',
                  label: Text('Trimestre', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.calendar_month, size: 16),
                ),
                ButtonSegment(
                  value: 'year',
                  label: Text('Este Año', style: TextStyle(fontSize: 12)),
                  icon: Icon(Icons.calendar_view_month, size: 16),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedPeriod = newSelection.first;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralStats(FinanceProvider provider) {
    final transactions = _getFilteredTransactions(provider);
    final totalIncome = transactions
        .where((t) => t.type == 'Ingreso')
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => t.type == 'Egreso')
        .fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIncome - totalExpenses;
    final savingsRate = totalIncome > 0 ? (balance / totalIncome * 100) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Estadísticas Generales',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  'Ingresos Totales',
                  CurrencyFormatter.formatCurrency(totalIncome),
                  Icons.arrow_downward,
                  AppColors.income,
                ),
                _buildStatCard(
                  'Egresos Totales',
                  CurrencyFormatter.formatCurrency(totalExpenses),
                  Icons.arrow_upward,
                  AppColors.expense,
                ),
                _buildStatCard(
                  'Balance',
                  CurrencyFormatter.formatCurrency(balance),
                  Icons.account_balance_wallet,
                  balance >= 0 ? AppColors.success : AppColors.error,
                ),
                _buildStatCard(
                  'Tasa de Ahorro',
                  '${savingsRate.toStringAsFixed(1)}%',
                  Icons.savings,
                  savingsRate >= 20 ? AppColors.success : AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseDistributionChart(FinanceProvider provider) {
    final transactions = _getFilteredTransactions(provider);
    final expensesByCategory = <String, double>{};

    for (var transaction in transactions) {
      if (transaction.type == 'Egreso' && transaction.category != null) {
        expensesByCategory[transaction.category!] =
            (expensesByCategory[transaction.category!] ?? 0) + transaction.amount;
      }
    }

    if (expensesByCategory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Distribución de Egresos',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay egresos para mostrar',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final sortedEntries = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Distribución de Egresos',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Gráfica de dona
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: _buildPieSections(sortedEntries),
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Leyenda
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 250,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: sortedEntries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final color = _getCategoryColor(index);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    category.key,
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Lista de categorías con porcentajes
            ...sortedEntries.take(5).map((entry) {
              final total = expensesByCategory.values.fold(0.0, (a, b) => a + b);
              final percentage = (entry.value / total * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.formatCurrency(entry.value),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(List<MapEntry<String, double>> entries) {
    final total = entries.fold(0.0, (sum, entry) => sum + entry.value);
    
    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final percentage = (data.value / total * 100);
      const radius = 60.0;

      return PieChartSectionData(
        color: _getCategoryColor(index),
        value: data.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(int index) {
    final colors = [
      const Color(0xFFEF4444), // red
      const Color(0xFFF59E0B), // amber
      const Color(0xFF10B981), // green
      const Color(0xFF3B82F6), // blue
      const Color(0xFF8B5CF6), // violet
      const Color(0xFFEC4899), // pink
      const Color(0xFF14B8A6), // teal
      const Color(0xFFF97316), // orange
      const Color(0xFF06B6D4), // cyan
    ];
    return colors[index % colors.length];
  }

  Widget _buildTemporalEvolutionChart(FinanceProvider provider) {
    final monthlyData = _getMonthlyData(provider);

    if (monthlyData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.show_chart, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay datos suficientes para mostrar evolución',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Evolución de Ingresos y Egresos',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                monthlyData[value.toInt()]['label'],
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (monthlyData.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxY(monthlyData) * 1.2,
                  lineBarsData: [
                    // Línea de ingresos
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['income'],
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppColors.income,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.income.withOpacity(0.1),
                      ),
                    ),
                    // Línea de egresos
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value['expense'],
                        );
                      }).toList(),
                      isCurved: true,
                      color: AppColors.expense,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.expense.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Leyenda
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Ingresos', AppColors.income),
                const SizedBox(width: 24),
                _buildLegendItem('Egresos', AppColors.expense),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildTopCategories(FinanceProvider provider) {
    final transactions = _getFilteredTransactions(provider);
    
    // Top egresos
    final expensesByCategory = <String, double>{};
    for (var transaction in transactions) {
      if (transaction.type == 'Egreso' && transaction.category != null) {
        expensesByCategory[transaction.category!] =
            (expensesByCategory[transaction.category!] ?? 0) + transaction.amount;
      }
    }
    final topExpenses = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top ingresos
    final incomesByCategory = <String, double>{};
    for (var transaction in transactions) {
      if (transaction.type == 'Ingreso' && transaction.category != null) {
        incomesByCategory[transaction.category!] =
            (incomesByCategory[transaction.category!] ?? 0) + transaction.amount;
      }
    }
    final topIncomes = incomesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Top Categorías',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildTopList(
              'Mayores Ingresos',
              topIncomes.take(5).toList(),
              AppColors.income,
              Icons.trending_down,
            ),
            const SizedBox(height: 24),
            _buildTopList(
              'Mayores Egresos',
              topExpenses.take(5).toList(),
              AppColors.expense,
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopList(
    String title,
    List<MapEntry<String, double>> items,
    Color color,
    IconData icon,
  ) {
    if (items.isEmpty) {
      return Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sin datos',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      );
    }

    final total = items.fold(0.0, (sum, item) => sum + item.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final percentage = (item.value / total * 100);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.key,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
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
                        color: color,
                        minHeight: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.formatCurrency(item.value),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildChannelComparison(FinanceProvider provider) {
    final transactions = _getFilteredTransactions(provider);
    final channelData = <String, Map<String, double>>{};

    // Calcular ingresos y egresos por canal
    for (var transaction in transactions) {
      String? channel;
      if (transaction.type == 'Transferencia') {
        continue; // Ignorar transferencias para esta vista
      } else {
        channel = transaction.channel;
      }

      if (channel != null) {
        channelData[channel] ??= {'income': 0, 'expense': 0};
        if (transaction.type == 'Ingreso') {
          channelData[channel]!['income'] = 
              channelData[channel]!['income']! + transaction.amount;
        } else if (transaction.type == 'Egreso') {
          channelData[channel]!['expense'] = 
              channelData[channel]!['expense']! + transaction.amount;
        }
      }
    }

    if (channelData.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.account_balance, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay movimientos por canal',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Comparativa por Canal',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...channelData.entries.map((entry) {
              final channel = entry.key;
              final income = entry.value['income']!;
              final expense = entry.value['expense']!;
              final balance = income - expense;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getChannelIcon(channel),
                          color: _getChannelColor(channel),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          channel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          CurrencyFormatter.formatCurrency(balance),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: balance >= 0 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildChannelBar(
                            'Ingresos',
                            income,
                            AppColors.income,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildChannelBar(
                            'Egresos',
                            expense,
                            AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelBar(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.formatCurrency(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getChannelIcon(String channel) {
    switch (channel) {
      case 'Nequi':
        return Icons.phone_android;
      case 'NuBank':
        return Icons.credit_card;
      case 'Efectivo':
        return Icons.money;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getChannelColor(String channel) {
    switch (channel) {
      case 'Nequi':
        return AppColors.nequi;
      case 'NuBank':
        return AppColors.nubank;
      case 'Efectivo':
        return AppColors.cash;
      default:
        return Colors.grey;
    }
  }

  // Funciones auxiliares
  List<TransactionModel> _getFilteredTransactions(FinanceProvider provider) {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case 'month':
        return provider.currentMonthTransactions;
      
      case '3months':
        final threeMonthsAgo = DateTime(now.year, now.month - 2, 1);
        return provider.transactions.where((t) {
          return t.date.isAfter(threeMonthsAgo);
        }).toList();
      
      case 'year':
        final yearStart = DateTime(now.year, 1, 1);
        return provider.transactions.where((t) {
          return t.date.isAfter(yearStart);
        }).toList();
      
      default:
        return provider.currentMonthTransactions;
    }
  }

  List<Map<String, dynamic>> _getMonthlyData(FinanceProvider provider) {
    final transactions = provider.transactions;
    final monthlyMap = <String, Map<String, double>>{};

    for (var transaction in transactions) {
      final key = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
      monthlyMap[key] ??= {'income': 0, 'expense': 0};
      
      if (transaction.type == 'Ingreso') {
        monthlyMap[key]!['income'] = monthlyMap[key]!['income']! + transaction.amount;
      } else if (transaction.type == 'Egreso') {
        monthlyMap[key]!['expense'] = monthlyMap[key]!['expense']! + transaction.amount;
      }
    }

    final sortedKeys = monthlyMap.keys.toList()..sort();
    final limitedKeys = sortedKeys.length > 6 
        ? sortedKeys.sublist(sortedKeys.length - 6)
        : sortedKeys;

    return limitedKeys.map((key) {
      final parts = key.split('-');
      final month = int.parse(parts[1]);
      return {
        'label': _getMonthShortName(month),
        'income': monthlyMap[key]!['income']!,
        'expense': monthlyMap[key]!['expense']!,
      };
    }).toList();
  }

  String _getMonthShortName(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    double max = 0;
    for (var item in data) {
      if (item['income'] > max) max = item['income'];
      if (item['expense'] > max) max = item['expense'];
    }
    return max;
  }
}

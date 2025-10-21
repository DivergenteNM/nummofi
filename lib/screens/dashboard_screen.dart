import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/providers/finance_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            'Resumen General',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),

          // Saldos Actuales
          Text(
            'Saldos Actuales',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          _buildBalanceCards(provider),
          const SizedBox(height: 24),

          // Movimiento Mensual
          Text(
            'Movimiento Mensual',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          _buildMonthlyMovementChart(provider),
          const SizedBox(height: 24),

          // Flujo por Canal
          Text(
            'Flujo de dinero por Canal',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          _buildChannelFlowChart(provider),
        ],
      ),
    );
  }

  Widget _buildBalanceCards(FinanceProvider provider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: provider.channelBalances.length,
      itemBuilder: (context, index) {
        final channel = provider.channelBalances[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  channel.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    CurrencyFormatter.formatCurrency(channel.balance),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: channel.balance >= 0
                          ? AppColors.income
                          : AppColors.expense,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyMovementChart(FinanceProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: [provider.totalIncome, provider.totalExpenses]
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      switch (value.toInt()) {
                        case 0:
                          return const Text('Ingresos');
                        case 1:
                          return const Text('Egresos');
                        default:
                          return const Text('');
                      }
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(
                      toY: provider.totalIncome,
                      color: AppColors.income,
                      width: 40,
                    ),
                  ],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(
                      toY: provider.totalExpenses,
                      color: AppColors.expense,
                      width: 40,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelFlowChart(FinanceProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: provider.channelBalances
                      .map((c) => c.balance.abs())
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
              minY: -provider.channelBalances
                      .map((c) => c.balance.abs())
                      .reduce((a, b) => a > b ? a : b) *
                  1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < provider.channelBalances.length) {
                        return Text(
                          provider.channelBalances[value.toInt()].name,
                          style: const TextStyle(fontSize: 12),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: provider.channelBalances
                  .asMap()
                  .entries
                  .map((entry) => BarChartGroupData(
                        x: entry.key,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value.balance,
                            color: _getChannelColor(entry.value.name),
                            width: 40,
                          ),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getChannelColor(String channelName) {
    switch (channelName) {
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
}

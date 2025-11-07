import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/providers/finance_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/currency_formatter.dart';
import 'close_month_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
            'Resumen General',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Botón para cerrar mes y generar reporte de IA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Obtener el provider antes de navegar
                final financeProvider = Provider.of<FinanceProvider>(context, listen: false);
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (newContext) => ChangeNotifierProvider<FinanceProvider>.value(
                      value: financeProvider,
                      child: const CloseMonthScreen(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Generar Reporte IA'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Saldos Actuales
          Text(
            'Saldos Actuales',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildBalanceCards(provider),
          const SizedBox(height: 24),

          // Movimiento Mensual
          Text(
            'Movimiento Mensual',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildMonthlyMovementChart(provider),
          const SizedBox(height: 24),

          // Flujo por Canal
          Text(
            'Distribución por Canal',
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
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
        child: Column(
          children: [
            SizedBox(
              height: 280,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: [provider.totalIncome, provider.totalExpenses]
                          .reduce((a, b) => a > b ? a : b) *
                      1.3,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Ingresos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            case 1:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Egresos',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
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
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: provider.totalIncome > 0 
                        ? (provider.totalIncome / 4) 
                        : 100000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: provider.totalIncome > 0 ? provider.totalIncome : 0.1,
                          color: AppColors.income,
                          width: 60,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: provider.totalExpenses > 0 ? provider.totalExpenses : 0.1,
                          color: AppColors.expense,
                          width: 60,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Valores estáticos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.income,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatCurrency(provider.totalIncome),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.income,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.expense,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Egresos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatCurrency(provider.totalExpenses),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.expense,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelFlowChart(FinanceProvider provider) {
    // Filtrar canales con saldo positivo para la gráfica
    final channelsWithBalance = provider.channelBalances
        .where((c) => c.balance > 0)
        .toList();

    if (channelsWithBalance.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No hay saldos disponibles',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final totalBalance = channelsWithBalance.fold(0.0, (sum, c) => sum + c.balance);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  // Gráfica de dona
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 50,
                        sections: channelsWithBalance.map((channel) {
                          final percentage = (channel.balance / totalBalance * 100);
                          return PieChartSectionData(
                            color: _getChannelColor(channel.name),
                            value: channel.balance,
                            title: '${percentage.toStringAsFixed(1)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Leyenda con valores
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: channelsWithBalance.map((channel) {
                        final percentage = (channel.balance / totalBalance * 100);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getChannelColor(channel.name),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      channel.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatCurrency(channel.balance),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: _getChannelColor(channel.name),
                                      ),
                                    ),
                                    Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Total
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Disponible',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatCurrency(totalBalance),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
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

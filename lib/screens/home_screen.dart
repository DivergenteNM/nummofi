import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/providers/finance_provider.dart';
import '../core/theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'transactions_screen.dart';
import 'budgets_screen.dart';
import 'reports_screen.dart';
import 'history_screen.dart';
import 'goals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const BudgetsScreen(),
    const ReportsScreen(),
    const HistoryScreen(),
    const GoalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: provider.currentMonth,
                items: List.generate(12, (index) {
                  final month = index + 1;
                  return DropdownMenuItem(
                    value: month,
                    child: Text(_getMonthName(month)),
                  );
                }),
                onChanged: (month) {
                  if (month != null) {
                    provider.setMonth(month, provider.currentYear);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                controller: TextEditingController(
                  text: provider.currentYear.toString(),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (value) {
                  final year = int.tryParse(value);
                  if (year != null) {
                    provider.setMonth(provider.currentMonth, year);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.info,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_circle_outline),
            label: l10n.transactions,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: l10n.budgets,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pie_chart),
            label: l10n.reports,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: l10n.history,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.flag),
            label: l10n.goals,
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    final months = [
      AppLocalizations.of(context)!.january,
      AppLocalizations.of(context)!.february,
      AppLocalizations.of(context)!.march,
      AppLocalizations.of(context)!.april,
      AppLocalizations.of(context)!.may,
      AppLocalizations.of(context)!.june,
      AppLocalizations.of(context)!.july,
      AppLocalizations.of(context)!.august,
      AppLocalizations.of(context)!.september,
      AppLocalizations.of(context)!.october,
      AppLocalizations.of(context)!.november,
      AppLocalizations.of(context)!.december,
    ];
    return months[month - 1];
  }
}

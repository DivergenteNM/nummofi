import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/providers/finance_provider.dart';
import '../core/providers/settings_provider.dart';
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
        actions: [
          _buildSettingsButton(context),
        ],
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

  /// Botón de configuración en la esquina superior derecha
  Widget _buildSettingsButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings),
      tooltip: l10n.settings,
      onSelected: (value) {
        _handleSettingsMenuAction(context, value, settingsProvider, l10n);
      },
      itemBuilder: (BuildContext context) {
        return [
          // Título: Apariencia
          PopupMenuItem<String>(
            enabled: false,
            child: Text(
              l10n.appearance,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Modo Claro
          PopupMenuItem<String>(
            value: 'theme_light',
            child: ListTile(
              leading: Icon(
                Icons.light_mode,
                color: settingsProvider.themeMode == ThemeMode.light
                    ? AppColors.info
                    : null,
              ),
              title: Text(l10n.lightMode),
              trailing: settingsProvider.themeMode == ThemeMode.light
                  ? const Icon(Icons.check, color: AppColors.info)
                  : null,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          // Modo Oscuro
          PopupMenuItem<String>(
            value: 'theme_dark',
            child: ListTile(
              leading: Icon(
                Icons.dark_mode,
                color: settingsProvider.themeMode == ThemeMode.dark
                    ? AppColors.info
                    : null,
              ),
              title: Text(l10n.darkMode),
              trailing: settingsProvider.themeMode == ThemeMode.dark
                  ? const Icon(Icons.check, color: AppColors.info)
                  : null,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          // Modo Sistema
          PopupMenuItem<String>(
            value: 'theme_system',
            child: ListTile(
              leading: Icon(
                Icons.brightness_auto,
                color: settingsProvider.themeMode == ThemeMode.system
                    ? AppColors.info
                    : null,
              ),
              title: Text(l10n.systemMode),
              trailing: settingsProvider.themeMode == ThemeMode.system
                  ? const Icon(Icons.check, color: AppColors.info)
                  : null,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          const PopupMenuDivider(),
          // Título: Idioma
          PopupMenuItem<String>(
            enabled: false,
            child: Text(
              l10n.language,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          // Español
          PopupMenuItem<String>(
            value: 'locale_es',
            child: ListTile(
              leading: Icon(
                Icons.language,
                color: settingsProvider.locale.languageCode == 'es'
                    ? AppColors.info
                    : null,
              ),
              title: Text(l10n.spanish),
              trailing: settingsProvider.locale.languageCode == 'es'
                  ? const Icon(Icons.check, color: AppColors.info)
                  : null,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
          // Inglés
          PopupMenuItem<String>(
            value: 'locale_en',
            child: ListTile(
              leading: Icon(
                Icons.language,
                color: settingsProvider.locale.languageCode == 'en'
                    ? AppColors.info
                    : null,
              ),
              title: Text(l10n.english),
              trailing: settingsProvider.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppColors.info)
                  : null,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          ),
        ];
      },
    );
  }

  /// Manejar las acciones del menú de configuración
  void _handleSettingsMenuAction(
    BuildContext context,
    String value,
    SettingsProvider settingsProvider,
    AppLocalizations l10n,
  ) {
    switch (value) {
      case 'theme_light':
        settingsProvider.setThemeMode(ThemeMode.light);
        _showSnackBar(context, l10n.themeChanged);
        break;
      case 'theme_dark':
        settingsProvider.setThemeMode(ThemeMode.dark);
        _showSnackBar(context, l10n.themeChanged);
        break;
      case 'theme_system':
        settingsProvider.setThemeMode(ThemeMode.system);
        _showSnackBar(context, l10n.themeChanged);
        break;
      case 'locale_es':
        settingsProvider.setLocale(const Locale('es', ''));
        _showSnackBar(context, l10n.languageChanged);
        break;
      case 'locale_en':
        settingsProvider.setLocale(const Locale('en', ''));
        _showSnackBar(context, l10n.languageChanged);
        break;
    }
  }

  /// Mostrar mensaje de confirmación
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

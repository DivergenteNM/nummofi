import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/providers/finance_provider.dart';
import '../core/utils/currency_formatter.dart';
import '../data/models/goal_model.dart';
import 'package:intl/intl.dart' as intl;
import '../l10n/app_localizations.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Iconos disponibles para las metas
  final List<Map<String, dynamic>> _availableIcons = [
    {'icon': '💰', 'name': 'Dinero'},
    {'icon': '🏠', 'name': 'Casa'},
    {'icon': '🚗', 'name': 'Auto'},
    {'icon': '✈️', 'name': 'Viaje'},
    {'icon': '👟', 'name': 'Zapatos'},
    {'icon': '💻', 'name': 'Tecnología'},
    {'icon': '📚', 'name': 'Educación'},
    {'icon': '🎯', 'name': 'Meta General'},
    {'icon': '💍', 'name': 'Compromiso'},
    {'icon': '🎮', 'name': 'Entretenimiento'},
    {'icon': '🏋️', 'name': 'Fitness'},
    {'icon': '🎸', 'name': 'Hobby'},
  ];

  // Colores disponibles
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FinanceProvider>(context);
    final goals = provider.goals;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.goals),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: goals.isEmpty
          ? _buildEmptyState(context)
          : _buildGoalsList(context, goals),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalDialog(context),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context)!.createGoal),
      ),
    );
  }

  // Estado vacío
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.savingsGoals,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.savingsGoalsTracking,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showGoalDialog(context),
              icon: const Icon(Icons.add_circle_outline),
              label: Text(AppLocalizations.of(context)!.createGoal),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lista de metas
  Widget _buildGoalsList(BuildContext context, List<GoalModel> goals) {
    // Separar metas completadas y activas
    final activeGoals = goals.where((g) => !g.isCompleted).toList();
    final completedGoals = goals.where((g) => g.isCompleted).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estadísticas generales
          _buildStatsCard(context, goals),
          const SizedBox(height: 24),

          // Metas activas
          if (activeGoals.isNotEmpty) ...[
            Text(
              '${AppLocalizations.of(context)!.inProgress} (${activeGoals.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...activeGoals.map((goal) => _buildGoalCard(context, goal)),
            const SizedBox(height: 24),
          ],

          // Metas completadas
          if (completedGoals.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(
                  '${AppLocalizations.of(context)!.completed} (${completedGoals.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber[700],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...completedGoals.map((goal) => _buildGoalCard(context, goal)),
          ],

          const SizedBox(height: 80), // Espacio para FAB
        ],
      ),
    );
  }

  // Card de estadísticas
  Widget _buildStatsCard(BuildContext context, List<GoalModel> goals) {
    final totalGoals = goals.length;
    final completedGoals = goals.where((g) => g.isCompleted).length;
    final totalTarget = goals.fold(0.0, (sum, g) => sum + g.targetAmount);
    final totalSaved = goals.fold(0.0, (sum, g) => sum + g.currentAmount);
    final overallProgress = totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  context,
                  AppLocalizations.of(context)!.goals,
                  totalGoals.toString(),
                  Icons.flag,
                  Colors.blue,
                ),
                _buildStatItem(
                  context,
                  AppLocalizations.of(context)!.completed,
                  completedGoals.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.progress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${overallProgress.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.savedInGoals,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatCurrency(totalSaved),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${AppLocalizations.of(context)!.targetAmount}: ${CurrencyFormatter.formatCurrency(totalTarget)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: overallProgress / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  overallProgress >= 100 ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Card de meta individual
  Widget _buildGoalCard(BuildContext context, GoalModel goal) {
    final color = goal.color != null
        ? Color(int.parse(goal.color!.replaceFirst('#', '0xFF')))
        : Colors.blue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showGoalDetailsDialog(context, goal),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Icono, título y menú
              Row(
                children: [
                  // Icono
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      goal.icon ?? '🎯',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Título y descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                goal.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (goal.isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.completed,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (goal.description != null &&
                            goal.description!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            goal.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Menú de opciones
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showGoalDialog(context, goal: goal);
                      } else if (value == 'add_money') {
                        _showAddMoneyDialog(context, goal);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(context, goal);
                      }
                    },
                    itemBuilder: (context) => [
                        PopupMenuItem(
                        value: 'add_money',
                          child: Row(
                            children: [
                              const Icon(Icons.add_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Text('${AppLocalizations.of(context)!.add} ${AppLocalizations.of(context)!.amount}'),
                            ],
                          ),
                      ),
                        PopupMenuItem(
                        value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.edit),
                            ],
                          ),
                      ),
                        PopupMenuItem(
                        value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(AppLocalizations.of(context)!.delete,
                                  style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progreso: Barra y montos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.formatCurrency(goal.currentAmount),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    '${goal.progressPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatCurrency(goal.targetAmount),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.isCompleted ? Colors.green : color,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Monto restante
              if (!goal.isCompleted)
                Text(
                  '${AppLocalizations.of(context)!.remaining}: ${CurrencyFormatter.formatCurrency(goal.remainingAmount)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Diálogo para agregar/editar meta
  void _showGoalDialog(BuildContext context, {GoalModel? goal}) {
    final isEdit = goal != null;
    final titleController = TextEditingController(text: goal?.title ?? '');
    final descriptionController =
        TextEditingController(text: goal?.description ?? '');
    final targetAmountController = TextEditingController(
      text: goal?.targetAmount.toStringAsFixed(0) ?? '',
    );
    final currentAmountController = TextEditingController(
      text: goal?.currentAmount.toStringAsFixed(0) ?? '0',
    );

    String selectedIcon = goal?.icon ?? _availableIcons[0]['icon'];
    Color selectedColor = goal?.color != null
        ? Color(int.parse(goal!.color!.replaceFirst('#', '0xFF')))
        : _availableColors[0];
    DateTime? targetDate = goal?.targetDate;

    // Obtener el provider ANTES de abrir el diálogo
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? AppLocalizations.of(context)!.editGoal : AppLocalizations.of(context)!.createGoal),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.goalName,
                    prefixIcon: const Icon(Icons.title),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Descripción
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                    prefixIcon: const Icon(Icons.notes),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),

                // Monto objetivo
                TextField(
                  controller: targetAmountController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.targetAmount,
                    hintText: '0',
                    prefixIcon: const Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),

                // Monto actual
                TextField(
                  controller: currentAmountController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.currentAmount,
                    hintText: '0',
                    prefixIcon: const Icon(Icons.savings),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),

                // Fecha objetivo (opcional)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    targetDate != null
                        ? '${AppLocalizations.of(context)!.deadline}: ${intl.DateFormat.yMd(Localizations.localeOf(context).toString()).format(targetDate!)}'
                        : AppLocalizations.of(context)!.deadline,
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      targetDate != null ? Icons.clear : Icons.add,
                    ),
                    onPressed: () async {
                      if (targetDate != null) {
                        setDialogState(() => targetDate = null);
                      } else {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ), // 10 años
                        );
                        if (picked != null) {
                          setDialogState(() => targetDate = picked);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Selector de icono
                const Text(
                  'Ícono:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableIcons.map((iconData) {
                    final icon = iconData['icon'] as String;
                    final isSelected = selectedIcon == icon;
                    return InkWell(
                      onTap: () {
                        setDialogState(() => selectedIcon = icon);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withValues(alpha: 0.2)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected ? selectedColor : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Selector de color
                const Text(
                  'Color:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableColors.map((color) {
                    final isSelected = selectedColor == color;
                    return InkWell(
                      onTap: () {
                        setDialogState(() => selectedColor = color);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.grey[300]!,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty ||
                    targetAmountController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.error),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final targetAmount =
                    double.tryParse(targetAmountController.text) ?? 0;
                final currentAmount =
                    double.tryParse(currentAmountController.text) ?? 0;

                if (targetAmount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.error),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final colorHex =
                    '#${selectedColor.value.toRadixString(16).substring(2)}';

                final newGoal = GoalModel(
                  id: goal?.id,
                  title: titleController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  targetAmount: targetAmount,
                  currentAmount: currentAmount,
                  createdAt: goal?.createdAt ?? DateTime.now(),
                  targetDate: targetDate,
                  icon: selectedIcon,
                  color: colorHex,
                );

                try {
                  if (isEdit) {
                    await provider.updateGoal(goal.id!, newGoal);
                  } else {
                    await provider.addGoal(newGoal);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
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
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppLocalizations.of(context)!.error}: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }

  // Diálogo para agregar dinero a una meta
  void _showAddMoneyDialog(BuildContext context, GoalModel goal) {
    final amountController = TextEditingController();
    
    // Obtener el provider ANTES de abrir el diálogo
    final provider = Provider.of<FinanceProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${AppLocalizations.of(context)!.add} ${AppLocalizations.of(context)!.amount}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.currentAmount}: ${CurrencyFormatter.formatCurrency(goal.currentAmount)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              '${AppLocalizations.of(context)!.remaining}: ${CurrencyFormatter.formatCurrency(goal.remainingAmount)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.amount,
                hintText: '0',
                prefixIcon: const Icon(Icons.add_circle_outline),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount <= 0) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.error),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                final newAmount = goal.currentAmount + amount;
                await provider.updateGoalProgress(goal.id!, newAmount);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  
                  // Si se completó la meta, mostrar celebración
                  if (newAmount >= goal.targetAmount) {
                    _showCelebrationDialog(context, goal);
                  } else {
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
                      ),
                    );
                  }
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('${AppLocalizations.of(context)!.error}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.add),
          ),
        ],
      ),
    );
  }

  // Diálogo de detalles de la meta
  void _showGoalDetailsDialog(BuildContext context, GoalModel goal) {
    final color = goal.color != null
        ? Color(int.parse(goal.color!.replaceFirst('#', '0xFF')))
        : Colors.blue;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Text(
              goal.icon ?? '🎯',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                goal.title,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (goal.description != null && goal.description!.isNotEmpty) ...[
                Text(
                  goal.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const Divider(height: 24),
              ],
              _buildDetailRow(
                AppLocalizations.of(context)!.targetAmount,
                CurrencyFormatter.formatCurrency(goal.targetAmount),
                Icons.flag,
                color,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                AppLocalizations.of(context)!.currentAmount,
                CurrencyFormatter.formatCurrency(goal.currentAmount),
                Icons.savings,
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                AppLocalizations.of(context)!.remaining,
                CurrencyFormatter.formatCurrency(goal.remainingAmount),
                Icons.schedule,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                AppLocalizations.of(context)!.progress,
                '${goal.progressPercentage.toStringAsFixed(1)}%',
                Icons.trending_up,
                color,
              ),
              if (goal.targetDate != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  AppLocalizations.of(context)!.deadline,
                  intl.DateFormat.yMd(Localizations.localeOf(context).toString()).format(goal.targetDate!),
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ],
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: goal.progressPercentage / 100,
                  minHeight: 12,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.isCompleted ? Colors.green : color,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (!goal.isCompleted)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showAddMoneyDialog(context, goal);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: Text('${AppLocalizations.of(context)!.add} ${AppLocalizations.of(context)!.amount}'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, IconData icon, Color color) {
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

  // Diálogo de celebración al completar meta
  void _showCelebrationDialog(BuildContext context, GoalModel goal) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (celebrationContext) => AlertDialog(
        title: Column(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 64),
            SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.success,
              style: const TextStyle(color: Colors.amber),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.completed,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              goal.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              CurrencyFormatter.formatCurrency(goal.targetAmount),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            const Text('🎊 🎉 🎈', style: TextStyle(fontSize: 32)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(celebrationContext),
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  // Confirmación de eliminación
  void _showDeleteConfirmation(BuildContext context, GoalModel goal) {
    // Obtener el provider ANTES de abrir el diálogo
    final provider = Provider.of<FinanceProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text(AppLocalizations.of(context)!.delete),
          ],
        ),
        content: Text(AppLocalizations.of(context)!.confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.deleteGoal(goal.id!);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.success),
                      ],
                    ),
                    backgroundColor: Colors.green,
                  ));
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('${AppLocalizations.of(context)!.error}: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
  }

  // Diálogo de información
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                // Permitir que el título haga wrap si es necesario
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.goals,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Esta pantalla te ayuda a:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Definir metas financieras'),
                  Text('• Hacer seguimiento del progreso'),
                  Text('• Agregar dinero a tus ahorros'),
                  Text('• Ver tus logros alcanzados'),
                  SizedBox(height: 16),
                  Text(
                    'Consejos:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Define metas realistas'),
                  Text('• Actualiza tu progreso regularmente'),
                  Text('• Celebra cada logro alcanzado'),
                  Text('• Usa el botón "+" para agregar dinero'),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.confirm),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

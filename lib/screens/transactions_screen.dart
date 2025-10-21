import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/finance_provider.dart';
import '../data/models/transaction_model.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/theme/app_theme.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
            'Registro de Transacciones',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),

          // Botón agregar transacción
          ElevatedButton.icon(
            onPressed: () {
              _showTransactionDialog(context, null);
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar Transacción'),
          ),
          const SizedBox(height: 16),

          // Lista de transacciones
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Historial del Mes',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  provider.currentMonthTransactions.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No hay transacciones este mes'),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.currentMonthTransactions.length,
                          separatorBuilder: (context, index) =>
                              const Divider(),
                          itemBuilder: (context, index) {
                            final transaction = provider
                                .currentMonthTransactions
                                .reversed
                                .toList()[index];
                            return _buildTransactionItem(
                              context,
                              transaction,
                              provider,
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionModel transaction,
    FinanceProvider provider,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        backgroundColor: transaction.type == 'Ingreso'
            ? AppColors.income.withOpacity(0.2)
            : AppColors.expense.withOpacity(0.2),
        child: Icon(
          transaction.type == 'Ingreso'
              ? Icons.arrow_downward
              : transaction.type == 'Egreso'
                  ? Icons.arrow_upward
                  : Icons.swap_horiz,
          color: transaction.type == 'Ingreso'
              ? AppColors.income
              : AppColors.expense,
        ),
      ),
      title: Text(transaction.description),
      subtitle: Text(
        '${transaction.date.day}/${transaction.date.month}/${transaction.date.year} • ${transaction.category ?? (transaction.channelFrom != null ? "${transaction.channelFrom} → ${transaction.channelTo}" : "")}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            CurrencyFormatter.formatCurrency(transaction.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.type == 'Ingreso'
                  ? AppColors.income
                  : AppColors.expense,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () {
              _showTransactionDialog(context, transaction);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            color: AppColors.error,
            onPressed: () {
              _showDeleteDialog(context, transaction, provider);
            },
          ),
        ],
      ),
    );
  }

  void _showTransactionDialog(
    BuildContext context,
    TransactionModel? transaction,
  ) {

    final financeprovider = Provider.of<FinanceProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogContext) => TransactionDialog(
        transaction: transaction,
        financeProvider: financeprovider,
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    TransactionModel transaction,
    FinanceProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Transacción'),
        content: const Text('¿Estás seguro de eliminar esta transacción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await provider.deleteTransaction(transaction.id!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transacción eliminada exitosamente'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class TransactionDialog extends StatefulWidget {
  final TransactionModel? transaction;
  final FinanceProvider financeProvider;

  const TransactionDialog({super.key, this.transaction, required this.financeProvider});

  @override
  State<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends State<TransactionDialog> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  late String _selectedType;
  String? _selectedCategory;
  String? _selectedChannel;
  String? _selectedChannelFrom;
  String? _selectedChannelTo;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.transaction?.description ?? '',
    );
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toString() ?? '',
    );
    _selectedDate = widget.transaction?.date ?? DateTime.now();
    _selectedType = widget.transaction?.type ?? 'Egreso';
    _selectedCategory = widget.transaction?.category ??
        (widget.transaction?.type == 'Ingreso'
            ? AppConstants.categoriasIngreso[0]
            : AppConstants.categoriasEgreso[0]);
    _selectedChannel = widget.transaction?.channel ?? AppConstants.canales[0];
    _selectedChannelFrom = widget.transaction?.channelFrom;
    _selectedChannelTo = widget.transaction?.channelTo;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.transaction == null
            ? 'Agregar Transacción'
            : 'Editar Transacción',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fecha
            ListTile(
              title: const Text('Fecha'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
            ),

            // Tipo
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: AppConstants.tiposTransaccion
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                  if (value == 'Ingreso') {
                    _selectedCategory = AppConstants.categoriasIngreso[0];
                  } else if (value == 'Egreso') {
                    _selectedCategory = AppConstants.categoriasEgreso[0];
                  }
                });
              },
            ),

            // Monto
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
            ),

            // Campos según el tipo
            if (_selectedType == 'Transferencia') ...[
              DropdownButtonFormField<String>(
                value: _selectedChannelFrom,
                decoration: const InputDecoration(labelText: 'Desde el Canal'),
                items: AppConstants.canales
                    .map((channel) => DropdownMenuItem(
                          value: channel,
                          child: Text(channel),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChannelFrom = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedChannelTo,
                decoration: const InputDecoration(labelText: 'Hacia el Canal'),
                items: AppConstants.canales
                    .map((channel) => DropdownMenuItem(
                          value: channel,
                          child: Text(channel),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChannelTo = value;
                  });
                },
              ),
            ] else ...[
              DropdownButtonFormField<String>(
                value: _selectedChannel,
                decoration: const InputDecoration(labelText: 'Canal'),
                items: AppConstants.canales
                    .map((channel) => DropdownMenuItem(
                          value: channel,
                          child: Text(channel),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChannel = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: (_selectedType == 'Ingreso'
                        ? AppConstants.categoriasIngreso
                        : AppConstants.categoriasEgreso)
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ],

            // Descripción
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              final transaction = TransactionModel(
                id: widget.transaction?.id,
                date: _selectedDate,
                description: _descriptionController.text,
                amount: double.parse(_amountController.text),
                type: _selectedType,
                category: _selectedCategory,
                channel: _selectedChannel,
                channelFrom: _selectedChannelFrom,
                channelTo: _selectedChannelTo,
              );

              if (widget.transaction == null) {
                await widget.financeProvider.addTransaction(transaction);
              } else {
                await widget.financeProvider.updateTransaction(
                  widget.transaction!.id!,
                  transaction,
                );
              }

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      widget.transaction == null
                          ? 'Transacción agregada exitosamente'
                          : 'Transacción actualizada exitosamente',
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

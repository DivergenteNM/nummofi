import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/providers/finance_provider.dart';
import '../data/models/transaction_model.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/number_formatter.dart';
import '../core/theme/app_theme.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

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
            'Registro de Transacciones',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Botón agregar transacción
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                _showTransactionDialog(context, null);
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Transacción'),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de transacciones
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Historial del Mes',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
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
    return InkWell(
      onTap: () {
        _showTransactionDetailSheet(context, transaction, provider);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // Ícono
            CircleAvatar(
              radius: 24,
              backgroundColor: transaction.type == 'Ingreso'
                  ? AppColors.income.withOpacity(0.15)
                  : transaction.type == 'Egreso'
                  ? AppColors.expense.withOpacity(0.15)
                  : AppColors.transfer.withOpacity(0.15),
              child: Icon(
                transaction.type == 'Ingreso'
                    ? Icons.arrow_downward
                    : transaction.type == 'Egreso'
                        ? Icons.arrow_upward
                        : Icons.swap_horiz,
                color: transaction.type == 'Ingreso'
                    ? AppColors.income
                    : transaction.type == 'Egreso'
                        ? AppColors.expense
                        : AppColors.transfer,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category ?? 
                    (transaction.channelFrom != null 
                        ? "${transaction.channelFrom} → ${transaction.channelTo}" 
                        : "Sin categoría"),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Monto
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  CurrencyFormatter.formatCurrency(transaction.amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: transaction.type == 'Ingreso'
                        ? AppColors.income
                        : AppColors.expense,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetailSheet(
    BuildContext context,
    TransactionModel transaction,
    FinanceProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: transaction.type == 'Ingreso'
                      ? AppColors.income.withOpacity(0.15)
                      : AppColors.expense.withOpacity(0.15),
                  child: Icon(
                    transaction.type == 'Ingreso'
                        ? Icons.arrow_downward
                        : transaction.type == 'Egreso'
                            ? Icons.arrow_upward
                            : Icons.swap_horiz,
                    color: transaction.type == 'Ingreso'
                        ? AppColors.income
                        : AppColors.expense,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        transaction.type,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // Detalles
            _buildDetailRow('Monto', CurrencyFormatter.formatCurrency(transaction.amount)),
            _buildDetailRow('Fecha', '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}'),
            if (transaction.category != null)
              _buildDetailRow('Categoría', transaction.category!),
            if (transaction.channel != null)
              _buildDetailRow('Canal', transaction.channel!),
            if (transaction.channelFrom != null)
              _buildDetailRow('Desde', transaction.channelFrom!),
            if (transaction.channelTo != null)
              _buildDetailRow('Hacia', transaction.channelTo!),
            const SizedBox(height: 24),
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showTransactionDialog(context, transaction);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteDialog(context, transaction, provider);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
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
    
    // Formatea el monto con separadores de miles
    String formattedAmount = '';
    if (widget.transaction?.amount != null && widget.transaction!.amount > 0) {
      formattedAmount = formatAmountWithThousands(widget.transaction!.amount.toInt());
    }
    
    _amountController = TextEditingController(text: formattedAmount);
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
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Fecha
              InkWell(
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
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tipo
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
              const SizedBox(height: 16),

              // Monto
              TextField(
                controller: _amountController,
                inputFormatters: [ThousandsSeparatorFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Campos según el tipo
              if (_selectedType == 'Transferencia') ...[
                DropdownButtonFormField<String>(
                  value: _selectedChannelFrom,
                  decoration: const InputDecoration(
                    labelText: 'Desde el Canal',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedChannelTo,
                  decoration: const InputDecoration(
                    labelText: 'Hacia el Canal',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
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
                const SizedBox(height: 16),
              ] else ...[
                DropdownButtonFormField<String>(
                  value: _selectedChannel,
                  decoration: const InputDecoration(
                    labelText: 'Canal',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  isExpanded: true,
                  items: (_selectedType == 'Ingreso'
                          ? AppConstants.categoriasIngreso
                          : AppConstants.categoriasEgreso)
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(
                              category,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Descripción
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
            ],
          ),
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
                amount: parseAmountFromFormatted(_amountController.text),
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

import 'package:flutter/services.dart';

/// Formateador que añade puntos separadores de miles mientras el usuario escribe
/// 
/// **Uso recomendado en campos numéricos:**
/// ```dart
/// TextField(
///   controller: _amountController,
///   inputFormatters: [ThousandsSeparatorFormatter()],
///   keyboardType: TextInputType.number,
///   decoration: InputDecoration(
///     labelText: 'Monto',
///     prefixText: '\$ ',
///   ),
/// )
/// ```
/// 
/// **Para guardar el valor, remover los puntos:**
/// ```dart
/// final amount = parseAmountFromFormatted(_amountController.text);
/// ```
/// 
/// **Para mostrar un valor existente con formato:**
/// ```dart
/// _controller.text = formatAmountWithThousands(existingValue.toInt());
/// ```
/// 
/// Convierte: 1000000 -> 1.000.000
class ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Si está vacío, devuelve vacío
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Elimina todos los puntos del texto
    final text = newValue.text.replaceAll('.', '');

    // Verifica que solo contenga dígitos
    if (!RegExp(r'^\d*$').hasMatch(text)) {
      return oldValue;
    }

    // Añade puntos cada 3 dígitos desde la derecha
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(text[i]);
    }

    final formattedText = buffer.toString();

    // Calcula la nueva posición del cursor
    int offset = newValue.selection.end;
    int oldDigitCount = oldValue.text.replaceAll('.', '').length;
    int newDigitCount = text.length;

    if (newDigitCount > oldDigitCount) {
      // Se añadió un dígito
      int newDotsCount = (newDigitCount / 3).floor();
      int oldDotsCount = (oldDigitCount / 3).floor();
      offset = newValue.selection.end + (newDotsCount - oldDotsCount);
    } else if (newDigitCount < oldDigitCount) {
      // Se eliminó un dígito
      int newDotsCount = (newDigitCount / 3).floor();
      int oldDotsCount = ((oldDigitCount) / 3).floor();
      offset = newValue.selection.end - (oldDotsCount - newDotsCount);
    }

    // Asegura que el offset esté dentro de los límites
    offset = offset.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// Función auxiliar para formatear un número entero con separadores de miles
/// 
/// Ejemplo:
/// ```dart
/// formatAmountWithThousands(1000000) // "1.000.000"
/// ```
String formatAmountWithThousands(int amount) {
  final text = amount.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(text[i]);
  }
  return buffer.toString();
}

/// Función auxiliar para remover los separadores de miles de un string
/// y convertirlo a double
/// 
/// Ejemplo:
/// ```dart
/// parseAmountFromFormatted("1.000.000") // 1000000.0
/// ```
double parseAmountFromFormatted(String formattedAmount) {
  return double.parse(formattedAmount.replaceAll('.', ''));
}

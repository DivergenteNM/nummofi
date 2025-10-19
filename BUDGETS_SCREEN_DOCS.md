# 📊 Pantalla de Presupuestos - Documentación

## ✅ Funcionalidades Implementadas

### 1. **Vista de Resumen (Modo Ver)**

#### Tarjetas de Resumen
- 💰 **Tarjeta de Ingresos**
  - Monto planeado vs real
  - Porcentaje de cumplimiento
  - Barra de progreso visual
  - Indicador de colores (verde si está bien, rojo si sobrepasa)

- 💸 **Tarjeta de Egresos**
  - Monto planeado vs real
  - Porcentaje de ejecución
  - Barra de progreso visual
  - Alertas si sobrepasa el presupuesto

#### Comparación por Categorías
- 📈 **Egresos por Categoría**
  - Lista de todas las categorías con presupuesto
  - Comparación presupuesto vs gasto real
  - Barra de progreso individual
  - Porcentaje de ejecución
  - ⚠️ Alertas de sobrepresupuesto con monto exacto

- 📊 **Ingresos por Categoría**
  - Lista de categorías de ingreso
  - Comparación presupuesto vs ingresos reales
  - Visualización de cumplimiento

---

### 2. **Modo Edición**

#### Formularios de Presupuesto
- ✏️ **Presupuestos de Egresos**
  - Input para cada categoría:
    - Alimentación
    - Transporte
    - Servicios y alojamiento
    - Estudios y universidad
    - Salud y cuidado personal
    - Eventos y vida social
    - Tecnología y regalos
    - Ahorros y proyectos
    - Otros egresos

- ✏️ **Presupuestos de Ingresos**
  - Input para cada categoría:
    - Ayuda Familiar
    - Entradas esporádicas
    - Emprendimiento
    - Otros ingresos

#### Características del Formulario
- 💵 Formato con símbolo de peso ($)
- ⌨️ Teclado numérico automático
- 🔄 Actualización en tiempo real
- 💾 Botón de guardar destacado

---

### 3. **Botones de Acción**

#### Alternar entre Modos
- 👁️ **Ver Resumen** - Muestra comparaciones y progreso
- ✏️ **Editar Presupuestos** - Habilita formularios de edición

#### Guardar Cambios
- 💾 **Botón Guardar** (solo en modo edición)
  - Color verde destacado
  - Guarda en Firestore
  - Notificación de éxito
  - Vuelve automáticamente al modo ver

---

## 🎨 Características Visuales

### Indicadores de Color
- 🟢 **Verde** - Dentro del presupuesto
- 🔴 **Rojo** - Sobrepasado el presupuesto
- 🔵 **Azul** - Acciones principales
- ⚪ **Gris** - Información neutral

### Barras de Progreso
- Lineales para cada categoría
- Color dinámico según estado
- Porcentaje visible
- Fondo gris claro

### Tarjetas
- Sombras suaves
- Bordes redondeados
- Espaciado consistente
- Iconos ilustrativos

---

## 💡 Lógica de Negocio

### Cálculos Automáticos

```dart
// Total planeado
totalPlanned = sum(budgetMap.values)

// Total real
totalActual = sum(transactions.where(filter).amount)

// Porcentaje
percentage = (actual / planned) * 100

// Sobrepresupuesto
overbudget = actual > planned
overbudgetAmount = actual - planned
```

### Comparación por Categoría

1. **Filtrar transacciones** del mes actual
2. **Agrupar por categoría** (Ingresos o Egresos)
3. **Sumar montos** de cada categoría
4. **Comparar** con presupuesto establecido
5. **Mostrar alertas** si hay sobrepresupuesto

---

## 🔄 Flujo de Usuario

### Primera vez (Sin presupuestos)
```
1. Usuario entra a la pantalla
2. Ve mensaje "No hay presupuestos establecidos"
3. Hace clic en "Establecer Presupuestos"
4. Modo edición se activa
5. Llena los campos deseados
6. Hace clic en "Guardar"
7. Se guarda en Firestore
8. Ve el resumen con comparaciones
```

### Con presupuestos existentes
```
1. Usuario entra a la pantalla
2. Ve resumen con tarjetas y comparaciones
3. Si quiere editar:
   - Hace clic en "Editar Presupuestos"
   - Modifica valores
   - Guarda cambios
4. Si solo quiere revisar:
   - Revisa barras de progreso
   - Ve alertas de sobrepresupuesto
   - Analiza su ejecución
```

---

## 📱 Responsive Design

### Layout Adaptativo
- **Desktop/Tablet**: Dos columnas (Egresos | Ingresos)
- **Mobile**: Columna única (scroll vertical)

### Elementos Responsivos
- Tarjetas se ajustan al ancho
- Textos se adaptan al espacio
- Inputs con tamaño apropiado

---

## 🔐 Persistencia de Datos

### Modelo de Datos en Firestore

```
budgets/
└── {month}-{year}
    ├── month: 10
    ├── year: 2025
    ├── incomes: {
    │   "Ayuda Familiar": 500000,
    │   "Emprendimiento": 300000
    │   }
    └── expenses: {
        "Alimentación": 200000,
        "Transporte": 100000,
        "Servicios y alojamiento": 150000
        }
```

### Operaciones
- **Crear**: Al guardar por primera vez
- **Actualizar**: Al modificar presupuestos existentes
- **Leer**: Al cargar la pantalla (Stream automático)

---

## 🎯 Casos de Uso

### Caso 1: Planificación Mensual
```
Usuario: Empleado que recibe salario
Necesidad: Planificar gastos del mes

1. Entra al mes actual (ej: Octubre 2025)
2. Establece presupuesto de ingresos:
   - Salario: $2,000,000
3. Establece presupuesto de egresos:
   - Alimentación: $600,000
   - Transporte: $200,000
   - Servicios: $300,000
   - Otros: $400,000
4. Durante el mes, ve el progreso
5. Recibe alertas si se está pasando
```

### Caso 2: Estudiante con Ingresos Variables
```
Usuario: Estudiante con emprendimiento
Necesidad: Controlar gastos con ingreso variable

1. Establece presupuesto conservador
2. Categorías principales:
   - Estudios: $300,000
   - Alimentación: $250,000
   - Transporte: $150,000
3. Ve en tiempo real si puede gastar más
4. Ajusta presupuesto según ingresos reales
```

### Caso 3: Control Familiar
```
Usuario: Padre/Madre de familia
Necesidad: Administrar presupuesto familiar

1. Categorías detalladas:
   - Mercado: $800,000
   - Colegios: $500,000
   - Salud: $200,000
   - Recreación: $150,000
2. Monitorea diariamente
3. Recibe alertas tempranas
4. Ajusta gastos según necesidad
```

---

## 🚨 Alertas y Validaciones

### Alertas Visuales
- ⚠️ **Icono de advertencia** cuando sobrepasa
- 🔴 **Texto rojo** en montos excedidos
- 📊 **Barra roja** cuando supera el 100%

### Mensajes
```dart
// Éxito al guardar
"Presupuestos guardados exitosamente"

// Error al guardar
"Error al guardar: [detalle del error]"

// Sin presupuestos
"No hay presupuestos establecidos"

// Sobrepresupuesto
"Sobrepresupuesto: $50,000"
```

---

## 🔧 Mejoras Futuras Sugeridas

### Corto Plazo
- [ ] Copiar presupuesto del mes anterior
- [ ] Restablecer presupuestos a cero
- [ ] Vista de comparación de múltiples meses

### Medio Plazo
- [ ] Gráficas de tendencia de presupuesto
- [ ] Alertas push al llegar al 80% del presupuesto
- [ ] Sugerencias de presupuesto basadas en historial

### Largo Plazo
- [ ] Presupuesto anual con distribución mensual
- [ ] Análisis predictivo de gastos
- [ ] Recomendaciones de ahorro
- [ ] Metas financieras integradas

---

## 🧪 Cómo Probar

### Test Manual

1. **Primera Carga**
   ```
   ✓ Verifica que muestra "No hay presupuestos"
   ✓ Botón para establecer presupuestos funciona
   ```

2. **Establecer Presupuesto**
   ```
   ✓ Click en "Editar Presupuestos"
   ✓ Llenar campos con valores de prueba
   ✓ Click en "Guardar"
   ✓ Verifica notificación de éxito
   ```

3. **Ver Comparaciones**
   ```
   ✓ Agrega algunas transacciones en TransactionsScreen
   ✓ Vuelve a BudgetsScreen
   ✓ Verifica que muestra comparaciones
   ✓ Verifica barras de progreso
   ```

4. **Sobrepresupuesto**
   ```
   ✓ Establece presupuesto bajo (ej: $10,000 en Alimentación)
   ✓ Agrega transacción que supere el presupuesto
   ✓ Verifica alerta de sobrepresupuesto
   ✓ Verifica que barra es roja
   ```

5. **Editar Existente**
   ```
   ✓ Con presupuesto ya guardado
   ✓ Click en "Editar Presupuestos"
   ✓ Verifica que carga valores actuales
   ✓ Modifica valores
   ✓ Guarda y verifica actualización
   ```

---

## 📊 Ejemplo Completo

### Datos de Prueba

```dart
// Presupuesto
Ingresos:
  Ayuda Familiar: $500,000
  Emprendimiento: $300,000
Total: $800,000

Egresos:
  Alimentación: $250,000
  Transporte: $100,000
  Servicios: $150,000
  Estudios: $200,000
Total: $700,000

// Transacciones Reales
Ingresos:
  Ayuda Familiar: $500,000 (100%)
  Emprendimiento: $250,000 (83%)
Total: $750,000

Egresos:
  Alimentación: $280,000 (112% - Sobrepresupuesto)
  Transporte: $80,000 (80%)
  Servicios: $150,000 (100%)
  Estudios: $180,000 (90%)
Total: $690,000
```

### Resultado Esperado
- ✅ Tarjeta de Ingresos: Verde (93.75%)
- ✅ Tarjeta de Egresos: Verde (98.57%)
- ⚠️ Alimentación: Roja con alerta "$30,000 sobrepresupuesto"
- ✅ Otras categorías: Verde

---

## 🎉 ¡Listo para Usar!

La pantalla de presupuestos está **100% funcional** con:

✅ Vista de resumen completa  
✅ Modo de edición intuitivo  
✅ Comparaciones visuales  
✅ Alertas de sobrepresupuesto  
✅ Persistencia en Firestore  
✅ UI responsive y moderna  
✅ Validaciones y manejo de errores  

**Próxima pantalla:** ReportsScreen o HistoryScreen 🚀

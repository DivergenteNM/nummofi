# 📊 Pantalla de Reportes - Documentación Completa

## ✅ Funcionalidades Implementadas

### 1. **Selector de Período** 📅

Permite analizar datos en diferentes rangos temporales:

- 📆 **Este Mes** - Datos del mes actual seleccionado
- 📅 **3 Meses** - Últimos 3 meses de datos
- 🗓️ **Este Año** - Todo el año actual

**Implementación:**
```dart
SegmentedButton<String>(
  segments: [
    ButtonSegment(value: 'month', label: Text('Este Mes')),
    ButtonSegment(value: '3months', label: Text('3 Meses')),
    ButtonSegment(value: 'year', label: Text('Este Año')),
  ],
  // Filtra automáticamente los datos
)
```

---

### 2. **Estadísticas Generales** 📈

Grid de 4 tarjetas con métricas clave:

#### 💰 Ingresos Totales
- Suma de todos los ingresos del período
- Color: Verde
- Icono: Flecha hacia abajo (entrada de dinero)

#### 💸 Egresos Totales
- Suma de todos los egresos del período
- Color: Rojo
- Icono: Flecha hacia arriba (salida de dinero)

#### 💵 Balance
- Cálculo: `Ingresos - Egresos`
- Color: Verde si positivo, Rojo si negativo
- Icono: Billetera

#### 🏦 Tasa de Ahorro
- Fórmula: `(Balance / Ingresos) * 100`
- Color: Verde si ≥20%, Amarillo si <20%
- Icono: Alcancía
- Indicador de salud financiera

**Ejemplo:**
```
Ingresos: $2,000,000
Egresos: $1,500,000
Balance: $500,000
Tasa de Ahorro: 25% ✅ (Saludable)
```

---

### 3. **Gráfica de Distribución de Egresos** 🥧

#### Gráfica de Dona (Pie Chart)
- Muestra proporción de gastos por categoría
- Colores distintos para cada categoría
- Porcentajes en cada sección
- Radio del centro: 60px (efecto dona)

#### Leyenda Interactiva
- Lista de categorías con su color
- Scrollable si hay muchas categorías
- Tamaño compacto y claro

#### Lista Detallada (Top 5)
Muestra las 5 categorías con mayor gasto:
- Nombre de categoría
- Porcentaje del total
- Monto en pesos

**Ejemplo Visual:**
```
┌─────────────────────────────────────────┐
│  DISTRIBUCIÓN DE EGRESOS               │
├─────────────────────────────────────────┤
│                                         │
│     ╭───────────╮      ● Alimentación  │
│     │           │      ● Transporte    │
│     │    🥧     │      ● Servicios     │
│     │           │      ● Estudios      │
│     ╰───────────╯                      │
│                                         │
│  Alimentación      35%  $700,000       │
│  Transporte        25%  $500,000       │
│  Servicios         20%  $400,000       │
└─────────────────────────────────────────┘
```

---

### 4. **Gráfica de Evolución Temporal** 📉

#### Gráfica de Líneas
- **Línea Verde**: Evolución de ingresos
- **Línea Roja**: Evolución de egresos
- Muestra últimos 6 meses con datos
- Suavizado de curvas (curved lines)
- Área sombreada debajo de cada línea

#### Características Visuales
- Grid horizontal para referencia
- Puntos en cada mes
- Etiquetas de mes en eje X (Ene, Feb, Mar...)
- Valores en eje Y (automático)
- Leyenda inferior

#### Utilidad
- Identificar tendencias de gastos
- Ver estacionalidad
- Comparar meses
- Planificar futuros gastos

**Ejemplo:**
```
  $
  │
2M│     ●────●
  │    /      \●
1M│   ●        ●────●
  │  
  └─────────────────────→ Tiempo
    Ene Feb Mar Abr May Jun
    
    ─── Ingresos
    ─── Egresos
```

---

### 5. **Top Categorías** 🏆

Dos listas lado a lado:

#### 🔴 Mayores Egresos
Ranking de categorías con más gastos:
- Posición (1-5)
- Nombre de categoría
- Barra de progreso relativa
- Monto total

#### 🟢 Mayores Ingresos
Ranking de categorías con más ingresos:
- Misma estructura que egresos
- Útil para identificar fuentes principales

**Características:**
- Top 5 de cada tipo
- Colores distintivos
- Ordenamiento automático (mayor a menor)
- Porcentajes relativos

**Ejemplo:**
```
┌─────────────────────┐  ┌─────────────────────┐
│ MAYORES EGRESOS     │  │ MAYORES INGRESOS    │
├─────────────────────┤  ├─────────────────────┤
│ 1️⃣ Alimentación    │  │ 1️⃣ Salario         │
│    ████████ $700K   │  │    ██████ $1,500K   │
│                     │  │                     │
│ 2️⃣ Transporte      │  │ 2️⃣ Emprendimiento  │
│    █████ $500K      │  │    ███ $500K        │
│                     │  │                     │
│ 3️⃣ Servicios       │  │ 3️⃣ Ayuda Familiar  │
│    ████ $400K       │  │    ██ $300K         │
└─────────────────────┘  └─────────────────────┘
```

---

### 6. **Comparativa por Canal** 💳

Analiza el flujo de dinero por canal de pago:

#### Información por Canal
Para cada canal (Nequi, NuBank, Efectivo):
- Icono representativo
- Total de ingresos
- Total de egresos
- Balance (ingresos - egresos)

#### Visualización
- Barras comparativas lado a lado
- Color verde para balance positivo
- Color rojo para balance negativo
- Formato de moneda claro

**Ejemplo:**
```
┌──────────────────────────────────────────┐
│ COMPARATIVA POR CANAL                   │
├──────────────────────────────────────────┤
│ 📱 Nequi                    +$200,000    │
│ Ingresos: $800,000  Egresos: $600,000   │
│                                          │
│ 💳 NuBank                   +$150,000    │
│ Ingresos: $500,000  Egresos: $350,000   │
│                                          │
│ 💵 Efectivo                 -$50,000     │
│ Ingresos: $200,000  Egresos: $250,000   │
└──────────────────────────────────────────┘
```

---

## 🎨 Paleta de Colores

### Categorías (Gráfica de Dona)
```dart
- Rojo:    #EF4444
- Ámbar:   #F59E0B
- Verde:   #10B981
- Azul:    #3B82F6
- Violeta: #8B5CF6
- Rosa:    #EC4899
- Turquesa:#14B8A6
- Naranja: #F97316
- Cian:    #06B6D4
```

### Canales
```dart
- Nequi:    #9B59B6 (Morado)
- NuBank:   #8B5CF6 (Violeta)
- Efectivo: #FBBF24 (Amarillo)
```

---

## 📊 Cálculos y Algoritmos

### 1. Distribución por Categorías
```dart
Map<String, double> calculateDistribution(List<Transaction> transactions) {
  Map<String, double> distribution = {};
  
  for (var t in transactions.where((t) => t.type == 'Egreso')) {
    distribution[t.category] = (distribution[t.category] ?? 0) + t.amount;
  }
  
  return distribution;
}
```

### 2. Tasa de Ahorro
```dart
double calculateSavingsRate(double income, double expenses) {
  if (income == 0) return 0;
  return ((income - expenses) / income) * 100;
}

// Ejemplo:
// Ingresos: $2,000,000
// Egresos: $1,600,000
// Ahorro: $400,000
// Tasa: 20%
```

### 3. Datos Mensuales para Gráfica
```dart
List<MonthlyData> getMonthlyData(List<Transaction> transactions) {
  // Agrupa por mes
  Map<String, double> monthlyIncome = {};
  Map<String, double> monthlyExpense = {};
  
  // Procesa transacciones
  for (var t in transactions) {
    String key = '${t.year}-${t.month}';
    if (t.type == 'Ingreso') {
      monthlyIncome[key] = (monthlyIncome[key] ?? 0) + t.amount;
    } else {
      monthlyExpense[key] = (monthlyExpense[key] ?? 0) + t.amount;
    }
  }
  
  // Retorna últimos 6 meses
  return sortAndLimit(monthlyIncome, monthlyExpense, 6);
}
```

---

## 🎯 Casos de Uso

### Caso 1: Análisis Mensual de Gastos
```
Usuario: Persona que quiere controlar gastos del mes

1. Entra a ReportsScreen
2. Selecciona "Este Mes"
3. Ve estadísticas generales:
   - Ingresos: $1,800,000
   - Egresos: $1,500,000
   - Balance: $300,000 ✅
   - Tasa de Ahorro: 16.7% ⚠️ (puede mejorar)
4. Revisa gráfica de dona:
   - Alimentación: 40% ($600,000) 😱
   - Identifica área de mejora
5. Toma acción: Reducir gastos en alimentación
```

### Caso 2: Tendencias Trimestrales
```
Usuario: Freelancer con ingresos variables

1. Selecciona "3 Meses"
2. Ve evolución en gráfica de líneas:
   - Mes 1: Ingresos altos, gastos normales ✅
   - Mes 2: Ingresos bajos, gastos altos ❌
   - Mes 3: Ingresos medios, gastos reducidos ✅
3. Identifica patrón: necesita reserva para mes 2
4. Planifica: Aumentar tasa de ahorro en meses buenos
```

### Caso 3: Optimización de Canales
```
Usuario: Persona con múltiples cuentas

1. Va a "Comparativa por Canal"
2. Observa:
   - Nequi: +$200,000 (usa para recibir dinero)
   - NuBank: -$100,000 (paga todo con tarjeta)
   - Efectivo: -$50,000 (gastos pequeños)
3. Estrategia: Concentrar gastos en NuBank para cashback
```

---

## 📱 Responsive Design

### Layout Móvil (< 600px)
- Todas las secciones en una columna
- Gráficas ajustadas al ancho
- Top categorías en columna única
- Texto legible en pantalla pequeña

### Layout Tablet (600-900px)
- Gráficas más grandes
- Top categorías en dos columnas
- Mejor aprovechamiento del espacio

### Layout Desktop (> 900px)
- Vista optimizada para pantalla grande
- Gráficas con más detalle
- Todas las comparativas visibles

---

## 🔍 Estados de la Pantalla

### 1. Sin Datos
```dart
// Muestra mensaje amigable
"No hay datos para mostrar"
+ Icono representativo
+ Sugerencia: "Agrega transacciones"
```

### 2. Con Pocos Datos
```dart
// Adapta visualizaciones
- Gráfica de líneas con menos puntos
- Top categorías con menos items
- Estadísticas básicas
```

### 3. Con Muchos Datos
```dart
// Muestra todo el potencial
- Gráfica de dona completa
- Evolución de 6 meses
- Top 5 completo de categorías
- Todos los canales
```

---

## 🧪 Cómo Probar

### Test Básico (5 minutos)

```bash
1. Ejecutar app: flutter run

2. Agregar datos de prueba:
   - 5 transacciones de ingreso
   - 10 transacciones de egreso
   - En diferentes categorías
   - En diferentes canales

3. Ir a ReportsScreen (4to botón)

4. Verificar:
   ✓ Estadísticas muestran totales correctos
   ✓ Gráfica de dona aparece
   ✓ Colores son distintos
   ✓ Porcentajes suman 100%
   ✓ Top categorías ordenado correctamente
```

### Test de Períodos

```bash
1. Seleccionar "Este Mes"
   ✓ Solo muestra transacciones del mes actual

2. Seleccionar "3 Meses"
   ✓ Muestra últimos 3 meses
   ✓ Gráfica de líneas con más puntos

3. Seleccionar "Este Año"
   ✓ Muestra todo el año
   ✓ Estadísticas acumuladas correctas
```

### Test de Gráficas

```bash
Gráfica de Dona:
✓ Muestra todas las categorías con gasto
✓ Colores distintivos
✓ Porcentajes visibles
✓ Leyenda completa
✓ Lista con top 5

Gráfica de Líneas:
✓ Línea verde (ingresos) y roja (egresos)
✓ Puntos en cada mes
✓ Etiquetas de mes visibles
✓ Escala Y apropiada
✓ Leyenda clara
```

---

## 🎓 Interpretación de Datos

### Tasa de Ahorro

| Tasa | Interpretación | Acción |
|------|----------------|--------|
| > 30% | 🟢 Excelente | Mantener hábitos |
| 20-30% | 🟢 Buena | Ahorrar más si es posible |
| 10-20% | 🟡 Regular | Revisar gastos no esenciales |
| < 10% | 🔴 Baja | Urgente: Reducir gastos |
| Negativa | 🔴 Crítico | Gastas más de lo que ganas |

### Balance

| Balance | Estado | Recomendación |
|---------|--------|---------------|
| Positivo alto | 🟢 Saludable | Invertir o ahorrar |
| Positivo bajo | 🟡 Estable | Aumentar ahorro |
| Cero | 🟡 Justo | Crear fondo de emergencia |
| Negativo | 🔴 Alerta | Reducir gastos inmediatamente |

---

## 🔮 Mejoras Futuras Sugeridas

### Corto Plazo
- [ ] Filtros por categoría específica
- [ ] Exportar gráficas como imagen
- [ ] Compartir reportes por WhatsApp/Email
- [ ] Comparación mes actual vs mes anterior

### Medio Plazo
- [ ] Gráfica de tendencias con predicción
- [ ] Alertas cuando un gasto supera promedio
- [ ] Análisis de gastos por día de semana
- [ ] Identificación de gastos recurrentes

### Largo Plazo
- [ ] Machine Learning para predecir gastos
- [ ] Recomendaciones personalizadas de ahorro
- [ ] Comparativa con usuarios similares (anonimizado)
- [ ] Análisis de eficiencia por categoría
- [ ] Dashboard personalizable

---

## 🐛 Solución de Problemas

### Problema 1: Gráficas vacías

**Síntomas:**
- Mensaje "No hay datos"
- Gráficas no aparecen

**Solución:**
```bash
1. Verifica que hay transacciones agregadas
2. Asegúrate de estar en el período correcto
3. Verifica que las categorías no son null
4. Revisa filtros de período
```

### Problema 2: Porcentajes incorrectos

**Síntomas:**
- Porcentajes no suman 100%
- Valores extraños

**Solución:**
```bash
1. Verifica que solo se cuentan egresos
2. No se incluyen transferencias
3. Categorías están bien asignadas
4. Recalcula totales
```

### Problema 3: Gráfica de líneas con pocos puntos

**Síntomas:**
- Solo 1-2 puntos en la gráfica
- No se ve tendencia

**Solución:**
```bash
1. Agrega transacciones en meses anteriores
2. Cambia a período más amplio (3 meses o año)
3. Sistema requiere mínimo 2 meses con datos
```

---

## 📊 Datos de Prueba Sugeridos

```dart
// Para probar todas las funcionalidades:

Mes 1 (Agosto 2025):
- Ingresos: $2,000,000 (Salario: $1,500K, Freelance: $500K)
- Egresos: $1,600,000
  - Alimentación: $600,000
  - Transporte: $400,000
  - Servicios: $300,000
  - Entretenimiento: $200,000
  - Otros: $100,000

Mes 2 (Septiembre 2025):
- Ingresos: $1,800,000 (Salario: $1,500K, Freelance: $300K)
- Egresos: $1,400,000
  - Alimentación: $500,000
  - Transporte: $350,000
  - Servicios: $300,000
  - Entretenimiento: $150,000
  - Otros: $100,000

Mes 3 (Octubre 2025):
- Ingresos: $2,200,000 (Salario: $1,500K, Freelance: $700K)
- Egresos: $1,700,000
  - Alimentación: $650,000
  - Transporte: $450,000
  - Servicios: $300,000
  - Entretenimiento: $200,000
  - Otros: $100,000
```

---

## ✅ Checklist de Funcionalidad

### Visualizaciones
- [x] Selector de período (Mes/3 Meses/Año)
- [x] Tarjetas de estadísticas generales
- [x] Gráfica de dona (distribución egresos)
- [x] Leyenda de gráfica de dona
- [x] Lista detallada top 5 egresos
- [x] Gráfica de líneas (evolución temporal)
- [x] Top 5 mayores egresos
- [x] Top 5 mayores ingresos
- [x] Comparativa por canal

### Cálculos
- [x] Total ingresos
- [x] Total egresos
- [x] Balance
- [x] Tasa de ahorro
- [x] Porcentajes por categoría
- [x] Agrupación mensual
- [x] Balance por canal

### UI/UX
- [x] Colores distintivos por categoría
- [x] Iconos representativos
- [x] Formato de moneda
- [x] Estados vacíos con mensajes
- [x] Responsive design
- [x] Scrollable cuando es necesario

---

## 🎉 ¡Pantalla Completa!

La ReportsScreen está **100% funcional** con:

✅ 6 visualizaciones diferentes  
✅ Selector de período dinámico  
✅ Gráficas interactivas (dona y líneas)  
✅ Top categorías ordenadas  
✅ Comparativa de canales  
✅ Cálculos automáticos precisos  
✅ UI moderna y colorida  
✅ Sin errores de compilación  
✅ Manejo de estados vacíos  
✅ Responsive design  

**Progreso Total:** 5/6 pantallas completas (83%) 🎊

**Última pantalla:** HistoryScreen 🚀

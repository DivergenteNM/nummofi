# 🧪 Guía de Pruebas - Pantalla de Presupuestos

## 📋 Checklist de Pruebas

### ✅ Fase 1: Primera Carga (Sin Presupuestos)

1. **Abrir la app**
   ```bash
   flutter run
   ```

2. **Navegar a Presupuestos**
   - Hacer clic en el ícono de billetera (3er botón inferior)
   
3. **Verificar estado inicial**
   - [ ] Debe mostrar "Presupuestos Mensuales" como título
   - [ ] Tarjetas de resumen muestran $0 en planeado
   - [ ] Mensaje "No hay presupuestos establecidos"
   - [ ] Botón "Establecer Presupuestos" visible

---

### ✅ Fase 2: Establecer Presupuesto

1. **Hacer clic en "Editar Presupuestos"**
   - [ ] Se activa el modo edición
   - [ ] Aparecen campos de entrada
   - [ ] Botón "Guardar" se vuelve visible

2. **Llenar presupuestos de prueba**
   
   **Egresos:**
   - Alimentación: `250000`
   - Transporte: `100000`
   - Servicios y alojamiento: `150000`
   - Estudios y universidad: `200000`
   
   **Ingresos:**
   - Ayuda Familiar: `500000`
   - Emprendimiento: `300000`

3. **Guardar presupuestos**
   - [ ] Hacer clic en "Guardar"
   - [ ] Debe aparecer notificación verde: "Presupuestos guardados exitosamente"
   - [ ] Automáticamente cambia a modo vista
   - [ ] Tarjetas ahora muestran montos planeados

---

### ✅ Fase 3: Agregar Transacciones de Prueba

1. **Ir a la pantalla de Transacciones**
   - Hacer clic en el botón "+" (2do botón inferior)

2. **Agregar transacciones de ingresos**
   
   **Transacción 1:**
   - Tipo: `Ingreso`
   - Monto: `500000`
   - Categoría: `Ayuda Familiar`
   - Canal: `Nequi`
   - Descripción: `Mesada octubre`
   
   **Transacción 2:**
   - Tipo: `Ingreso`
   - Monto: `250000`
   - Categoría: `Emprendimiento`
   - Canal: `NuBank`
   - Descripción: `Venta productos`

3. **Agregar transacciones de egresos**
   
   **Transacción 3:**
   - Tipo: `Egreso`
   - Monto: `280000` ⚠️ (más que presupuesto de 250k)
   - Categoría: `Alimentación`
   - Canal: `Efectivo`
   - Descripción: `Mercado semanal`
   
   **Transacción 4:**
   - Tipo: `Egreso`
   - Monto: `80000`
   - Categoría: `Transporte`
   - Canal: `Nequi`
   - Descripción: `Transporte público`
   
   **Transacción 5:**
   - Tipo: `Egreso`
   - Monto: `150000`
   - Categoría: `Servicios y alojamiento`
   - Canal: `NuBank`
   - Descripción: `Internet y servicios`
   
   **Transacción 6:**
   - Tipo: `Egreso`
   - Monto: `180000`
   - Categoría: `Estudios y universidad`
   - Canal: `Nequi`
   - Descripción: `Material de estudio`

---

### ✅ Fase 4: Verificar Comparaciones

1. **Volver a Presupuestos**
   - Hacer clic en el botón de billetera

2. **Verificar Tarjeta de Ingresos**
   - [ ] Planeado: `$800,000`
   - [ ] Real: `$750,000`
   - [ ] Porcentaje: `93.8%`
   - [ ] Barra de progreso en verde
   - [ ] No hay alertas

3. **Verificar Tarjeta de Egresos**
   - [ ] Planeado: `$700,000`
   - [ ] Real: `$690,000`
   - [ ] Porcentaje: `98.6%`
   - [ ] Barra de progreso en verde (casi llena)
   - [ ] No hay alertas (aún dentro del presupuesto)

4. **Verificar Comparación de Egresos por Categoría**
   
   **Alimentación:**
   - [ ] Muestra: `$280,000 / $250,000`
   - [ ] Porcentaje: `112%`
   - [ ] Barra de progreso en ROJO
   - [ ] Alerta: ⚠️ "Sobrepresupuesto: $30,000"
   
   **Transporte:**
   - [ ] Muestra: `$80,000 / $100,000`
   - [ ] Porcentaje: `80%`
   - [ ] Barra de progreso en azul/verde
   - [ ] Sin alertas
   
   **Servicios y alojamiento:**
   - [ ] Muestra: `$150,000 / $150,000`
   - [ ] Porcentaje: `100%`
   - [ ] Barra de progreso completa
   - [ ] Sin alertas
   
   **Estudios y universidad:**
   - [ ] Muestra: `$180,000 / $200,000`
   - [ ] Porcentaje: `90%`
   - [ ] Barra de progreso en verde
   - [ ] Sin alertas

5. **Verificar Comparación de Ingresos por Categoría**
   
   **Ayuda Familiar:**
   - [ ] Muestra: `$500,000 / $500,000`
   - [ ] Porcentaje: `100%`
   - [ ] Barra completa en verde
   
   **Emprendimiento:**
   - [ ] Muestra: `$250,000 / $300,000`
   - [ ] Porcentaje: `83%`
   - [ ] Barra en verde

---

### ✅ Fase 5: Editar Presupuesto Existente

1. **Hacer clic en "Editar Presupuestos"**
   - [ ] Campos se llenan con valores actuales
   - [ ] Alimentación muestra: `250000`
   - [ ] Transporte muestra: `100000`
   - etc.

2. **Modificar valores**
   - Cambiar Alimentación de `250000` a `300000`
   - Cambiar Emprendimiento de `300000` a `250000`

3. **Guardar cambios**
   - [ ] Hacer clic en "Guardar"
   - [ ] Notificación de éxito
   - [ ] Vuelve a modo vista
   - [ ] Valores actualizados

4. **Verificar que alertas cambiaron**
   - [ ] Alimentación ahora muestra: `$280,000 / $300,000` (93%)
   - [ ] Ya NO hay alerta de sobrepresupuesto
   - [ ] Barra cambió a verde

---

### ✅ Fase 6: Pruebas de Cambio de Mes

1. **Cambiar al mes siguiente**
   - En el header, seleccionar "Noviembre 2025"

2. **Verificar comportamiento**
   - [ ] No hay presupuestos para noviembre
   - [ ] Mensaje "No hay presupuestos establecidos"
   - [ ] Transacciones de octubre no afectan noviembre
   - [ ] Puede establecer presupuestos nuevos

3. **Volver a octubre**
   - Seleccionar "Octubre 2025"
   - [ ] Presupuestos anteriores están guardados
   - [ ] Comparaciones siguen funcionando

---

### ✅ Fase 7: Pruebas de Persistencia

1. **Cerrar la app completamente**
   ```bash
   # En el emulador/dispositivo:
   - Presionar botón "atrás" hasta salir
   - O cerrar desde el task manager
   ```

2. **Volver a abrir la app**
   ```bash
   flutter run
   ```

3. **Navegar a Presupuestos**
   - [ ] Presupuestos siguen guardados
   - [ ] Comparaciones siguen mostrándose
   - [ ] No se perdió información

---

### ✅ Fase 8: Pruebas de Errores

1. **Sin conexión a internet**
   - Desactivar WiFi/Datos
   - Intentar guardar presupuesto
   - [ ] Debe mostrar error apropiado
   - [ ] No crashea la app

2. **Valores extremos**
   - Intentar poner valores muy grandes: `999999999`
   - [ ] Se guarda correctamente
   - [ ] Formato de moneda funciona
   
   - Intentar poner valores negativos: `-1000`
   - [ ] Sistema lo maneja apropiadamente

3. **Campos vacíos**
   - Dejar algunos campos en blanco
   - [ ] Se guardan como 0
   - [ ] No aparecen en comparaciones

---

## 🎯 Resultados Esperados

### Resumen Visual Esperado

```
╔══════════════════════════════════════════════════════════╗
║           PRESUPUESTOS MENSUALES                         ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  ┌─────────────────────┐  ┌─────────────────────┐      ║
║  │ 💰 INGRESOS         │  │ 💸 EGRESOS          │      ║
║  │                     │  │                     │      ║
║  │ Planeado: $800,000  │  │ Planeado: $700,000  │      ║
║  │ Real: $750,000      │  │ Real: $690,000      │      ║
║  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░  │  │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░  │      ║
║  │ 93.8%               │  │ 98.6%               │      ║
║  └─────────────────────┘  └─────────────────────┘      ║
║                                                          ║
║  ┌────────────────────────────────────────────┐         ║
║  │ COMPARACIÓN DE EGRESOS POR CATEGORÍA       │         ║
║  ├────────────────────────────────────────────┤         ║
║  │ Alimentación       $280K / $250K    ▓▓▓▓▓  │ 112%   ║
║  │ ⚠️ Sobrepresupuesto: $30,000               │         ║
║  │                                             │         ║
║  │ Transporte         $80K / $100K     ▓▓▓▓░  │ 80%    ║
║  │ Servicios          $150K / $150K    ▓▓▓▓▓  │ 100%   ║
║  │ Estudios           $180K / $200K    ▓▓▓▓░  │ 90%    ║
║  └────────────────────────────────────────────┘         ║
╚══════════════════════════════════════════════════════════╝
```

---

## 📊 Datos Finales Esperados

Después de todas las pruebas:

```yaml
Presupuesto Guardado en Firestore:
  Ruta: budgets/10-2025
  Datos:
    month: 10
    year: 2025
    incomes:
      "Ayuda Familiar": 500000
      "Emprendimiento": 300000  # (o 250000 si lo modificaste)
    expenses:
      "Alimentación": 250000  # (o 300000 si lo modificaste)
      "Transporte": 100000
      "Servicios y alojamiento": 150000
      "Estudios y universidad": 200000

Transacciones Reales:
  Total Ingresos: $750,000 (93.8% del presupuesto)
  Total Egresos: $690,000 (98.6% del presupuesto)
  
  Desglose Ingresos:
    - Ayuda Familiar: $500,000 (100%)
    - Emprendimiento: $250,000 (83%)
  
  Desglose Egresos:
    - Alimentación: $280,000 (112% ⚠️)
    - Transporte: $80,000 (80%)
    - Servicios: $150,000 (100%)
    - Estudios: $180,000 (90%)
```

---

## 🐛 Problemas Comunes y Soluciones

### Problema 1: No se guardan los presupuestos

**Síntomas:**
- Click en "Guardar" no hace nada
- No aparece notificación

**Solución:**
1. Verifica que Firebase está configurado
2. Revisa la consola: `flutter logs`
3. Asegúrate de que el usuario está autenticado
4. Verifica las reglas de Firestore

---

### Problema 2: No se muestran comparaciones

**Síntomas:**
- Mensaje "No hay presupuestos" incluso después de guardar

**Solución:**
1. Verifica que las transacciones tienen las categorías correctas
2. Asegúrate de estar en el mes correcto
3. Recarga la pantalla (navega a otra y vuelve)

---

### Problema 3: Porcentajes incorrectos

**Síntomas:**
- Porcentajes no cuadran con los montos

**Solución:**
1. Verifica que las transacciones son del mes correcto
2. Asegúrate de que el tipo de transacción es correcto
3. Revisa que las categorías coincidan exactamente

---

## ✅ Checklist Final

Después de completar todas las pruebas:

- [ ] ✅ Modo vista funciona correctamente
- [ ] ✅ Modo edición funciona correctamente
- [ ] ✅ Se guardan presupuestos en Firestore
- [ ] ✅ Se cargan presupuestos existentes
- [ ] ✅ Comparaciones se calculan correctamente
- [ ] ✅ Barras de progreso se muestran bien
- [ ] ✅ Alertas de sobrepresupuesto funcionan
- [ ] ✅ Cambio de mes funciona
- [ ] ✅ Persistencia funciona (reabrir app)
- [ ] ✅ UI se ve bien en tu dispositivo
- [ ] ✅ Notificaciones de éxito/error aparecen
- [ ] ✅ No hay crashes ni errores en consola

---

## 🎉 ¡Felicidades!

Si todos los checkboxes están marcados, la pantalla de presupuestos está:

✅ **100% Funcional**  
✅ **Probada y Verificada**  
✅ **Lista para Producción**

**Siguiente paso:** Implementar ReportsScreen o HistoryScreen 🚀

---

## 💡 Tips Adicionales

### Para Desarrollo Rápido
```dart
// En caso de necesitar datos de prueba rápido,
// puedes agregar un botón temporal para llenar
// presupuestos automáticamente:

void _fillTestData() {
  setState(() {
    _expenseBudget = {
      "Alimentación": 250000,
      "Transporte": 100000,
      "Servicios y alojamiento": 150000,
    };
    _incomeBudget = {
      "Ayuda Familiar": 500000,
      "Emprendimiento": 300000,
    };
  });
}
```

### Para Debug
```dart
// Agrega prints en lugares clave:
print('Guardando presupuesto: $_expenseBudget');
print('Transacciones del mes: ${provider.currentMonthTransactions.length}');
print('Total gastos calculado: ${provider.totalExpenses}');
```

¡Mucho éxito con las pruebas! 🎯

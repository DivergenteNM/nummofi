import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { initializeApp } from 'firebase/app';
import { getAuth, signInAnonymously, signInWithCustomToken, onAuthStateChanged } from 'firebase/auth';
import { getFirestore, doc, setDoc, collection, query, onSnapshot, addDoc, updateDoc, deleteDoc, runTransaction, getDocs } from 'firebase/firestore';
import { Chart as ChartJS, ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, Title as ChartTitle } from 'chart.js';
import { Doughnut, Bar } from 'react-chartjs-2';

// Registrar los componentes de Chart.js que se usarán
ChartJS.register(ArcElement, Tooltip, Legend, CategoryScale, LinearScale, BarElement, ChartTitle);

const firebaseConfig = typeof __firebase_config !== 'undefined' ? JSON.parse(__firebase_config) : {};
const appId = typeof __app_id !== 'undefined' ? __app_id : 'default-app-id';
const initialAuthToken = typeof __initial_auth_token !== 'undefined' ? __initial_auth_token : null;

// Categorías y canales predefinidos basados en los archivos de Excel
const categoriasIngreso = ["Ayuda Familiar", "Entradas esporádicas", "Emprendimiento", "Otros ingresos"];
const categoriasEgreso = ["Alimentación", "Transporte", "Servicios y alojamiento", "Estudios y universidad", "Salud y cuidado personal", "Eventos y vida social", "Tecnología y regalos", "Ahorros y proyectos", "Otros egresos"];
const canales = ["Nequi", "NuBank", "Efectivo"];
const tiposTransaccion = ["Ingreso", "Egreso", "Transferencia"];

// Helper para formatear números como moneda
const formatCurrency = (amount) => {
  return new Intl.NumberFormat('es-CO', { style: 'currency', currency: 'COP' }).format(amount);
};

const Header = ({ title }) => (
  <div className="bg-white p-4 rounded-lg shadow-md mb-4 text-center">
    <h1 className="text-3xl font-bold text-gray-800">{title}</h1>
  </div>
);

// Componente para la notificación temporal (reemplazo de alert)
const Notification = ({ message, type, onClose }) => {
  const [visible, setVisible] = useState(true);

  useEffect(() => {
    const timer = setTimeout(() => {
      setVisible(false);
      onClose();
    }, 3000);
    return () => clearTimeout(timer);
  }, [onClose]);

  if (!visible) return null;

  const bgColor = type === 'success' ? 'bg-green-500' : 'bg-red-500';
  const icon = type === 'success'
    ? <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" viewBox="0 0 20 20" fill="currentColor"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" /></svg>
    : <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" viewBox="0 0 20 20" fill="currentColor"><path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" /></svg>;

  return (
    <div className={`fixed bottom-4 left-1/2 -translate-x-1/2 flex items-center p-4 rounded-full shadow-lg text-white z-50 transition-transform duration-300 ${bgColor}`}>
      <span className="mr-2">{icon}</span>
      <span>{message}</span>
    </div>
  );
};


const App = () => {
  const [db, setDb] = useState(null);
  const [auth, setAuth] = useState(null);
  const [userId, setUserId] = useState(null);
  const [loading, setLoading] = useState(true);
  const [currentView, setCurrentView] = useState('dashboard');
  const [transactions, setTransactions] = useState([]);
  const [budgets, setBudgets] = useState({});
  const [currentMonth, setCurrentMonth] = useState(new Date().getMonth() + 1); // 1-12
  const [currentYear, setCurrentYear] = useState(new Date().getFullYear());
  const [channelsData, setChannelsData] = useState([]);
  const [monthlySummaries, setMonthlySummaries] = useState([]);
  const [editTransaction, setEditTransaction] = useState(null);
  const [notification, setNotification] = useState(null);

  const showNotification = (message, type = 'success') => {
    setNotification({ message, type });
  };

  const getCollectionPath = (collectionName) => {
    return `artifacts/${appId}/users/${userId}/${collectionName}`;
  };

  // Inicialización de Firebase
  useEffect(() => {
    try {
      const app = initializeApp(firebaseConfig);
      const firestore = getFirestore(app);
      const authInstance = getAuth(app);
      setDb(firestore);
      setAuth(authInstance);

      onAuthStateChanged(authInstance, async (user) => {
        if (user) {
          setUserId(user.uid);
        } else {
          try {
            if (initialAuthToken) {
              await signInWithCustomToken(authInstance, initialAuthToken);
            } else {
              await signInAnonymously(authInstance);
            }
          } catch (error) {
            console.error("Error signing in:", error);
            showNotification('Error de autenticación.', 'error');
          }
        }
      });
    } catch (error) {
      console.error("Firebase initialization failed:", error);
      showNotification('Error al inicializar la base de datos.', 'error');
    }
  }, []);

  // Sincronización de datos con Firestore
  useEffect(() => {
    if (!db || !userId) return;

    setLoading(true);

    const transactionsRef = collection(db, getCollectionPath('transactions'));
    const budgetsRef = collection(db, getCollectionPath('budgets'));
    const summariesRef = collection(db, getCollectionPath('monthlySummaries'));

    const unsubTransactions = onSnapshot(transactionsRef, (snapshot) => {
      const docs = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setTransactions(docs);
      setLoading(false);
    });

    const unsubBudgets = onSnapshot(budgetsRef, (snapshot) => {
      const budgetData = {};
      snapshot.docs.forEach(doc => {
        const data = doc.data();
        budgetData[`${data.month}-${data.year}`] = data;
      });
      setBudgets(budgetData);
    });

    const unsubSummaries = onSnapshot(summariesRef, (snapshot) => {
      const docs = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
      setMonthlySummaries(docs);
    });

    return () => {
      unsubTransactions();
      unsubBudgets();
      unsubSummaries();
    };
  }, [db, userId]);

  // Funciones de cálculo y manejo de datos
  const calculateBalances = useCallback(() => {
    if (!transactions.length) {
      setChannelsData(canales.map(channel => ({ name: channel, balance: 0 })));
      return;
    }

    const currentMonthTransactions = transactions.filter(t => new Date(t.date).getMonth() + 1 === currentMonth && new Date(t.date).getFullYear() === currentYear);
    
    // Obtener saldos iniciales del mes anterior
    const previousMonthSummary = monthlySummaries.find(s => {
      const date = new Date(currentYear, currentMonth - 2, 1);
      return s.month === date.getMonth() + 1 && s.year === date.getFullYear();
    });

    const initialBalances = previousMonthSummary ? previousMonthSummary.finalBalances : { "Nequi": 0, "NuBank": 0, "Efectivo": 0 };

    const newBalances = { ...initialBalances };
    currentMonthTransactions.forEach(t => {
      if (t.type === "Ingreso") {
        newBalances[t.channel] = (newBalances[t.channel] || 0) + t.amount;
      } else if (t.type === "Egreso") {
        newBalances[t.channel] = (newBalances[t.channel] || 0) - t.amount;
      } else if (t.type === "Transferencia") {
        newBalances[t.channelFrom] = (newBalances[t.channelFrom] || 0) - t.amount;
        newBalances[t.channelTo] = (newBalances[t.channelTo] || 0) + t.amount;
      }
    });

    const finalChannelData = canales.map(channel => ({
      name: channel,
      balance: newBalances[channel] || initialBalances[channel] || 0
    }));
    setChannelsData(finalChannelData);
  }, [transactions, currentMonth, currentYear, monthlySummaries]);

  // Ejecutar el cálculo de balances cada vez que las transacciones o el mes cambian
  useEffect(() => {
    calculateBalances();
  }, [transactions, currentMonth, currentYear, monthlySummaries, calculateBalances]);

  const getMonthlyData = useCallback(() => {
    const filteredTransactions = transactions.filter(t => {
      const tDate = new Date(t.date);
      return tDate.getMonth() + 1 === currentMonth && tDate.getFullYear() === currentYear;
    });

    const totalIncome = filteredTransactions
      .filter(t => t.type === 'Ingreso')
      .reduce((sum, t) => sum + t.amount, 0);

    const totalExpenses = filteredTransactions
      .filter(t => t.type === 'Egreso')
      .reduce((sum, t) => sum + t.amount, 0);

    const expensesByCategory = filteredTransactions
      .filter(t => t.type === 'Egreso')
      .reduce((acc, t) => {
        acc[t.category] = (acc[t.category] || 0) + t.amount;
        return acc;
      }, {});

    const monthlyBudgets = budgets[`${currentMonth}-${currentYear}`] || {
      incomes: {},
      expenses: {}
    };

    return { filteredTransactions, totalIncome, totalExpenses, expensesByCategory, monthlyBudgets };
  }, [transactions, budgets, currentMonth, currentYear]);

  const { filteredTransactions, totalIncome, totalExpenses, expensesByCategory, monthlyBudgets } = useMemo(() => getMonthlyData(), [getMonthlyData]);

  // Transacciones
  const addTransaction = async (newTransaction) => {
    if (!db || !userId) return;
    try {
      const colRef = collection(db, getCollectionPath('transactions'));
      await addDoc(colRef, newTransaction);
      showNotification('Transacción agregada exitosamente.');
    } catch (e) {
      console.error("Error adding document: ", e);
      showNotification('Error al agregar la transacción.', 'error');
    }
  };

  const updateTransaction = async (id, updatedFields) => {
    if (!db || !userId) return;
    try {
      const docRef = doc(db, getCollectionPath('transactions'), id);
      await updateDoc(docRef, updatedFields);
      showNotification('Transacción actualizada exitosamente.');
      setEditTransaction(null);
    } catch (e) {
      console.error("Error updating document: ", e);
      showNotification('Error al actualizar la transacción.', 'error');
    }
  };

  const deleteTransaction = async (id) => {
    if (!db || !userId) return;
    try {
      const docRef = doc(db, getCollectionPath('transactions'), id);
      await deleteDoc(docRef);
      showNotification('Transacción eliminada exitosamente.');
    } catch (e) {
      console.error("Error deleting document: ", e);
      showNotification('Error al eliminar la transacción.', 'error');
    }
  };

  // Manejo de presupuestos
  const saveBudgets = async (newBudgets) => {
    if (!db || !userId) return;
    try {
      const budgetDocRef = doc(db, getCollectionPath('budgets'), `${currentMonth}-${currentYear}`);
      await setDoc(budgetDocRef, { ...newBudgets, month: currentMonth, year: currentYear });
      showNotification('Presupuestos guardados exitosamente.');
    } catch (e) {
      console.error("Error saving budgets: ", e);
      showNotification('Error al guardar los presupuestos.', 'error');
    }
  };

  // Cierre de mes
  const closeMonth = async () => {
    if (!db || !userId) return;
    try {
      await runTransaction(db, async (transaction) => {
        // 1. Guardar resumen del mes actual
        const currentSummaryDocRef = doc(db, getCollectionPath('monthlySummaries'), `${currentMonth}-${currentYear}`);
        const previousMonthSummary = monthlySummaries.find(s => {
          const date = new Date(currentYear, currentMonth - 2, 1);
          return s.month === date.getMonth() + 1 && s.year === date.getFullYear();
        });
        const initialBalances = previousMonthSummary ? previousMonthSummary.finalBalances : { "Nequi": 0, "NuBank": 0, "Efectivo": 0 };
        const finalBalances = channelsData.reduce((acc, c) => ({ ...acc, [c.name]: c.balance }), {});

        const summaryData = {
          month: currentMonth,
          year: currentYear,
          initialBalances: initialBalances,
          finalBalances: finalBalances,
          totalIncome: totalIncome,
          totalExpenses: totalExpenses,
          budgetComparison: {
            income: {
              planned: Object.values(monthlyBudgets.incomes || {}).reduce((sum, val) => sum + val, 0),
              actual: totalIncome
            },
            expense: {
              planned: Object.values(monthlyBudgets.expenses || {}).reduce((sum, val) => sum + val, 0),
              actual: totalExpenses
            }
          }
        };
        transaction.set(currentSummaryDocRef, summaryData);
        showNotification('Mes cerrado exitosamente.');
      });
    } catch (e) {
      console.error("Error closing month: ", e);
      showNotification('Error al cerrar el mes.', 'error');
    }
  };

  const getMonthName = (month) => {
    const date = new Date();
    date.setMonth(month - 1);
    return date.toLocaleString('es-CO', { month: 'long' });
  };

  const canCloseMonth = useMemo(() => {
    const summaryExists = monthlySummaries.some(s => s.month === currentMonth && s.year === currentYear);
    return !summaryExists;
  }, [monthlySummaries, currentMonth, currentYear]);

  if (!userId) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-100 p-4">
        <div className="flex items-center space-x-2 text-gray-600">
          <svg className="animate-spin h-5 w-5 text-gray-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span>Cargando...</span>
        </div>
      </div>
    );
  }

  // Componentes de la interfaz
  const DashboardView = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <Header title="Resumen General" />
      <div className="lg:col-span-3">
        <h2 className="text-xl font-semibold text-gray-700 mb-4">Saldos Actuales</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4">
          {channelsData.map(c => (
            <div key={c.name} className="bg-white p-6 rounded-lg shadow-md flex flex-col items-center justify-center">
              <span className="text-xl font-medium text-gray-500">{c.name}</span>
              <span className={`text-2xl md:text-3xl font-bold mt-2 ${c.balance >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                {formatCurrency(c.balance)}
              </span>
            </div>
          ))}
        </div>
      </div>

      <div className="lg:col-span-3">
        <h2 className="text-xl font-semibold text-gray-700 mt-6 mb-4">Movimiento Mensual</h2>
        <div className="bg-white p-6 rounded-lg shadow-md">
          <Bar
            data={{
              labels: ['Ingresos', 'Egresos'],
              datasets: [
                {
                  label: 'Valores Reales',
                  data: [totalIncome, totalExpenses],
                  backgroundColor: ['rgba(75, 192, 192, 0.6)', 'rgba(255, 99, 132, 0.6)'],
                  borderColor: ['rgba(75, 192, 192, 1)', 'rgba(255, 99, 132, 1)'],
                  borderWidth: 1,
                },
              ],
            }}
            options={{ responsive: true, maintainAspectRatio: false }}
          />
        </div>
      </div>
      
      <div className="lg:col-span-3 mt-6">
        <h2 className="text-xl font-semibold text-gray-700 mb-4">Flujo de dinero por Canal (Mes)</h2>
        <div className="bg-white p-6 rounded-lg shadow-md">
          <Bar
            data={{
              labels: canales,
              datasets: [
                {
                  label: 'Saldo del Mes',
                  data: channelsData.map(c => c.balance),
                  backgroundColor: ['rgba(75, 192, 192, 0.6)', 'rgba(54, 162, 235, 0.6)', 'rgba(255, 206, 86, 0.6)'],
                  borderColor: ['rgba(75, 192, 192, 1)', 'rgba(54, 162, 235, 1)', 'rgba(255, 206, 86, 1)'],
                  borderWidth: 1,
                },
              ],
            }}
            options={{ responsive: true, maintainAspectRatio: false }}
          />
        </div>
      </div>
    </div>
  );

  const TransactionForm = ({ transaction, onSave, onCancel }) => {
    const [formData, setFormData] = useState(transaction || {
      date: new Date().toISOString().split('T')[0],
      description: '',
      amount: '',
      type: 'Egreso',
      category: categoriasEgreso[0],
      channel: canales[0],
      channelFrom: '',
      channelTo: ''
    });

    const handleChange = (e) => {
      const { name, value } = e.target;
      setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = (e) => {
      e.preventDefault();
      onSave({
        ...formData,
        amount: parseFloat(formData.amount),
        date: formData.date
      });
    };

    const isTransfer = formData.type === 'Transferencia';
    const categories = formData.type === 'Ingreso' ? categoriasIngreso : categoriasEgreso;

    return (
      <form onSubmit={handleSubmit} className="bg-white p-6 rounded-lg shadow-md space-y-4">
        <h2 className="text-xl font-semibold mb-4">{transaction ? 'Editar Transacción' : 'Añadir Transacción'}</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <label className="block">
            <span className="text-gray-700">Fecha</span>
            <input type="date" name="date" value={formData.date} onChange={handleChange} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50" />
          </label>
          <label className="block">
            <span className="text-gray-700">Tipo</span>
            <select name="type" value={formData.type} onChange={handleChange} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50">
              {tiposTransaccion.map(type => <option key={type} value={type}>{type}</option>)}
            </select>
          </label>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <label className="block">
            <span className="text-gray-700">Monto</span>
            <input type="number" name="amount" value={formData.amount} onChange={handleChange} required min="0" step="0.01" className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50" />
          </label>
          {isTransfer ? (
            <>
              <label className="block">
                <span className="text-gray-700">Desde el Canal</span>
                <select name="channelFrom" value={formData.channelFrom} onChange={handleChange} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50">
                  <option value="">Seleccionar</option>
                  {canales.map(c => <option key={c} value={c}>{c}</option>)}
                </select>
              </label>
              <label className="block">
                <span className="text-gray-700">Hacia el Canal</span>
                <select name="channelTo" value={formData.channelTo} onChange={handleChange} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50">
                  <option value="">Seleccionar</option>
                  {canales.map(c => <option key={c} value={c}>{c}</option>)}
                </select>
              </label>
            </>
          ) : (
            <>
              <label className="block">
                <span className="text-gray-700">Canal</span>
                <select name="channel" value={formData.channel} onChange={handleChange} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50">
                  {canales.map(c => <option key={c} value={c}>{c}</option>)}
                </select>
              </label>
              <label className="block">
                <span className="text-gray-700">Categoría</span>
                <select name="category" value={formData.category} onChange={handleChange} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50">
                  {categories.map(cat => <option key={cat} value={cat}>{cat}</option>)}
                </select>
              </label>
            </>
          )}
        </div>
        <label className="block">
          <span className="text-gray-700">Descripción</span>
          <input type="text" name="description" value={formData.description} onChange={handleChange} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50" />
        </label>
        <div className="flex justify-end space-x-2">
          <button type="button" onClick={onCancel} className="px-4 py-2 rounded-md bg-gray-200 text-gray-700 font-medium hover:bg-gray-300 transition-colors">Cancelar</button>
          <button type="submit" className="px-4 py-2 rounded-md bg-indigo-600 text-white font-medium hover:bg-indigo-700 transition-colors">Guardar Transacción</button>
        </div>
      </form>
    );
  };

  const TransactionsView = () => (
    <div className="space-y-6">
      <Header title="Registro de Transacciones" />
      <TransactionForm
        onSave={(t) => addTransaction(t)}
        onCancel={() => setEditTransaction(null)}
      />
      {editTransaction && (
        <TransactionForm
          transaction={editTransaction}
          onSave={(t) => updateTransaction(t.id, t)}
          onCancel={() => setEditTransaction(null)}
        />
      )}
      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-xl font-semibold mb-4">Historial del Mes</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tipo</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Descripción</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Monto</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Categoría</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Canal</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredTransactions.sort((a, b) => new Date(b.date) - new Date(a.date)).map(t => (
                <tr key={t.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{t.date}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{t.type}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{t.description}</td>
                  <td className={`px-6 py-4 whitespace-nowrap text-sm font-medium ${t.type === 'Ingreso' ? 'text-green-600' : 'text-red-600'}`}>{formatCurrency(t.amount)}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{t.category}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{t.channel || `${t.channelFrom} → ${t.channelTo}`}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button onClick={() => setEditTransaction(t)} className="text-indigo-600 hover:text-indigo-900 transition-colors">
                      <svg xmlns="http://www.w3.org/2000/svg" className="inline-block w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.536l10.232-10.232z" /></svg>
                      Editar
                    </button>
                    <button onClick={() => deleteTransaction(t.id)} className="text-red-600 hover:text-red-900 ml-4 transition-colors">
                      <svg xmlns="http://www.w3.org/2000/svg" className="inline-block w-4 h-4 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" /></svg>
                      Eliminar
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );

  const BudgetsView = () => {
    const [incomeBudget, setIncomeBudget] = useState(monthlyBudgets.incomes || {});
    const [expenseBudget, setExpenseBudget] = useState(monthlyBudgets.expenses || {});

    useEffect(() => {
      setIncomeBudget(monthlyBudgets.incomes || {});
      setExpenseBudget(monthlyBudgets.expenses || {});
    }, [monthlyBudgets]);

    const handleSave = () => {
      saveBudgets({ incomes: incomeBudget, expenses: expenseBudget });
    };

    const totalPlannedIncome = Object.values(incomeBudget).reduce((sum, val) => sum + (val || 0), 0);
    const totalActualIncome = filteredTransactions.filter(t => t.type === 'Ingreso').reduce((sum, t) => sum + t.amount, 0);

    const totalPlannedExpense = Object.values(expenseBudget).reduce((sum, val) => sum + (val || 0), 0);
    const totalActualExpense = filteredTransactions.filter(t => t.type === 'Egreso').reduce((sum, t) => sum + t.amount, 0);

    return (
      <div className="space-y-6">
        <Header title="Presupuestos Mensuales" />
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-semibold mb-4">Ingresos y Egresos</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="p-4 rounded-md border border-gray-200">
              <h3 className="font-bold text-lg mb-2">Ingresos</h3>
              <p>Planeado: <span className="text-indigo-600 font-semibold">{formatCurrency(totalPlannedIncome)}</span></p>
              <p>Real: <span className="text-green-600 font-semibold">{formatCurrency(totalActualIncome)}</span></p>
            </div>
            <div className="p-4 rounded-md border border-gray-200">
              <h3 className="font-bold text-lg mb-2">Egresos</h3>
              <p>Planeado: <span className="text-indigo-600 font-semibold">{formatCurrency(totalPlannedExpense)}</span></p>
              <p>Real: <span className="text-red-600 font-semibold">{formatCurrency(totalActualExpense)}</span></p>
            </div>
          </div>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-semibold mb-4">Establecer Presupuestos por Categoría</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <h3 className="text-lg font-medium mb-2">Presupuesto de Egresos</h3>
              {categoriasEgreso.map(cat => (
                <div key={cat} className="flex items-center space-x-2 my-2">
                  <span className="w-1/2 text-gray-700">{cat}</span>
                  <input
                    type="number"
                    value={expenseBudget[cat] || ''}
                    onChange={(e) => setExpenseBudget(prev => ({ ...prev, [cat]: parseFloat(e.target.value) || 0 }))}
                    className="flex-1 rounded-md border-gray-300 shadow-sm"
                  />
                </div>
              ))}
            </div>
            <div>
              <h3 className="text-lg font-medium mb-2">Presupuesto de Ingresos</h3>
              {categoriasIngreso.map(cat => (
                <div key={cat} className="flex items-center space-x-2 my-2">
                  <span className="w-1/2 text-gray-700">{cat}</span>
                  <input
                    type="number"
                    value={incomeBudget[cat] || ''}
                    onChange={(e) => setIncomeBudget(prev => ({ ...prev, [cat]: parseFloat(e.target.value) || 0 }))}
                    className="flex-1 rounded-md border-gray-300 shadow-sm"
                  />
                </div>
              ))}
            </div>
          </div>
          <div className="flex justify-end mt-4">
            <button onClick={handleSave} className="px-6 py-2 rounded-md bg-indigo-600 text-white font-medium hover:bg-indigo-700 transition-colors">
              Guardar Presupuestos
            </button>
          </div>
        </div>
      </div>
    );
  };

  const ReportsView = () => {
    // Datos para el gráfico de distribución de egresos
    const pieData = {
      labels: Object.keys(expensesByCategory),
      datasets: [
        {
          data: Object.values(expensesByCategory),
          backgroundColor: [
            '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40', '#E46651', '#7FCDFF', '#FFD180'
          ],
          hoverBackgroundColor: [
            '#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0', '#9966FF', '#FF9F40', '#E46651', '#7FCDFF', '#FFD180'
          ],
        },
      ],
    };

    // Datos para el gráfico de evolución de ingresos y egresos
    const monthlyIncomeExpenseData = useMemo(() => {
      const allMonths = Array.from(new Set(transactions.map(t => `${new Date(t.date).getFullYear()}-${new Date(t.date).getMonth() + 1}`))).sort();
      const incomeMap = {};
      const expenseMap = {};

      transactions.forEach(t => {
        const monthYear = `${new Date(t.date).getFullYear()}-${new Date(t.date).getMonth() + 1}`;
        if (t.type === 'Ingreso') {
          incomeMap[monthYear] = (incomeMap[monthYear] || 0) + t.amount;
        } else if (t.type === 'Egreso') {
          expenseMap[monthYear] = (expenseMap[monthYear] || 0) + t.amount;
        }
      });
      
      const chartLabels = allMonths.map(my => {
        const [year, month] = my.split('-');
        return `${getMonthName(parseInt(month, 10))} ${year}`;
      });

      return {
        labels: chartLabels,
        datasets: [
          {
            label: 'Ingresos',
            data: allMonths.map(my => incomeMap[my] || 0),
            backgroundColor: 'rgba(75, 192, 192, 0.6)',
            borderColor: 'rgba(75, 192, 192, 1)',
            borderWidth: 1,
          },
          {
            label: 'Egresos',
            data: allMonths.map(my => expenseMap[my] || 0),
            backgroundColor: 'rgba(255, 99, 132, 0.6)',
            borderColor: 'rgba(255, 99, 132, 1)',
            borderWidth: 1,
          },
        ],
      };
    }, [transactions]);


    return (
      <div className="space-y-6">
        <Header title="Reportes y Gráficas" />
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h2 className="text-xl font-semibold mb-4">Distribución de Egresos</h2>
            {Object.keys(expensesByCategory).length > 0 ? (
              <Doughnut data={pieData} options={{ responsive: true, maintainAspectRatio: false }} />
            ) : (
              <p className="text-center text-gray-500">No hay egresos para el mes seleccionado.</p>
            )}
          </div>
          <div className="bg-white p-6 rounded-lg shadow-md">
            <h2 className="text-xl font-semibold mb-4">Evolución Ingresos/Egresos</h2>
            <Bar data={monthlyIncomeExpenseData} options={{ responsive: true, maintainAspectRatio: false }} />
          </div>
        </div>
      </div>
    );
  };

  const HistoryView = () => (
    <div className="space-y-6">
      <Header title="Historial y Cierre de Mes" />
      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-xl font-semibold mb-4">Cierre de Mes Actual</h2>
        <p className="mb-4 text-gray-600">Al cerrar el mes, los saldos finales se guardarán como saldos iniciales del siguiente mes y el historial del mes actual quedará bloqueado.</p>
        <button
          onClick={closeMonth}
          disabled={!canCloseMonth}
          className={`px-6 py-3 rounded-md font-medium text-white transition-colors ${canCloseMonth ? 'bg-green-600 hover:bg-green-700' : 'bg-gray-400 cursor-not-allowed'}`}
        >
          Cerrar Mes: {getMonthName(currentMonth)} {currentYear}
        </button>
        {!canCloseMonth && <p className="text-sm text-red-500 mt-2">Este mes ya ha sido cerrado.</p>}
      </div>
      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-xl font-semibold mb-4">Historial de Meses Cerrados</h2>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mes</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ingresos Totales</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Egresos Totales</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Saldo Final</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {monthlySummaries.sort((a,b) => new Date(b.year, b.month -1) - new Date(a.year, a.month - 1)).map(s => (
                <tr key={`${s.month}-${s.year}`} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{getMonthName(s.month)} {s.year}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-green-600">{formatCurrency(s.totalIncome)}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-red-600">{formatCurrency(s.totalExpenses)}</td>
                  <td className={`px-6 py-4 whitespace-nowrap text-sm font-medium ${Object.values(s.finalBalances).reduce((sum, val) => sum + val, 0) >= 0 ? 'text-green-600' : 'text-red-600'}`}>
                    {formatCurrency(Object.values(s.finalBalances).reduce((sum, val) => sum + val, 0))}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
  
  const renderView = () => {
    switch (currentView) {
      case 'dashboard':
        return <DashboardView />;
      case 'transactions':
        return <TransactionsView />;
      case 'budgets':
        return <BudgetsView />;
      case 'reports':
        return <ReportsView />;
      case 'history':
        return <HistoryView />;
      default:
        return <DashboardView />;
    }
  };

  return (
    <div className="min-h-screen bg-gray-100 font-sans antialiased text-gray-800 p-4 sm:p-6">
      <style>{`
        body {
          font-family: 'Inter', sans-serif;
        }
      `}</style>
      <script src="https://cdn.tailwindcss.com"></script>
      <div className="max-w-7xl mx-auto">
        <div className="bg-white p-4 rounded-lg shadow-md mb-6 flex justify-between items-center flex-wrap">
          <div className="flex items-center space-x-2 mb-2 sm:mb-0">
            <select
              value={currentMonth}
              onChange={(e) => setCurrentMonth(parseInt(e.target.value))}
              className="bg-gray-50 rounded-md border border-gray-300 p-2 text-sm"
            >
              {[...Array(12).keys()].map(i => (
                <option key={i + 1} value={i + 1}>{getMonthName(i + 1)}</option>
              ))}
            </select>
            <input
              type="number"
              value={currentYear}
              onChange={(e) => setCurrentYear(parseInt(e.target.value))}
              className="bg-gray-50 rounded-md border border-gray-300 p-2 text-sm w-24"
            />
          </div>
          <div className="flex items-center space-x-2 flex-wrap">
            <button
              onClick={() => setCurrentView('dashboard')}
              className={`p-3 rounded-full transition-colors ${currentView === 'dashboard' ? 'bg-indigo-600 text-white' : 'text-gray-600 hover:bg-gray-200'}`}
              aria-label="Dashboard"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 9V7a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2m2 4h10a2 2 0 002-2v-6a2 2 0 00-2-2H9m0 0V9m0 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" /></svg>
            </button>
            <button
              onClick={() => setCurrentView('transactions')}
              className={`p-3 rounded-full transition-colors ${currentView === 'transactions' ? 'bg-indigo-600 text-white' : 'text-gray-600 hover:bg-gray-200'}`}
              aria-label="Transactions"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" /></svg>
            </button>
            <button
              onClick={() => setCurrentView('budgets')}
              className={`p-3 rounded-full transition-colors ${currentView === 'budgets' ? 'bg-indigo-600 text-white' : 'text-gray-600 hover:bg-gray-200'}`}
              aria-label="Budgets"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4" /></svg>
            </button>
            <button
              onClick={() => setCurrentView('reports')}
              className={`p-3 rounded-full transition-colors ${currentView === 'reports' ? 'bg-indigo-600 text-white' : 'text-gray-600 hover:bg-gray-200'}`}
              aria-label="Reports"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z" /></svg>
            </button>
            <button
              onClick={() => setCurrentView('history')}
              className={`p-3 rounded-full transition-colors ${currentView === 'history' ? 'bg-indigo-600 text-white' : 'text-gray-600 hover:bg-gray-200'}`}
              aria-label="History"
            >
              <svg xmlns="http://www.w3.org/2000/svg" className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" /></svg>
            </button>
          </div>
        </div>
        {loading ? (
          <div className="flex items-center justify-center min-h-[calc(100vh-10rem)]">
            <div className="flex items-center space-x-2 text-gray-600">
              <svg className="animate-spin h-5 w-5 text-gray-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <span>Cargando datos...</span>
            </div>
          </div>
        ) : (
          renderView()
        )}
      </div>
      {notification && <Notification message={notification.message} type={notification.type} onClose={() => setNotification(null)} />}
    </div>
  );
};

export default App;

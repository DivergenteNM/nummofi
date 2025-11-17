import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'NummoFi - Financial Management'**
  String get appTitle;

  /// Dashboard label
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Transactions label
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Budgets label
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// Reports label
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// History label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Goals label
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions recorded'**
  String get noTransactions;

  /// No description provided for @setBudgets.
  ///
  /// In en, this message translates to:
  /// **'Set Budgets'**
  String get setBudgets;

  /// No description provided for @editBudgets.
  ///
  /// In en, this message translates to:
  /// **'Edit Budgets'**
  String get editBudgets;

  /// No description provided for @viewSummary.
  ///
  /// In en, this message translates to:
  /// **'View Summary'**
  String get viewSummary;

  /// No description provided for @budgetSummary.
  ///
  /// In en, this message translates to:
  /// **'Budget Summary'**
  String get budgetSummary;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @exceeded.
  ///
  /// In en, this message translates to:
  /// **'Exceeded'**
  String get exceeded;

  /// No description provided for @noBudgets.
  ///
  /// In en, this message translates to:
  /// **'No budgets set'**
  String get noBudgets;

  /// No description provided for @monthlyReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly Report'**
  String get monthlyReport;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @incomeVsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Income vs Expenses'**
  String get incomeVsExpenses;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by Date'**
  String get filterByDate;

  /// No description provided for @filterByCategory.
  ///
  /// In en, this message translates to:
  /// **'Filter by Category'**
  String get filterByCategory;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// No description provided for @editGoal.
  ///
  /// In en, this message translates to:
  /// **'Edit Goal'**
  String get editGoal;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Goal Name'**
  String get goalName;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get targetAmount;

  /// No description provided for @currentAmount.
  ///
  /// In en, this message translates to:
  /// **'Current Amount'**
  String get currentAmount;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @noGoals.
  ///
  /// In en, this message translates to:
  /// **'No goals created'**
  String get noGoals;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @authenticationError.
  ///
  /// In en, this message translates to:
  /// **'Authentication error'**
  String get authenticationError;

  /// No description provided for @notAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated'**
  String get notAuthenticated;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter Description'**
  String get enterDescription;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get transport;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @systemMode.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemMode;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @themeChanged.
  ///
  /// In en, this message translates to:
  /// **'Theme changed'**
  String get themeChanged;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  /// No description provided for @generalSummary.
  ///
  /// In en, this message translates to:
  /// **'General Summary'**
  String get generalSummary;

  /// No description provided for @generateAIReport.
  ///
  /// In en, this message translates to:
  /// **'Generate AI Report'**
  String get generateAIReport;

  /// No description provided for @currentBalances.
  ///
  /// In en, this message translates to:
  /// **'Current Balances'**
  String get currentBalances;

  /// No description provided for @monthlyMovement.
  ///
  /// In en, this message translates to:
  /// **'Monthly Movement'**
  String get monthlyMovement;

  /// No description provided for @channelDistribution.
  ///
  /// In en, this message translates to:
  /// **'Channel Distribution'**
  String get channelDistribution;

  /// No description provided for @incomes.
  ///
  /// In en, this message translates to:
  /// **'Incomes'**
  String get incomes;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @noBalancesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No balances available'**
  String get noBalancesAvailable;

  /// No description provided for @totalAvailable.
  ///
  /// In en, this message translates to:
  /// **'Total Available'**
  String get totalAvailable;

  /// No description provided for @monthlyBudgets.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budgets'**
  String get monthlyBudgets;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @actual.
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actual;

  /// No description provided for @incomeBudget.
  ///
  /// In en, this message translates to:
  /// **'Income Budget'**
  String get incomeBudget;

  /// No description provided for @expenseBudget.
  ///
  /// In en, this message translates to:
  /// **'Expense Budget'**
  String get expenseBudget;

  /// No description provided for @incomeComparison.
  ///
  /// In en, this message translates to:
  /// **'Income Comparison by Category'**
  String get incomeComparison;

  /// No description provided for @expenseComparison.
  ///
  /// In en, this message translates to:
  /// **'Expense Comparison by Category'**
  String get expenseComparison;

  /// No description provided for @budgetsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Budgets saved successfully'**
  String get budgetsSavedSuccessfully;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving'**
  String get errorSaving;

  /// No description provided for @monthlyAIReport.
  ///
  /// In en, this message translates to:
  /// **'Monthly AI Report'**
  String get monthlyAIReport;

  /// No description provided for @generateMonthlyAIReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Monthly Report with AI'**
  String get generateMonthlyAIReport;

  /// No description provided for @generateCompleteReport.
  ///
  /// In en, this message translates to:
  /// **'Generate a complete report with AI analysis'**
  String get generateCompleteReport;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating report...'**
  String get generating;

  /// No description provided for @whatIncludes.
  ///
  /// In en, this message translates to:
  /// **'What\'s included?'**
  String get whatIncludes;

  /// No description provided for @summaryIncomeExpenses.
  ///
  /// In en, this message translates to:
  /// **'📊 Income and expense summary'**
  String get summaryIncomeExpenses;

  /// No description provided for @savingsGoalsTracking.
  ///
  /// In en, this message translates to:
  /// **'🎯 Savings goals tracking'**
  String get savingsGoalsTracking;

  /// No description provided for @categoryBreakdown.
  ///
  /// In en, this message translates to:
  /// **'💰 Category breakdown'**
  String get categoryBreakdown;

  /// No description provided for @channelAnalysis.
  ///
  /// In en, this message translates to:
  /// **'📱 Channel analysis (Nequi, NuBank, Cash)'**
  String get channelAnalysis;

  /// No description provided for @aiIntelligentAnalysis.
  ///
  /// In en, this message translates to:
  /// **'🤖 Intelligent analysis of your finances'**
  String get aiIntelligentAnalysis;

  /// No description provided for @reportGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully!'**
  String get reportGeneratedSuccessfully;

  /// No description provided for @yourDataIsReady.
  ///
  /// In en, this message translates to:
  /// **'Your data is ready for AI analysis'**
  String get yourDataIsReady;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// No description provided for @activeSavings.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get activeSavings;

  /// No description provided for @savedInGoals.
  ///
  /// In en, this message translates to:
  /// **'Saved in Goals'**
  String get savedInGoals;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// No description provided for @savingsPercentage.
  ///
  /// In en, this message translates to:
  /// **'Savings %'**
  String get savingsPercentage;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Expense Categories'**
  String get topCategories;

  /// No description provided for @noExpensesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded'**
  String get noExpensesRecorded;

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @noChannelsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No channels recorded'**
  String get noChannelsRecorded;

  /// No description provided for @analyzeWithAI.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get analyzeWithAI;

  /// No description provided for @viewReportsHistory.
  ///
  /// In en, this message translates to:
  /// **'View Reports History'**
  String get viewReportsHistory;

  /// No description provided for @advancedOptions.
  ///
  /// In en, this message translates to:
  /// **'Advanced options'**
  String get advancedOptions;

  /// No description provided for @copyTechnicalData.
  ///
  /// In en, this message translates to:
  /// **'Copy technical data (JSON)'**
  String get copyTechnicalData;

  /// No description provided for @exportToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportToExcel;

  /// No description provided for @technicalDataCopied.
  ///
  /// In en, this message translates to:
  /// **'Technical data copied to clipboard'**
  String get technicalDataCopied;

  /// No description provided for @reportGeneratedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully'**
  String get reportGeneratedSuccess;

  /// No description provided for @errorGeneratingReport.
  ///
  /// In en, this message translates to:
  /// **'Error generating report'**
  String get errorGeneratingReport;

  /// No description provided for @analyzingWithAI.
  ///
  /// In en, this message translates to:
  /// **'Analyzing with AI...'**
  String get analyzingWithAI;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @errorAnalyzingAI.
  ///
  /// In en, this message translates to:
  /// **'Error analyzing with AI'**
  String get errorAnalyzingAI;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @financialAIAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Financial AI Analysis'**
  String get financialAIAnalysis;

  /// No description provided for @executiveSummary.
  ///
  /// In en, this message translates to:
  /// **'📊 Executive Summary'**
  String get executiveSummary;

  /// No description provided for @yourStrengths.
  ///
  /// In en, this message translates to:
  /// **'💪 Your Strengths'**
  String get yourStrengths;

  /// No description provided for @detailedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'💡 Detailed Analysis'**
  String get detailedAnalysis;

  /// No description provided for @projections.
  ///
  /// In en, this message translates to:
  /// **'🔮 Projections'**
  String get projections;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'🎯 Recommendations'**
  String get recommendations;

  /// No description provided for @improvementAreas.
  ///
  /// In en, this message translates to:
  /// **'📈 Improvement Areas'**
  String get improvementAreas;

  /// No description provided for @financialHealth.
  ///
  /// In en, this message translates to:
  /// **'Financial Health'**
  String get financialHealth;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get excellent;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very Good'**
  String get veryGood;

  /// No description provided for @canImprove.
  ///
  /// In en, this message translates to:
  /// **'Can Improve'**
  String get canImprove;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @confidence.
  ///
  /// In en, this message translates to:
  /// **'confidence'**
  String get confidence;

  /// No description provided for @impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

import SwiftUI
import SwiftData

struct MatrixPlannerView: View {
    @Environment(\.modelContext) private var context
    @Query private var plannedTransactions: [PlannedTransaction]
    @Query private var categories: [Category]
    
    @State private var matrixData: MatrixViewData?
    @State private var selectedDateRange: DateRange = .nextMonth
    @State private var isLoading = true
    
    enum DateRange: String, CaseIterable {
        case nextMonth = "Месяц"
        case next3Months = "3 месяца"
        case next6Months = "6 месяцев"
        case nextYear = "Год"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Период", selection: $selectedDateRange) {
                    ForEach(DateRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if isLoading {
                    ProgressView("Загрузка данных...")
                } else if let matrixData = matrixData {
                    MatrixGridView(data: matrixData)
                } else {
                    ContentUnavailableView(
                        "Нет данных",
                        systemImage: "table",
                        description: Text("Нет запланированных операций для отображения")
                    )
                }
            }
            .navigationTitle("Матричный планировщик")
            .onAppear {
                loadMatrixData()
            }
            .onChange(of: selectedDateRange) {
                loadMatrixData()
            }
        }
    }
    
    private func loadMatrixData() {
        isLoading = true
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Определяем диапазон дат
        let endDate: Date = {
            switch selectedDateRange {
            case .nextMonth: return calendar.date(byAdding: .month, value: 1, to: today)!
            case .next3Months: return calendar.date(byAdding: .month, value: 3, to: today)!
            case .next6Months: return calendar.date(byAdding: .month, value: 6, to: today)!
            case .nextYear: return calendar.date(byAdding: .year, value: 1, to: today)!
            }
        }()
        
        // Фильтруем только будущие операции
        let futureTransactions = plannedTransactions.filter { transaction in
            calendar.startOfDay(for: transaction.date) >= today &&
            transaction.date <= endDate
        }
        
        guard !futureTransactions.isEmpty else {
            matrixData = nil
            isLoading = false
            return
        }
        
        // Получаем уникальные даты и сортируем
        let uniqueDates = Array(Set(futureTransactions.map { calendar.startOfDay(for: $0.date) }))
            .sorted()
        
        // Группируем по категориям
        let incomeCategories = categories.filter { $0.type == .income }
        let expenseCategories = categories.filter { $0.type == .expense }
        
        // Создаем матрицы значений
        var incomeValues: [String: [Double]] = [:]
        var expenseValues: [String: [Double]] = [:]
        var totalIncome = Array(repeating: 0.0, count: uniqueDates.count)
        var totalExpense = Array(repeating: 0.0, count: uniqueDates.count)
        
        // Заполняем матрицы
        for (dateIndex, date) in uniqueDates.enumerated() {
            // Операции на эту дату
            let dailyTransactions = futureTransactions.filter {
                calendar.isDate($0.date, inSameDayAs: date)
            }
            
            // Доходы
            for category in incomeCategories {
                let categoryTransactions = dailyTransactions.filter {
                    $0.category?.id == category.id && !$0.isExpense
                }
                let total = categoryTransactions.reduce(0) { $0 + $1.amount }
                
                if incomeValues[category.name] == nil {
                    incomeValues[category.name] = Array(repeating: 0.0, count: uniqueDates.count)
                }
                incomeValues[category.name]?[dateIndex] = total
                totalIncome[dateIndex] += total
            }
            
            // Расходы
            for category in expenseCategories {
                let categoryTransactions = dailyTransactions.filter {
                    $0.category?.id == category.id && $0.isExpense
                }
                let total = categoryTransactions.reduce(0) { $0 + $1.amount }
                
                if expenseValues[category.name] == nil {
                    expenseValues[category.name] = Array(repeating: 0.0, count: uniqueDates.count)
                }
                expenseValues[category.name]?[dateIndex] = total
                totalExpense[dateIndex] += total
            }
        }
        
        // Расчет остатка
        let balance = zip(totalIncome, totalExpense).map { $0 - $1 }
        
        matrixData = MatrixViewData(
            incomeCategories: incomeCategories,
            expenseCategories: expenseCategories,
            dates: uniqueDates,
            incomeValues: incomeValues,
            expenseValues: expenseValues,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            balance: balance
        )
        
        isLoading = false
    }
}

import SwiftUI
import SwiftData
import Charts

struct DashboardView: View {
    @Query private var transactions: [Transaction]
    @Query private var accounts: [Account]
    @Query private var planned: [PlannedTransaction]
    
    @State private var selectedCategory: String? = nil
    @State private var showCategoryTransactions = false
    
    private var totalBalance: Double {
        accounts.reduce(0) { $0 + $1.balance }
    }
    
    private var monthlyTransactions: [Transaction] {
        let calendar = Calendar.current
        guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else { return [] }
        return transactions.filter { $0.date >= monthAgo }
    }
    
    private var monthlyIncome: Double {
        monthlyTransactions.filter { !$0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var monthlyExpense: Double {
        monthlyTransactions.filter { $0.isExpense }.reduce(0) { $0 + $1.amount }
    }
    
    private var categorySummary: [(name: String, total: Double)] {
        let expenseTransactions = monthlyTransactions.filter { $0.isExpense }
        let grouped = Dictionary(grouping: expenseTransactions) { $0.category?.name ?? "Без категории" }
        return grouped.map { (name: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
    }
    
    private var upcomingTransactions: [PlannedTransaction] {
        planned.filter { $0.date > Date() }
            .sorted { $0.date < $1.date }
            .prefix(5)
            .map { $0 }
    }
    
    private var projectedBalance: Double {
        let futurePlanned = planned.filter { $0.date > Date() }
        return totalBalance + futurePlanned.reduce(0) {
            $0 + ($1.isExpense ? -$1.amount : $1.amount)
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    balanceCard
                    incomeExpenseCards
                    
                    if !upcomingTransactions.isEmpty {
                        upcomingTransactionsCard
                    }
                    
                    if !categorySummary.isEmpty {
                        categoryChart
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .navigationTitle("📊 Дашборд")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCategoryTransactions) {
                if let category = selectedCategory {
                    CategoryTransactionsView(
                        categoryName: category,
                        transactions: monthlyTransactions
                    )
                }
            }
        }
    }
    
    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Итоговый баланс")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(formatCurrency(totalBalance))
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(totalBalance >= 0 ? .green : .red)
            
            if projectedBalance != totalBalance {
                Text("Прогноз: \(formatCurrency(projectedBalance))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var categoryChart: some View {
        Card {
            VStack(alignment: .leading) {
                Text("Траты по категориям")
                    .font(.headline)
                    .padding(.bottom, 8)
                
                Chart(categorySummary, id: \.name) { item in
                    SectorMark(
                        angle: .value("Сумма", item.total),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Категория", item.name))
                    .annotation(position: .overlay, alignment: .center) {
                        Text(item.name.prefix(3))
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 250)
                .chartOverlay { proxy in
                    GeometryReader { _ in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if let firstCategory = categorySummary.first?.name {
                                    selectedCategory = firstCategory
                                    showCategoryTransactions = true
                                }
                            }
                    }
                }
            }
        }
    }
    
    private var incomeExpenseCards: some View {
        HStack(spacing: 12) {
            Card {
                VStack(spacing: 4) {
                    Text("Доходы")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(formatCurrency(monthlyIncome))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
            }
            Card {
                VStack(spacing: 4) {
                    Text("Расходы")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(formatCurrency(monthlyExpense))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var upcomingTransactionsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                Text("Предстоящие")
                    .font(.system(size: 16, weight: .semibold))
                
                ForEach(upcomingTransactions.prefix(3)) { plan in
                    HStack {
                        Text(plan.note.isEmpty ? (plan.isExpense ? "Расход" : "Доход") : plan.note)
                            .font(.system(size: 14))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(formatCurrency(plan.isExpense ? -plan.amount : plan.amount))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(plan.isExpense ? .red : .green)
                    }
                }
            }
        }
    }
}

import SwiftUI

struct CategoryTransactionsView: View {
    let categoryName: String
    let transactions: [Transaction]

    private var filtered: [Transaction] {
        transactions.filter { $0.category?.name == categoryName }
    }

    private var total: Double {
        filtered.map { $0.amount }.reduce(0, +)
    }

    private var percent: Double {
        let all = transactions.filter { $0.isExpense }.map { $0.amount }.reduce(0, +)
        return all > 0 ? (total / all * 100) : 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Card {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Всего по категории")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(total))
                            .font(.title2).bold()
                            .foregroundColor(.red)
                        // ✅ Исправление: правильный specifier без кавычек
                        Text(String(format: "%.1f%% от расходов", percent))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                List(filtered) { tx in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(tx.note.isEmpty ? (tx.isExpense ? "Расход" : "Доход") : tx.note)
                                .font(.headline)
                            Spacer()
                            Text(formatCurrency(tx.isExpense ? -tx.amount : tx.amount))
                                .foregroundColor(tx.isExpense ? .red : .green)
                        }
                        Text(tx.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 12)
            .navigationTitle(categoryName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    
    private var categoryText: String {
        if let categoryName = transaction.category?.name {
            if let subcategoryName = transaction.subcategory?.name {
                return "\(categoryName) → \(subcategoryName)"
            } else {
                return categoryName
            }
        }
        return "-"
    }
    
    private var accountText: String {
        if let accountName = transaction.account?.name {
            if let subaccountName = transaction.subaccount?.name {
                return "\(accountName) → \(subaccountName)"
            } else {
                return accountName
            }
        }
        return "-"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(transaction.note.isEmpty ? (transaction.isExpense ? "Расход" : "Доход") : transaction.note)
                    .font(.headline)
                Spacer()
                Text(formatCurrency(transaction.isExpense ? -transaction.amount : transaction.amount))
                    .foregroundColor(transaction.isExpense ? .red : .green)
            }
            HStack {
                Text(categoryText)
                Text("•")
                Text(accountText)
                Text("•")
                Text(transaction.date, style: .date)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
    }
}

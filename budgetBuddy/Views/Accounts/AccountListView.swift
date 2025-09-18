import SwiftUI
import SwiftData

struct AccountListView: View {
    @Environment(\.modelContext) private var context
    @Query private var accounts: [Account]
    
    @State private var newName = ""
    @State private var balance = 0.0
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(accounts) { acc in
                    VStack(alignment: .leading) {
                        Text(acc.name).font(.headline)
                        Text("Баланс: \(formatCurrency(acc.balance))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete { idx in
                    idx.map { accounts[$0] }.forEach(context.delete)
                    try? context.save()
                }
                
                Section("Добавить счёт") {
                    TextField("Название", text: $newName)
                    TextField("Начальный баланс", value: $balance, format: .number)
                        .keyboardType(.decimalPad)
                        .onChange(of: balance) { if balance < 0 { balance = abs(balance) } }
                    Button("Добавить") {
                        guard !newName.isEmpty else { return }
                        let acc = Account(name: newName, balance: balance)
                        context.insert(acc)
                        try? context.save()
                        newName = ""
                        balance = 0.0
                    }
                }
            }
            .navigationTitle("Счета")
        }
    }
}

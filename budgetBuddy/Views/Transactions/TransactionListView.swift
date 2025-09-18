import SwiftUI
import SwiftData

struct TransactionListView: View {
    @Environment(\.modelContext) private var context
    @Query private var transactions: [Transaction]
       
    @State private var search = ""
    @State private var selectedPeriod: PeriodFilter = .all
    @State private var selectedCategory: Category?
    @State private var selectedAccount: Account?
    @State private var showAddTransaction = false
    
    var filtered: [Transaction] {
        transactions.filter { tx in
            if !search.isEmpty && !tx.note.localizedCaseInsensitiveContains(search) { return false }
            
            let now = Date()
            let cal = Calendar.current
            switch selectedPeriod {
            case .week:
                guard let weekAgo = cal.date(byAdding: .day, value: -7, to: now) else { return true }
                if tx.date < weekAgo { return false }
            case .month:
                guard let monthAgo = cal.date(byAdding: .month, value: -1, to: now) else { return true }
                if tx.date < monthAgo { return false }
            case .all: break
            }
            
            if let cat = selectedCategory, tx.category?.id != cat.id { return false }
            if let acc = selectedAccount, tx.account?.id != acc.id { return false }
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 8) {
                TextField("Поиск...", text: $search)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PeriodFilter.allCases, id: \.self) { period in
                            Chip(label: period.rawValue, isSelected: selectedPeriod == period) {
                                selectedPeriod = period
                            }
                        }
                        if let categories = try? context.fetch(FetchDescriptor<Category>()) {
                            ForEach(categories) { cat in
                                Chip(label: cat.name, isSelected: selectedCategory?.id == cat.id) {
                                    selectedCategory = selectedCategory?.id == cat.id ? nil : cat
                                }
                            }
                        }
                        if let accounts = try? context.fetch(FetchDescriptor<Account>()) {
                            ForEach(accounts) { acc in
                                Chip(label: acc.name, isSelected: selectedAccount?.id == acc.id) {
                                    selectedAccount = selectedAccount?.id == acc.id ? nil : acc
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                List {
                    ForEach(filtered) { tx in
                        TransactionRow(transaction: tx)
                    }
                    .onDelete { indexSet in
                        indexSet.map { filtered[$0] }.forEach(context.delete)
                        try? context.save()
                    }
                }
                HStack {
                    Spacer()
                    Button {
                        showAddTransaction = true
                    } label: {
                        Image(systemName: "plus")
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color.black)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                    .padding(.bottom, 100)
                    .padding(.trailing, 30)
                }
            }
            .navigationTitle("Операции")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if let url = exportCSV(transactions: filtered) {
                        ShareLink(item: url, preview: SharePreview("Экспорт CSV")) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddTransaction) {
                TransactionForm()
            }
        }
    }
}

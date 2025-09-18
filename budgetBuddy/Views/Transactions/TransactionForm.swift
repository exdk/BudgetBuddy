import SwiftUI
import SwiftData

struct TransactionForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var date = Date()
    @State private var amount: Double = 0
    @State private var isExpense = true
    @State private var note = ""
    @State private var category: Category?
    @State private var subcategory: Subcategory?
    @State private var account: Account?
    @State private var subaccount: Subaccount?
    @State private var showCategoryPicker = false
    
    @Query private var categories: [Category]
    @Query private var accounts: [Account]
    
    private var filteredCategories: [Category] {
        categories.filter { $0.type == (isExpense ? .expense : .income) }
    }
    
    private var filteredSubcategories: [Subcategory] {
        guard let category = category, let subcategories = category.subcategories else { return [] }
        return subcategories
    }
    
    private var filteredSubaccounts: [Subaccount] {
        guard let account = account, let subaccounts = account.subaccounts else { return [] }
        return subaccounts
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Основная информация") {
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                    
                    HStack {
                        Text("Сумма")
                        Spacer()
                        TextField("0", value: $amount, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .onChange(of: amount) { if amount < 0 { amount = abs(amount) } }
                    }
                    
                    Toggle("Это расход", isOn: $isExpense)
                        .onChange(of: isExpense) {
                            category = nil
                            subcategory = nil
                        }
                    
                    TextField("Заметка", text: $note)
                        .textContentType(.none)
                }
                
                Section("Категория") {
                    HStack {
                        if let category = category {
                            Circle()
                                .fill(colorFromString(category.color))
                                .frame(width: 16, height: 16)
                            VStack(alignment: .leading) {
                                Text(category.name).font(.subheadline)
                                if let subcategory = subcategory {
                                    Text(subcategory.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } else {
                            Text("Без категории").foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Выбрать") { showCategoryPicker = true }
                            .foregroundColor(.blue)
                    }
                }
                
                Section("Детали") {
                    Picker("Категория", selection: $category) {
                        Text("Без категории").tag(nil as Category?)
                        ForEach(filteredCategories) { cat in
                            Text(cat.name).tag(cat as Category?)
                        }
                    }
                    .onChange(of: category) { subcategory = nil }
                    
                    if !filteredSubcategories.isEmpty {
                        Picker("Подкатегория", selection: $subcategory) {
                            Text("Без подкатегории").tag(nil as Subcategory?)
                            ForEach(filteredSubcategories) { subcat in
                                Text(subcat.name).tag(subcat as Subcategory?)
                            }
                        }
                    }
                    
                    Picker("Счет", selection: $account) {
                        Text("Без счета").tag(nil as Account?)
                        ForEach(accounts) { acc in
                            Text(acc.name).tag(acc as Account?)
                        }
                    }
                    .onChange(of: account) { subaccount = nil }
                    
                    if !filteredSubaccounts.isEmpty {
                        Picker("Подсчет", selection: $subaccount) {
                            Text("Основной счет").tag(nil as Subaccount?)
                            ForEach(filteredSubaccounts) { subacc in
                                Text(subacc.name).tag(subacc as Subaccount?)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                NavigationStack {
                    CategoryTreePicker(
                        selectedCategory: $category,
                        selectedSubcategory: $subcategory,
                        categories: categories,
                        isExpense: isExpense
                    )
                    .navigationTitle("Выбор категории")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Готово") { showCategoryPicker = false }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }
            .navigationTitle("Новая транзакция")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { saveTransaction() }
                        .disabled(amount <= 0)
                }
            }
        }
    }
    
    private func saveTransaction() {
        let cleanNote = note.trimmingCharacters(in: .whitespaces)
        let transaction = Transaction(
            date: date,
            amount: amount,
            isExpense: isExpense,
            note: cleanNote.isEmpty ? (isExpense ? "Расход" : "Доход") : cleanNote,
            category: category,
            subcategory: subcategory,
            account: account,
            subaccount: subaccount
        )
        
        context.insert(transaction)
        if let selectedSubaccount = subaccount {
            selectedSubaccount.balance += isExpense ? -amount : amount
            selectedSubaccount.parentAccount?.balance += isExpense ? -amount : amount
        } else if let selectedAccount = account {
            selectedAccount.balance += isExpense ? -amount : amount
        }
        
        do {
            try context.save()
            dismiss()
        } catch {
            print("Ошибка сохранения транзакции: \(error)")
        }
    }
}

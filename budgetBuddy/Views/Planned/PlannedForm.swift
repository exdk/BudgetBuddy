import SwiftUI
import SwiftData

struct PlannedForm: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    var defaultDate: Date = Date()
    var onSave: (() -> Void)? = nil

    @State private var date: Date
    @State private var amount = 0.0
    @State private var isExpense = true
    @State private var note = ""
    @State private var category: Category?
    @State private var subcategory: Subcategory?
    @State private var account: Account?
    @State private var subaccount: Subaccount?
    @State private var repeatRule: RepeatRule = .none
    @State private var showCategoryPicker = false

    @Query private var categories: [Category]
    @Query private var accounts: [Account]

    init(defaultDate: Date = Date(), onSave: (() -> Void)? = nil) {
        self.defaultDate = defaultDate
        self.onSave = onSave
        _date = State(initialValue: defaultDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Дата", selection: $date, displayedComponents: .date)
                TextField("Сумма", value: $amount, format: .number)
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { if amount < 0 { amount = abs(amount) } }

                Toggle("Это расход", isOn: $isExpense)
                    .onChange(of: isExpense) {
                        category = nil
                        subcategory = nil
                    }

                TextField("Заметка", text: $note)

                Picker("Повтор", selection: $repeatRule) {
                    ForEach(RepeatRule.allCases, id: \.self) { Text($0.rawValue) }
                }

                Section("Категория") {
                    HStack {
                        if let category = category {
                            Circle()
                                .fill(colorFromString(category.color))
                                .frame(width: 16, height: 16)
                            VStack(alignment: .leading) {
                                Text(category.name).font(.subheadline)
                                if let sub = subcategory { Text(sub.name).font(.caption).foregroundColor(.secondary) }
                            }
                        } else {
                            Text("Без категории").foregroundColor(.secondary)
                        }
                        Spacer()
                        Button("Выбрать") { showCategoryPicker = true }
                            .foregroundColor(.blue)
                    }
                }

                // выбор счета
                Picker("Счет", selection: $account) {
                    Text("Без счета").tag(nil as Account?)
                    ForEach(accounts) { acc in Text(acc.name).tag(acc as Account?) }
                }
                .onChange(of: account) { subaccount = nil }

                if let account = account, let subaccounts = account.subaccounts, !subaccounts.isEmpty {
                    Picker("Подсчет", selection: $subaccount) {
                        Text("Основной").tag(nil as Subaccount?)
                        ForEach(subaccounts) { sub in Text(sub.name).tag(sub as Subaccount?) }
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
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Готово") { showCategoryPicker = false }
                        }
                    }
                }
            }
            .navigationTitle("Новая операция")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        savePlanned()
                    }
                    .disabled(amount <= 0)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func savePlanned() {
        let cleanNote = note.trimmingCharacters(in: .whitespaces)
        let item = PlannedTransaction(
            date: date,
            amount: amount,
            isExpense: isExpense,
            note: cleanNote.isEmpty ? (isExpense ? "Расход" : "Доход") : cleanNote,
            category: category,
            subcategory: subcategory,
            account: account,
            subaccount: subaccount,
            repeatRule: repeatRule
        )
        context.insert(item)
        try? context.save()
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        onSave?()
        dismiss()
    }
}


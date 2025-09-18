import SwiftUI
import SwiftData

struct PlannedListView: View {
    @Environment(\.modelContext) private var context
    @Query private var planned: [PlannedTransaction]
    
    enum Mode: String, CaseIterable {
        case list = "Список"
        case calendar = "Календарь"
        case matrix = "Матрица"
    }
    @State private var mode: Mode = .calendar
    @State private var showAdd = false
    @State private var monthAnchor: Date = .now
    @State private var selectedDay: Date = .now
    @State private var showDaySheet = false

    /// Группировка по дате
    private var plannedByDay: [Date: [PlannedTransaction]] {
        let cal = Calendar.current
        return Dictionary(grouping: planned) { cal.startOfDay(for: $0.date) }
    }
    
    /// Отсортированный список
    private var sortedPlanned: [PlannedTransaction] {
        planned.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Планы")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Picker("Режим", selection: $mode) {
                            ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 300)
                    }
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            showAdd = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAdd) {
                    PlannedForm(defaultDate: selectedDay)
                }
        }
    }
    
    // MARK: - Подвью для выбора режима
    private var modePicker: some View {
        Picker("Режим", selection: $mode) {
            ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
        }
        .pickerStyle(.segmented)
        .frame(width: 200)
    }
    
    // MARK: - Контент
    @ViewBuilder
    private var content: some View {
        switch mode {
        case .list:
            List {
                ForEach(planned.sorted { $0.date < $1.date }) { plan in
                    PlannedRow(plan: plan)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let item = planned[index]
                        context.delete(item)
                    }
                    try? context.save()
                }
            }
            
        case .calendar:
            ScrollView {
                CalendarMonthView(
                    monthAnchor: $monthAnchor,
                    selectedDay: $selectedDay,
                    plannedByDay: plannedByDay,
                    onSelectDay: { day in
                        selectedDay = day
                        showDaySheet = true
                    }
                )
                .padding(.horizontal, 16)
            }
            
        case .matrix:
            MatrixPlannerView()
        }
        
    }
}

struct PlannedRow: View {
    let plan: PlannedTransaction
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(plan.note.isEmpty ? (plan.isExpense ? "Расход" : "Доход") : plan.note)
                    .font(.headline)
                Text(plan.date, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(formatCurrency(plan.isExpense ? -plan.amount : plan.amount))
                .foregroundColor(plan.isExpense ? .red : .green)
        }
    }
}

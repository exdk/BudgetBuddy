import SwiftUI
import SwiftData

struct PlannedListView: View {
    @Environment(\.modelContext) private var context
    @Query private var planned: [PlannedTransaction]
    
    enum Mode: String, CaseIterable { case list = "Список", calendar = "Календарь" }
    @State private var mode: Mode = .calendar
    @State private var showAdd = false
    @State private var monthAnchor: Date = .now
    @State private var selectedDay: Date = .now
    @State private var showDaySheet = false
    @State private var showMatrixPlanner = false
    
    private var plannedByDay: [Date: [PlannedTransaction]] {
        let cal = Calendar.current
        return Dictionary(grouping: planned) { cal.startOfDay(for: $0.date) }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch mode {
                case .list:
                    List {
                        ForEach(planned.sorted { $0.date < $1.date }) { plan in
                            PlannedRow(plan: plan)
                        }
                        .onDelete { idx in
                            idx.map { planned.sorted { $0.date < $1.date }[$0] }.forEach(context.delete)
                            try? context.save()
                        }
                    }.listStyle(.plain)
                    
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
                }
            }
            .navigationTitle("Запланированные")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Picker("Режим", selection: $mode) {
                        ForEach(Mode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Матричный") { showMatrixPlanner = true }
                    Button("Добавить") { showAdd = true }
                }
            }
            .sheet(isPresented: $showAdd) {
                PlannedForm(defaultDate: selectedDay)
            }
            .sheet(isPresented: $showDaySheet) {
                DayPlannedSheet(
                    date: selectedDay,
                    items: plannedByDay[Calendar.current.startOfDay(for: selectedDay)] ?? [],
                    onAdd: {
                        showDaySheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showAdd = true
                        }
                    }
                )
            }
            .sheet(isPresented: $showMatrixPlanner) {
                MatrixPlannerView()
            }
            .onAppear { processPlannedTransactions(context: context) }
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

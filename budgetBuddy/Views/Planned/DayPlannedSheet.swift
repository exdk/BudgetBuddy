import SwiftUI
import SwiftData

struct DayPlannedSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let date: Date
    @State private var planned: [PlannedTransaction] = []

    @State private var showAddForm = false

    var body: some View {
        NavigationStack {
            List {
                if planned.isEmpty {
                    Text("Нет запланированных операций")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(planned) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.category?.name ?? "Без категории")
                                    .font(.headline)
                                Text(item.note.isEmpty ? "" : item.note)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(formatCurrency(item.amount))
                                .foregroundColor(item.isExpense ? .red : .green)
                        }
                    }
                    .onDelete { idxSet in
                        for idx in idxSet {
                            context.delete(planned[idx])
                        }
                        try? context.save()
                        loadPlanned()
                    }
                }
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear { loadPlanned() }
            .sheet(isPresented: $showAddForm) {
                PlannedForm(date: date) {
                    loadPlanned()
                }
            }
        }
    }

    private func loadPlanned() {
        let descriptor = FetchDescriptor<PlannedTransaction>(
            predicate: #Predicate { $0.date.isSameDay(as: date) },
            sortBy: [SortDescriptor(\.amount, order: .reverse)]
        )
        if let results = try? context.fetch(descriptor) {
            planned = results
        }
    }
}

// MARK: - Вспомогательный метод для сравнения дат по дню
fileprivate extension Date {
    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }
}

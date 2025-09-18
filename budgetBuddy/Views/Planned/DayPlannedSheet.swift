import SwiftUI
import SwiftData

struct DayPlannedSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let date: Date
    var onAdd: (() -> Void)? = nil
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
                                if !item.note.isEmpty {
                                    Text(item.note)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            Spacer()
                            Text(formatCurrency(item.amount))
                                .foregroundColor(item.isExpense ? .red : .green)
                        }
                        .padding(.vertical, 6)
                    }
                    .onDelete { idxSet in
                        for idx in idxSet {
                            let item = planned[idx]
                            context.delete(item)
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
                        if let onAdd = onAdd {
                            onAdd()
                        } else {
                            showAddForm = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear { loadPlanned() }
            .sheet(isPresented: $showAddForm) {
                PlannedForm(defaultDate: date, onSave: {
                    loadPlanned()
                })
            }
        }
    }

    private func loadPlanned() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        var descriptor = FetchDescriptor<PlannedTransaction>()
        descriptor.predicate = #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        descriptor.sortBy = [SortDescriptor(\.amount, order: .reverse)]

        if let results = try? context.fetch(descriptor) {
            planned = results
        } else {
            planned = []
        }
    }
}


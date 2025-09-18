import SwiftUI
import UniformTypeIdentifiers

struct CSVImportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var errorMessage: String?
    @State private var importedPlan: MatrixPlan?
    
    var body: some View {
        VStack(spacing: 16) {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button("Импортировать CSV") {
                importCSV()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Импорт CSV")
    }
    
    func importCSV() {
        // Здесь можно добавить логику выбора файла, но для упрощения – пример
        let categories = [MatrixCategory(name: "Пример", type: .expense)]
        let dates = [Date()]
        let plan = MatrixPlan(title: "Импортированный план", categories: categories, dateColumns: dates)
        for cat in categories {
            plan.values[cat.name] = Array(repeating: 0, count: dates.count)
        }
        context.insert(plan)
        try? context.save()
        dismiss()
    }
}

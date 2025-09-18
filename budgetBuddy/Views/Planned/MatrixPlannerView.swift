import SwiftUI
import SwiftData

struct MatrixPlannerView: View {
    @Environment(\.modelContext) private var context
    @Query private var matrixPlans: [MatrixPlan]
    
    @State private var selectedPlan: MatrixPlan?
    @State private var showPlanForm = false
    @State private var showImportSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(matrixPlans) { plan in
                    Button { selectedPlan = plan } label: {
                        VStack(alignment: .leading) {
                            Text(plan.title).font(.headline)
                            Text("\(plan.categories.count) категорий, \(plan.dateColumns.count) дат")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indexes in
                    indexes.forEach { index in
                        if index < matrixPlans.count {
                            context.delete(matrixPlans[index])
                        }
                    }
                    try? context.save()
                }
            }
            .navigationTitle("Матричный планировщик")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { showImportSheet = true } label: {
                        Image(systemName: "square.and.arrow.down")
                    }
                    Button { showPlanForm = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showPlanForm) { MatrixPlanForm() }
            .sheet(isPresented: $showImportSheet) { CSVImportView() }
            .sheet(item: $selectedPlan) { plan in
                MatrixPlanDetailView(plan: plan)
            }
        }
    }
}

import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.modelContext) private var context
    @Query private var categories: [Category]
    
    @State private var newName = ""
    @State private var newColor = "purple"
    @State private var selectedType: CategoryType = .expense
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { cat in
                    CategoryItemTile(category: cat)
                }
                .onDelete { idx in
                    idx.map { categories[$0] }.forEach(context.delete)
                    try? context.save()
                }
                
                Section("Добавить категорию") {
                    TextField("Название", text: $newName)
                    Picker("Тип", selection: $selectedType) {
                        ForEach(CategoryType.allCases, id: \.self) { Text($0.rawValue) }
                    }
                    Button("Добавить") {
                        guard !newName.isEmpty else { return }
                        let category = Category(name: newName, color: newColor, type: selectedType)
                        context.insert(category)
                        try? context.save()
                        newName = ""
                    }
                }
            }
            .navigationTitle("Категории")
        }
    }
}

import SwiftUI

struct CategoryTreePicker: View {
    @Binding var selectedCategory: Category?
    @Binding var selectedSubcategory: Subcategory?
    
    var categories: [Category]
    var isExpense: Bool
    
    private var filtered: [Category] {
        categories.filter { $0.type == (isExpense ? .expense : .income) }
    }
    
    var body: some View {
        List {
            ForEach(filtered) { cat in
                Section(cat.name) {
                    Button {
                        selectedCategory = cat
                        selectedSubcategory = nil
                    } label: {
                        HStack {
                            Text(cat.name)
                            if selectedCategory?.id == cat.id && selectedSubcategory == nil {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    if let subs = cat.subcategories {
                        ForEach(subs) { sub in
                            Button {
                                selectedCategory = cat
                                selectedSubcategory = sub
                            } label: {
                                HStack {
                                    Text("↳ \(sub.name)")
                                    if selectedSubcategory?.id == sub.id {
                                        Spacer()
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

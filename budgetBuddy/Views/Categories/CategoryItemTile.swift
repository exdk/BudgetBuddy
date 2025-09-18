import SwiftUI

struct CategoryItemTile: View {
    let category: Category
    
    var body: some View {
        HStack {
            Circle()
                .fill(colorFromString(category.color))
                .frame(width: 20, height: 20)
            VStack(alignment: .leading) {
                Text(category.name)
                    .font(.headline)
                Text(category.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("Бюджет: \(formatCurrency(category.budget))")
                .font(.caption)
        }
    }
}

import SwiftUI

func colorFromString(_ colorName: String) -> Color {
    switch colorName {
    case "red": return .red
    case "orange": return .orange
    case "yellow": return .yellow
    case "green": return .green
    case "blue": return .blue
    case "purple": return .purple
    case "pink": return .pink
    case "gray": return .gray
    case "black": return .black
    case "white": return .white
    case "brown": return .brown
    case "cyan": return .cyan
    case "indigo": return .indigo
    case "mint": return .mint
    case "teal": return .teal
    default: return .purple
    }
}

func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current
    return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
}

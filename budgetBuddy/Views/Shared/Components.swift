import SwiftUI

// MARK: - Chip
struct Chip: View {
    let label: String
    let isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.15))
                .foregroundColor(isSelected ? .accentColor : .primary)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Card
struct Card<Content: View>: View {
    var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2, y: 1)
    }
}

// MARK: - DayCell for Calendar
struct DayCell: View {
    let date: Date
    let inCurrentMonth: Bool
    let items: [PlannedTransaction]
    
    var body: some View {
        VStack {
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption)
                .foregroundColor(inCurrentMonth ? .primary : .gray)
            if !items.isEmpty {
                Circle()
                    .fill(items.first?.isExpense == true ? Color.red : Color.green)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(width: 30, height: 30)
        .background(Calendar.current.isDateInToday(date) ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(6)
    }
}

// MARK: - Helper: Days for Calendar Grid
func daysForMonthGrid(anchor: Date) -> [Date] {
    var calendar = Calendar.current
    calendar.firstWeekday = 2 // Понедельник
    
    let range = calendar.range(of: .day, in: .month, for: anchor)!
    let comps = calendar.dateComponents([.year, .month], from: anchor)
    let firstDay = calendar.date(from: comps)!
    let weekday = calendar.component(.weekday, from: firstDay)
    
    let leadingDays = (weekday - calendar.firstWeekday + 7) % 7
    let totalDays = range.count + leadingDays
    let rows = Int(ceil(Double(totalDays) / 7.0))
    
    return (0..<rows*7).map { offset in
        calendar.date(byAdding: .day, value: offset - leadingDays, to: firstDay)!
    }
}

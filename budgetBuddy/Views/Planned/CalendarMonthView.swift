import SwiftUI

struct CalendarMonthView: View {
    @Binding var monthAnchor: Date
    @Binding var selectedDay: Date
    let plannedByDay: [Date: [PlannedTransaction]]
    var onSelectDay: (Date) -> Void
    
    private var gridDays: [Date] { daysForMonthGrid(anchor: monthAnchor) }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Button {
                    monthAnchor = Calendar.current.date(byAdding: .month, value: -1, to: monthAnchor)!
                } label: { Image(systemName: "chevron.left") }
                Spacer()
                Text(monthAnchor, formatter: russianMonthFormatter)
                    .font(.headline)
                Spacer()
                Button {
                    monthAnchor = Calendar.current.date(byAdding: .month, value: 1, to: monthAnchor)!
                } label: { Image(systemName: "chevron.right") }
            }
            .padding(.horizontal, 8)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(gridDays.indices, id: \.self) { index in
                    let day = gridDays[index]
                    let isCurrentMonth = Calendar.current.isDate(day, equalTo: monthAnchor, toGranularity: .month)
                    let key = Calendar.current.startOfDay(for: day)
                    let items = plannedByDay[key] ?? []
                    DayCell(date: day, inCurrentMonth: isCurrentMonth, items: items)
                        .onTapGesture { onSelectDay(day) }
                }
            }
        }
    }
}

private let russianMonthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ru_RU")
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}()

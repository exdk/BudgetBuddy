import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.rawValue)
                            .font(.system(size: 20, weight: .semibold))
                        // Можно добавить подпись, если нужно:
                        // Text(tabTitle(tab)).font(.caption2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundColor(selectedTab == tab ? Color.accentColor : Color.secondary)
                }
            }
        }
        .padding(.horizontal, 6)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }

    // опционально: функция для отображения текста
    private func tabTitle(_ tab: Tab) -> String {
        switch tab {
        case .transactions: return "Транзакции"
        case .planned: return "Планы"
        case .dashboard: return "Дашборд"
        case .settings: return "Настройки"
        }
    }
}

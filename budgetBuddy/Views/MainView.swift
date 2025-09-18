import SwiftUI

enum Tab: String, CaseIterable {
    case transactions = "list.bullet"
    case planned = "calendar"
    case dashboard = "chart.bar.fill"
    case accounts = "rublesign.bank.building"
    case settings = "gearshape.fill"
}

struct MainView: View {
    @State private var selectedTab: Tab = .transactions
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .transactions:
                    TransactionListView()
                case .planned:
                    PlannedListView()
                case .dashboard:
                    DashboardView()
                case .accounts:
                    AccountListView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaPadding(.bottom, 80)
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

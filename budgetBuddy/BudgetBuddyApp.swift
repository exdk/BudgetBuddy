import SwiftUI
import SwiftData

@main
struct BudgetBuddyApp: App {
    @AppStorage("theme") private var theme: Theme = .system
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: [
                    Transaction.self,
                    Category.self,
                    Account.self,
                    PlannedTransaction.self,
                    Subcategory.self,
                    Subaccount.self,
                ])
                .preferredColorScheme(theme.colorScheme)
                .onAppear(perform: migrateData)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                print("Приложение стало активным")
            }
        }
    }
}

extension Theme {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum Theme: String, CaseIterable {
    case system
    case light
    case dark
}

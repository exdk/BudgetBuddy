import SwiftData
import Foundation

class PersistentContainer {
    static let shared = PersistentContainer()
    let container: ModelContainer
    
    private init() {
        do {
            container = try ModelContainer(
                for: Transaction.self,
                Category.self,
                Account.self,
                PlannedTransaction.self,
                Subcategory.self,
                Subaccount.self,
                configurations: ModelConfiguration()
            )
        } catch {
            fatalError("Не удалось инициализировать ModelContainer: \(error)")
        }
    }
}

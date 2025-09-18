import SwiftData
import Foundation

@Model
class Account {
    var id: UUID
    var name: String
    var balance: Double
    var subaccounts: [Subaccount]?
    
    init(name: String, balance: Double = 0) {
        self.id = UUID()
        self.name = name
        self.balance = balance
    }
}

@Model
class Subaccount {
    var id: UUID
    var name: String
    var balance: Double
    var parentAccount: Account?
    
    init(name: String, balance: Double = 0, parentAccount: Account? = nil) {
        self.id = UUID()
        self.name = name
        self.balance = balance
        self.parentAccount = parentAccount
    }
}

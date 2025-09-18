import SwiftData
import Foundation

@Model
class Transaction {
    var id: UUID
    var date: Date
    var amount: Double
    var isExpense: Bool
    var note: String
    var category: Category?
    var subcategory: Subcategory?
    var account: Account?
    var subaccount: Subaccount?
    
    init(date: Date, amount: Double, isExpense: Bool, note: String,
         category: Category?, subcategory: Subcategory? = nil,
         account: Account?, subaccount: Subaccount? = nil) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.isExpense = isExpense
        self.note = note
        self.category = category
        self.subcategory = subcategory
        self.account = account
        self.subaccount = subaccount
    }
}

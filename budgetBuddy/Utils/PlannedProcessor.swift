import SwiftData
import Foundation

func processPlannedTransactions(context: ModelContext) {
    let today = Calendar.current.startOfDay(for: Date())
    let plans = try? context.fetch(FetchDescriptor<PlannedTransaction>())
    
    plans?.forEach { plan in
        while plan.date <= today && plan.repeatRule != .none {
            let tx = Transaction(
                date: plan.date,
                amount: plan.amount,
                isExpense: plan.isExpense,
                note: plan.note,
                category: plan.category,
                subcategory: plan.subcategory,
                account: plan.account,
                subaccount: plan.subaccount
            )
            context.insert(tx)
            
            switch plan.repeatRule {
            case .weekly:
                plan.date = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: plan.date)!
            case .monthly:
                plan.date = Calendar.current.date(byAdding: .month, value: 1, to: plan.date)!
            case .none:
                break
            }
        }
        
        if plan.date <= today && plan.repeatRule == .none {
            context.delete(plan)
        }
    }
    try? context.save()
}

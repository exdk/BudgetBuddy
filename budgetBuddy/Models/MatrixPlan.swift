import SwiftData
import Foundation

// УДАЛИТЕ ВСЁ и ЗАМЕНИТЕ на:
struct MatrixViewData {
    let incomeCategories: [Category]
    let expenseCategories: [Category]
    let dates: [Date]
    let incomeValues: [String: [Double]] // categoryName: values for each date
    let expenseValues: [String: [Double]] // categoryName: values for each date
    let totalIncome: [Double] // total for each date
    let totalExpense: [Double] // total for each date
    let balance: [Double] // balance for each date
}

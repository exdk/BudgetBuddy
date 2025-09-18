import Foundation

func exportCSV(transactions: [Transaction]) -> URL? {
    let header = "Дата;Категория;Подкатегория;Сумма;Заметка;Счёт;Подсчет"
    let rows = transactions.map { tx in
        let dateStr = DateFormatter.localizedString(from: tx.date, dateStyle: .short, timeStyle: .none)
        let cat = tx.category?.name ?? "-"
        let subcat = tx.subcategory?.name ?? "-"
        let amount = (tx.isExpense ? -tx.amount : tx.amount).formatted()
        let note = tx.note.replacingOccurrences(of: ";", with: ",")
        let acc = tx.account?.name ?? "-"
        let subacc = tx.subaccount?.name ?? "-"
        return "\(dateStr);\(cat);\(subcat);\(amount);\(note);\(acc);\(subacc)"
    }
    let csvString = ([header] + rows).joined(separator: "\n")
    
    do {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("transactions.csv")
        try csvString.write(to: tmpURL, atomically: true, encoding: .utf8)
        return tmpURL
    } catch {
        print("Ошибка экспорта: \(error)")
        return nil
    }
}

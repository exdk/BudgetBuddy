import SwiftData
import Foundation

func migrateData() {
    let container = PersistentContainer.shared.container
    let context = ModelContext(container)
    
    do {
        let categories = try context.fetch(FetchDescriptor<Category>())
        for category in categories {
            // Устанавливаем тип категории, если он отсутствует
            if Mirror(reflecting: category.type).displayStyle == .optional {
                category.type = .expense
            }
        }
        try context.save()
    } catch {
        print("Ошибка миграции категорий: \(error)")
    }
    
    // Создание стандартных категорий при первом запуске
    do {
        let categoriesCount = try context.fetchCount(FetchDescriptor<Category>())
        if categoriesCount == 0 {
            createDefaultCategories(context: context)
        }
        try context.save()
    } catch {
        print("Ошибка создания категорий: \(error)")
    }
}

func createDefaultCategories(context: ModelContext) {
    let expenseCategories = [
        ("Продукты", "green"),
        ("Транспорт", "blue"),
        ("Жилье", "purple"),
        ("Развлечения", "pink"),
        ("Здоровье", "red"),
        ("Одежда", "orange"),
        ("Образование", "indigo")
    ]
    
    let incomeCategories = [
        ("Зарплата", "green"),
        ("Аванс", "blue"),
        ("Премия", "purple"),
        ("Инвестиции", "teal"),
        ("Подарки", "pink")
    ]
    
    for (name, color) in expenseCategories {
        context.insert(Category(name: name, color: color, type: .expense))
    }
    for (name, color) in incomeCategories {
        context.insert(Category(name: name, color: color, type: .income))
    }
}

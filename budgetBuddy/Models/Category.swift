import SwiftData
import Foundation

@Model
class Category {
    var id: UUID
    var name: String
    var color: String
    var budget: Double
    var subcategories: [Subcategory]?
    var type: CategoryType
    
    init(name: String, color: String = "purple", budget: Double = 0, type: CategoryType = .expense) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.budget = budget
        self.type = type
    }
}

@Model
class Subcategory {
    var id: UUID
    var name: String
    var parentCategory: Category?
    var parentSubcategory: Subcategory?
    var childSubcategories: [Subcategory]?
    
    init(name: String, parentCategory: Category? = nil, parentSubcategory: Subcategory? = nil) {
        self.id = UUID()
        self.name = name
        self.parentCategory = parentCategory
        self.parentSubcategory = parentSubcategory
    }
}

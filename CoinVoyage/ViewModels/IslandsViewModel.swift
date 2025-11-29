import Foundation
import SwiftUI
import Combine

class IslandsViewModel: ObservableObject {
    @Published var islands: [FinancialIsland] = [] {
        didSet {
            saveIslands()
        }
    }
    @Published var showAddIslandSheet = false
    
    init() {
        loadIslands()
    }
    
    func deleteIsland(_ island: FinancialIsland) {
        islands.removeAll { $0.id == island.id }
    }
    
    private func saveIslands() {
        if let encoded = try? JSONEncoder().encode(islands) {
            UserDefaults.standard.set(encoded, forKey: "financialIslands")
        }
    }
    
    private func loadIslands() {
        if let data = UserDefaults.standard.data(forKey: "financialIslands"),
           let decoded = try? JSONDecoder().decode([FinancialIsland].self, from: data) {
            islands = decoded
        }
    }
}

struct FinancialIsland: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: ExpenseCategory
    var totalSpent: Double
    var monthlyBudget: Double
    let colorData: ColorData
    
    var color: Color {
        Color(red: colorData.red, green: colorData.green, blue: colorData.blue)
    }
    
    var progress: Double {
        min(totalSpent / monthlyBudget, 1.0)
    }
    
    var remaining: Double {
        max(monthlyBudget - totalSpent, 0)
    }
    
    init(id: UUID, name: String, category: ExpenseCategory, totalSpent: Double, monthlyBudget: Double, color: Color) {
        self.id = id
        self.name = name
        self.category = category
        self.totalSpent = totalSpent
        self.monthlyBudget = monthlyBudget
        
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.colorData = ColorData(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

struct ColorData: Codable {
    let red: Double
    let green: Double
    let blue: Double
}

enum ExpenseCategory: String, Codable {
    case food
    case entertainment
    case transport
    case shopping
    case other
}


import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var goals: [FinancialGoal] = [] {
        didSet {
            saveGoals()
        }
    }
    @Published var totalSaved: Double = 0.0
    @Published var monthlyBudget: Double = 5000.0 {
        didSet {
            UserDefaults.standard.set(monthlyBudget, forKey: "monthlyBudget")
        }
    }
    @Published var showAddGoalSheet = false
    
    init() {
        loadGoals()
        if let budget = UserDefaults.standard.object(forKey: "monthlyBudget") as? Double {
            monthlyBudget = budget
        }
        updateTotalSaved()
    }
    
    func updateTotalSaved() {
        totalSaved = goals.reduce(0) { $0 + $1.currentAmount }
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: "financialGoals")
        }
    }
    
    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: "financialGoals"),
           let decoded = try? JSONDecoder().decode([FinancialGoal].self, from: data) {
            goals = decoded
        }
    }
}

struct FinancialGoal: Identifiable, Codable {
    let id: UUID
    let title: String
    let targetAmount: Double
    var currentAmount: Double
    let imageName: String
    
    var progress: Double {
        min(currentAmount / targetAmount, 1.0)
    }
}


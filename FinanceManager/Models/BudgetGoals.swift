import Foundation

struct BudgetGoals: Codable {
    var monthlyIncomeGoal: Double?
    var categoryLimits: [Category: Double] = [:]
    
    // Return a dictionary with all categories and their limits (including zeros for categories without limits)
    func allCategoryLimits() -> [Category: Double] {
        var result: [Category: Double] = [:]
        
        for category in Category.allCases {
            result[category] = categoryLimits[category] ?? 0
        }
        
        return result
    }
    
    // Check if a specific category has exceeded its limit
    func isCategoryLimitExceeded(category: Category, currentSpending: Double) -> Bool {
        guard let limit = categoryLimits[category], limit > 0 else {
            return false // No limit set
        }
        
        return currentSpending > limit
    }
    
    // Get progress percentage toward income goal (0.0 to 1.0)
    func incomeGoalProgress(currentIncome: Double) -> Double {
        guard let goal = monthlyIncomeGoal, goal > 0 else {
            return 0 // No goal set
        }
        
        return min(currentIncome / goal, 1.0)
    }
    
    // Check if a category has a limit set
    func hasLimit(for category: Category) -> Bool {
        return categoryLimits[category] != nil && categoryLimits[category] != 0
    }
    
    // Set a limit for a category
    mutating func setLimit(for category: Category, amount: Double) {
        categoryLimits[category] = amount
    }
    
    // Remove a limit for a category
    mutating func removeLimit(for category: Category) {
        categoryLimits.removeValue(forKey: category)
    }
} 
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    goalsSection
                    summarySection
                }
                .padding()
            }
            .navigationTitle("Coin Voyage")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showAddGoalSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddGoalSheet) {
                AddGoalSheet(viewModel: viewModel)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Your Financial Journey")
                .font(.title2)
                .fontWeight(.bold)
            Text("Total Saved: $\(Int(viewModel.totalSaved))")
                .font(.title)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Visual Goals")
                .font(.headline)
            
            ForEach($viewModel.goals) { $goal in
                GoalCard(goal: $goal, viewModel: viewModel)
            }
        }
    }
    
    private var summarySection: some View {
        VStack(spacing: 16) {
            Text("Monthly Budget")
                .font(.headline)
            
            HStack {
                Text("Budget: $\(Int(viewModel.monthlyBudget))")
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

struct GoalCard: View {
    @Binding var goal: FinancialGoal
    @ObservedObject var viewModel: HomeViewModel
    @State private var showEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.imageName)
                    .font(.title)
                    .foregroundColor(.blue)
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("$\(Int(goal.currentAmount)) / $\(Int(goal.targetAmount))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Button(action: {
                    showEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                        .cornerRadius(10)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * goal.progress, height: 20)
                        .cornerRadius(10)
                }
            }
            .frame(height: 20)
            
            Text("\(Int(goal.progress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showEditSheet) {
            EditGoalSheet(goal: $goal, viewModel: viewModel)
        }
    }
}

struct EditGoalSheet: View {
    @Binding var goal: FinancialGoal
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    @State private var currentAmountText: String
    
    init(goal: Binding<FinancialGoal>, viewModel: HomeViewModel) {
        self._goal = goal
        self.viewModel = viewModel
        _currentAmountText = State(initialValue: String(Int(goal.wrappedValue.currentAmount)))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Information")) {
                    Text(goal.title)
                        .foregroundColor(.gray)
                    Text("Target: $\(Int(goal.targetAmount))")
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Current Amount")) {
                    TextField("Amount", text: $currentAmountText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amount = Double(currentAmountText) {
                            goal.currentAmount = amount
                            viewModel.goals = viewModel.goals
                            viewModel.updateTotalSaved()
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddGoalSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var targetAmountText = ""
    @State private var currentAmountText = ""
    @State private var selectedIcon = "star.fill"
    
    let icons = ["car.fill", "airplane", "house.fill", "gift.fill", "dumbbell.fill", "gamecontroller.fill"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Title", text: $title)
                    TextField("Target Amount", text: $targetAmountText)
                        .keyboardType(.decimalPad)
                    TextField("Current Amount", text: $currentAmountText)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Icon")) {
                    Picker("Icon", selection: $selectedIcon) {
                        ForEach(icons, id: \.self) { icon in
                            HStack {
                                Image(systemName: icon)
                                Text(icon)
                            }
                            .tag(icon)
                        }
                    }
                }
            }
            .navigationTitle("Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let target = Double(targetAmountText),
                           let current = Double(currentAmountText),
                           !title.isEmpty {
                            let newGoal = FinancialGoal(
                                id: UUID(),
                                title: title,
                                targetAmount: target,
                                currentAmount: current,
                                imageName: selectedIcon
                            )
                            viewModel.goals.append(newGoal)
                            viewModel.updateTotalSaved()
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}


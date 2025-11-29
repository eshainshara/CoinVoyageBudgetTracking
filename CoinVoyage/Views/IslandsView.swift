import SwiftUI

struct IslandsView: View {
    @StateObject private var viewModel = IslandsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    islandsGrid
                }
                .padding()
            }
            .navigationTitle("Financial Islands")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showAddIslandSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddIslandSheet) {
                AddIslandSheet(viewModel: viewModel)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Explore Your Spending")
                .font(.title2)
                .fontWeight(.bold)
            Text("Each category is an island on your financial map")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var islandsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach($viewModel.islands) { $island in
                IslandCard(island: $island, viewModel: viewModel)
            }
        }
    }
}

struct IslandCard: View {
    @Binding var island: FinancialIsland
    @ObservedObject var viewModel: IslandsViewModel
    @State private var showEditSheet = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button(action: {
                    showEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
            
            ZStack {
                Circle()
                    .fill(island.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: iconForCategory(island.category))
                    .font(.system(size: 40))
                    .foregroundColor(island.color)
            }
            
            Text(island.name)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            VStack(spacing: 4) {
                Text("$\(Int(island.totalSpent))")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(island.color)
                
                Text("of $\(Int(island.monthlyBudget))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(island.color)
                        .frame(width: geometry.size.width * island.progress, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
            
            Text("$\(Int(island.remaining)) remaining")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showEditSheet) {
            EditIslandSheet(island: $island, viewModel: viewModel)
        }
    }
    
    private func iconForCategory(_ category: ExpenseCategory) -> String {
        switch category {
        case .food:
            return "fork.knife"
        case .entertainment:
            return "tv"
        case .transport:
            return "car.fill"
        case .shopping:
            return "bag.fill"
        case .other:
            return "ellipsis.circle"
        }
    }
}

struct EditIslandSheet: View {
    @Binding var island: FinancialIsland
    @ObservedObject var viewModel: IslandsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var totalSpentText: String
    @State private var monthlyBudgetText: String
    
    init(island: Binding<FinancialIsland>, viewModel: IslandsViewModel) {
        self._island = island
        self.viewModel = viewModel
        _totalSpentText = State(initialValue: String(Int(island.wrappedValue.totalSpent)))
        _monthlyBudgetText = State(initialValue: String(Int(island.wrappedValue.monthlyBudget)))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Island Information")) {
                    Text(island.name)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Spending")) {
                    TextField("Total Spent", text: $totalSpentText)
                        .keyboardType(.decimalPad)
                    TextField("Monthly Budget", text: $monthlyBudgetText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Edit Island")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let spent = Double(totalSpentText),
                           let budget = Double(monthlyBudgetText) {
                            island.totalSpent = spent
                            island.monthlyBudget = budget
                            viewModel.islands = viewModel.islands
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddIslandSheet: View {
    @ObservedObject var viewModel: IslandsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var totalSpentText = ""
    @State private var monthlyBudgetText = ""
    @State private var selectedCategory: ExpenseCategory = .food
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Island Details")) {
                    TextField("Name", text: $name)
                    Picker("Category", selection: $selectedCategory) {
                        Text("Food").tag(ExpenseCategory.food)
                        Text("Entertainment").tag(ExpenseCategory.entertainment)
                        Text("Transport").tag(ExpenseCategory.transport)
                        Text("Shopping").tag(ExpenseCategory.shopping)
                        Text("Other").tag(ExpenseCategory.other)
                    }
                    TextField("Total Spent", text: $totalSpentText)
                        .keyboardType(.decimalPad)
                    TextField("Monthly Budget", text: $monthlyBudgetText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Island")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let spent = Double(totalSpentText),
                           let budget = Double(monthlyBudgetText),
                           !name.isEmpty {
                            let color = colorForCategory(selectedCategory)
                            let newIsland = FinancialIsland(
                                id: UUID(),
                                name: name,
                                category: selectedCategory,
                                totalSpent: spent,
                                monthlyBudget: budget,
                                color: color
                            )
                            viewModel.islands.append(newIsland)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func colorForCategory(_ category: ExpenseCategory) -> Color {
        switch category {
        case .food:
            return .orange
        case .entertainment:
            return .purple
        case .transport:
            return .blue
        case .shopping:
            return .pink
        case .other:
            return .gray
        }
    }
}


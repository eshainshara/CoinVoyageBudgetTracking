import SwiftUI

struct MissionsView: View {
    @StateObject private var viewModel = MissionsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    if !viewModel.activeMissions.isEmpty {
                        activeMissionsSection
                    }
                    
                    if !viewModel.completedMissions.isEmpty {
                        completedMissionsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Missions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.showAddMissionSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showAddMissionSheet) {
                AddMissionSheet(viewModel: viewModel)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Complete Challenges")
                .font(.title2)
                .fontWeight(.bold)
            Text("Earn rewards by completing financial missions")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private var activeMissionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Missions")
                .font(.headline)
            
            ForEach(viewModel.activeMissions) { mission in
                MissionCard(mission: mission, viewModel: viewModel)
            }
        }
    }
    
    private var completedMissionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completed Missions")
                .font(.headline)
            
            ForEach(viewModel.completedMissions) { mission in
                MissionCard(mission: mission, viewModel: viewModel)
            }
        }
    }
}

struct MissionCard: View {
    let mission: Mission
    @ObservedObject var viewModel: MissionsViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.toggleMission(mission)
            }) {
                Image(systemName: mission.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(mission.isCompleted ? .green : .gray)
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mission.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(mission.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack {
                Text("$\(Int(mission.reward))")
                    .font(.headline)
                    .foregroundColor(.green)
                Text("reward")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                viewModel.deleteMission(mission)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct AddMissionSheet: View {
    @ObservedObject var viewModel: MissionsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var rewardText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Mission Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Reward", text: $rewardText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Mission")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let reward = Double(rewardText),
                           !title.isEmpty,
                           !description.isEmpty {
                            let newMission = Mission(
                                id: UUID(),
                                title: title,
                                description: description,
                                reward: reward,
                                progress: 0.0,
                                isCompleted: false
                            )
                            viewModel.activeMissions.append(newMission)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
}


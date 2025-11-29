import Foundation
import Combine

class MissionsViewModel: ObservableObject {
    @Published var activeMissions: [Mission] = [] {
        didSet {
            saveMissions()
        }
    }
    @Published var completedMissions: [Mission] = [] {
        didSet {
            saveMissions()
        }
    }
    @Published var showAddMissionSheet = false
    
    init() {
        loadMissions()
    }
    
    func toggleMission(_ mission: Mission) {
        if let index = activeMissions.firstIndex(where: { $0.id == mission.id }) {
            var completed = activeMissions[index]
            completed.isCompleted = true
            completed.progress = 1.0
            activeMissions.remove(at: index)
            completedMissions.append(completed)
        } else if let index = completedMissions.firstIndex(where: { $0.id == mission.id }) {
            var active = completedMissions[index]
            active.isCompleted = false
            completedMissions.remove(at: index)
            activeMissions.append(active)
        }
    }
    
    func deleteMission(_ mission: Mission) {
        activeMissions.removeAll { $0.id == mission.id }
        completedMissions.removeAll { $0.id == mission.id }
    }
    
    private func saveMissions() {
        let allMissions = MissionsData(active: activeMissions, completed: completedMissions)
        if let encoded = try? JSONEncoder().encode(allMissions) {
            UserDefaults.standard.set(encoded, forKey: "missions")
        }
    }
    
    private func loadMissions() {
        if let data = UserDefaults.standard.data(forKey: "missions"),
           let decoded = try? JSONDecoder().decode(MissionsData.self, from: data) {
            activeMissions = decoded.active
            completedMissions = decoded.completed
        }
    }
}

struct MissionsData: Codable {
    let active: [Mission]
    let completed: [Mission]
}

struct Mission: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let reward: Double
    var progress: Double
    var isCompleted: Bool
}


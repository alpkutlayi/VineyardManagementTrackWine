import SwiftUI
import Foundation

struct UserActivity: Identifiable, Codable {
    let id: UUID
    let action: String
    let timestamp: Date
    let icon: String
    
    init(action: String, icon: String) {
        self.id = UUID()
        self.action = action
        self.timestamp = Date()
        self.icon = icon
    }
    
    init(id: UUID, action: String, timestamp: Date, icon: String) {
        self.id = id
        self.action = action
        self.timestamp = timestamp
        self.icon = icon
    }
}

class ActivityManager: ObservableObject {
    static let shared = ActivityManager()
    
    @Published var activities: [UserActivity] = []
    private let maxActivities = 50
    private let userDefaults = UserDefaults.standard
    private let activitiesKey = "savedActivities"
    
    private init() {
        loadActivities()
    }
    
    func addActivity(action: String, icon: String) {
        let newActivity = UserActivity(action: action, icon: icon)
        
        DispatchQueue.main.async {
            self.activities.insert(newActivity, at: 0)
            
            if self.activities.count > self.maxActivities {
                self.activities = Array(self.activities.prefix(self.maxActivities))
            }
            
            self.saveActivities()
        }
    }
    
    func getRecentActivities(limit: Int = 20) -> [UserActivity] {
        return Array(activities.prefix(limit))
    }
    
    func clearAllActivities() {
        activities.removeAll()
        saveActivities()
    }
    
    private func saveActivities() {
        if let encoded = try? JSONEncoder().encode(activities) {
            userDefaults.set(encoded, forKey: activitiesKey)
        }
    }
    
    private func loadActivities() {
        if let data = userDefaults.data(forKey: activitiesKey),
           let decoded = try? JSONDecoder().decode([UserActivity].self, from: data) {
            activities = decoded
        }
    }
}
import Foundation

class ContainerDataManager: ObservableObject {
    static let shared = ContainerDataManager()
    
    @Published var containers: [Container] = []
    private let userDefaults = UserDefaults.standard
    private let containersKey = "SavedContainers"
    private let activityManager = ActivityManager.shared
    
    private init() {
        loadContainers()
    }
    
    func loadContainers() {
        // Always load fresh data from JSON file to get the latest American winery names
        loadFromJSON()
    }
    
    private func loadFromJSON() {
        guard let url = Bundle.main.url(forResource: "containers", withExtension: "json") else {
            print("Could not find containers.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let containerData = try JSONDecoder().decode(ContainerData.self, from: data)
            self.containers = containerData.containers
            
            // Clear any old saved data and save the new data
            userDefaults.removeObject(forKey: containersKey)
            saveContainers()
        } catch {
            print("Error loading containers from JSON: \(error)")
        }
    }
    
    func updateContainer(_ updatedContainer: Container) {
        if let index = containers.firstIndex(where: { $0.id == updatedContainer.id }) {
            containers[index] = updatedContainer
            saveContainers()
        }
    }
    
    func addContainer(_ container: Container) {
        containers.append(container)
        saveContainers()
        activityManager.addActivity(action: "Added new container \(container.name)", icon: "plus.circle")
    }
    
    func deleteContainer(withId id: Int) {
        if let container = containers.first(where: { $0.id == id }) {
            containers.removeAll { $0.id == id }
            saveContainers()
            activityManager.addActivity(action: "Removed container \(container.name)", icon: "minus.circle")
        }
    }
    
    private func saveContainers() {
        do {
            let data = try JSONEncoder().encode(containers)
            userDefaults.set(data, forKey: containersKey)
            
            // Notify observers that data has changed
            NotificationCenter.default.post(name: NSNotification.Name("ContainerDataChanged"), object: nil)
        } catch {
            print("Error saving containers: \(error)")
        }
    }
    
    func resetToDefault() {
        userDefaults.removeObject(forKey: containersKey)
        loadFromJSON()
    }
    
    func forceReloadFromJSON() {
        userDefaults.removeObject(forKey: containersKey)
        loadFromJSON()
    }
    
    func getContainer(byId id: Int) -> Container? {
        return containers.first { $0.id == id }
    }
}
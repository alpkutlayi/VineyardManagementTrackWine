import Foundation
import CoreLocation

struct ContainerCoordinates: Codable {
    let latitude: Double
    let longitude: Double
    
    var clLocationCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct Container: Codable, Identifiable {
    let id: Int
    let name: String
    let type: String
    var capacity: Double
    var currentVolume: Double
    let grapeVariety: String?
    let harvestDate: String?
    var status: String
    let location: String
    let temperature: Double
    let ph: Double?
    let coordinates: ContainerCoordinates
    
    var fillPercentage: Double {
        return currentVolume / capacity * 100
    }
}

struct ContainerData: Codable {
    let containers: [Container]
}

class ContainerManager: ObservableObject {
    @Published var containers: [Container] = []
    private var dataManager = ContainerDataManager.shared
    
    init() {
        loadContainers()
        // Listen for changes from the shared data manager
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataChanged),
            name: NSNotification.Name("ContainerDataChanged"),
            object: nil
        )
    }
    
    func loadContainers() {
        dataManager.forceReloadFromJSON()
        self.containers = dataManager.containers
    }
    
    @objc private func dataChanged() {
        DispatchQueue.main.async {
            self.containers = self.dataManager.containers
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
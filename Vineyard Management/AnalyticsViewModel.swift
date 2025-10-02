import SwiftUI
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var totalContainers: Int = 15
    @Published var activeContainers: Int = 13
    @Published var emptyContainers: Int = 2
    @Published var containers: [Container] = []
    @Published var isEditMode: Bool = false

    private let containerManager = ContainerManager()
    private var cancellables = Set<AnyCancellable>()

    init() {
        loadData()
        observeContainerChanges()
    }

    private func observeContainerChanges() {
        containerManager.$containers
            .sink { [weak self] containers in
                self?.containers = containers
                self?.calculateStatistics()
            }
            .store(in: &cancellables)
    }

    func loadData() {
        containers = containerManager.containers
        calculateStatistics()
    }

    private func calculateStatistics() {
        totalContainers = containers.count
        activeContainers = containers.filter { container in
            container.status == "Active" || container.status == "Fermenting" || container.status == "Aging"
        }.count
        emptyContainers = containers.filter { container in
            container.status == "Empty" || container.status == "Maintenance"
        }.count
    }

    func updateContainer(_ container: Container) {
        if let index = containers.firstIndex(where: { $0.id == container.id }) {
            containers[index] = container
            ContainerDataManager.shared.updateContainer(container)
            calculateStatistics()
        }
    }

    func getCapacityPercentage(for container: Container) -> Double {
        guard container.capacity > 0 else { return 0 }
        return (container.currentVolume / container.capacity) * 100
    }

    func getCapacityColor(percentage: Double) -> Color {
        switch percentage {
        case 0..<50:
            return .green
        case 50..<75:
            return .yellow
        case 75..<90:
            return .orange
        default:
            return .red
        }
    }

    func getTopContainersByCapacity(limit: Int = 8) -> [Container] {
        return containers
            .sorted { container1, container2 in
                let percentage1 = getCapacityPercentage(for: container1)
                let percentage2 = getCapacityPercentage(for: container2)
                return percentage1 > percentage2
            }
            .prefix(limit)
            .map { $0 }
    }

    func formatCapacity(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fK", value / 1000)
        } else {
            return String(format: "%.0f", value)
        }
    }

    func formatCapacityWithUnit(_ value: Double) -> String {
        return "\(formatCapacity(value))L"
    }

    func toggleEditMode() {
        isEditMode.toggle()
    }
}
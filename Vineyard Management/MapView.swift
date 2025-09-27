import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var containerManager = ContainerManager()
    @ObservedObject private var activityManager = ActivityManager.shared
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 38.4161, longitude: -122.3681),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedContainer: Container?
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Map(coordinateRegion: $region, annotationItems: containerManager.containers) { container in
                    MapAnnotation(coordinate: container.coordinates.clLocationCoordinate) {
                        ContainerMapPin(container: container, isSelected: selectedContainer?.id == container.id)
                            .onTapGesture {
                                selectedContainer = container
                            }
                    }
                }
                
                if let selectedContainer = selectedContainer {
                    ContainerMapCard(container: selectedContainer)
                        .padding()
                        .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("Vineyard Map")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Center") {
                        withAnimation {
                            region = MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: 38.4161, longitude: -122.3681),
                                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                            )
                        }
                    }
                }
            }
            .onTapGesture {
                selectedContainer = nil
            }
            .onAppear {
                containerManager.loadContainers()
                activityManager.addActivity(action: "Checked vineyard locations", icon: "map")
            }
        }
    }
    
}

struct ContainerMapPin: View {
    let container: Container
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: iconForContainerType(container.type))
                .foregroundColor(.white)
                .font(.system(size: isSelected ? 20 : 16))
                .padding(isSelected ? 12 : 8)
                .background(colorForStatus(container.status))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
                )
                .shadow(radius: isSelected ? 8 : 4)
            
            Text(container.name)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.white)
                .cornerRadius(6)
                .shadow(radius: 2)
        }
        .scaleEffect(isSelected ? 1.2 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private func iconForContainerType(_ type: String) -> String {
        switch type.lowercased() {
        case "fermentation tank":
            return "flask.fill"
        case "storage tank":
            return "archivebox.fill"
        case "oak barrel":
            return "cylinder.fill"
        case "clarification tank":
            return "drop.fill"
        default:
            return "cube.fill"
        }
    }
    
    private func colorForStatus(_ status: String) -> Color {
        switch status.lowercased() {
        case "fermenting":
            return .orange
        case "aging":
            return .purple
        case "clarifying":
            return .blue
        case "empty":
            return .gray
        default:
            return .green
        }
    }
}

struct ContainerMapCard: View {
    let container: Container
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(container.name)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(container.type)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(container.status)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(12)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Volume")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(container.currentVolume)/\(container.capacity)L")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fill Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", container.fillPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Temperature")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(String(format: "%.1f", container.temperature))°C")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            
            if let grapeVariety = container.grapeVariety {
                Text("Grape Variety: \(grapeVariety)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: container.fillPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: fillColor))
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 10)
    }
    
    private var statusColor: Color {
        switch container.status.lowercased() {
        case "fermenting":
            return .orange
        case "aging":
            return .purple
        case "clarifying":
            return .blue
        case "empty":
            return .gray
        default:
            return .green
        }
    }
    
    private var fillColor: Color {
        if container.fillPercentage > 90 {
            return .red
        } else if container.fillPercentage > 70 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview {
    MapView()
}
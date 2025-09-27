import SwiftUI
import MapKit

struct ContainerDetailView: View {
    @State private var container: Container
    @State private var region: MKCoordinateRegion
    @StateObject private var likeManager = LikeManager()
    @StateObject private var dataManager = ContainerDataManager.shared
    @State private var showingEditView = false
    
    init(container: Container) {
        self._container = State(initialValue: container)
        self._region = State(initialValue: MKCoordinateRegion(
            center: container.coordinates.clLocationCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: iconForContainerType(container.type))
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .padding(20)
                            .background(colorForStatus(container.status))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(container.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(container.type)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(container.status)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(colorForStatus(container.status).opacity(0.2))
                                .foregroundColor(colorForStatus(container.status))
                                .cornerRadius(12)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Capacity Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Capacity Information")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Current Volume")
                            Spacer()
                            Text("\(container.currentVolume) L")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Total Capacity")
                            Spacer()
                            Text("\(container.capacity) L")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Fill Percentage")
                            Spacer()
                            Text("\(String(format: "%.1f", container.fillPercentage))%")
                                .fontWeight(.semibold)
                                .foregroundColor(fillColor)
                        }
                        
                        ProgressView(value: container.fillPercentage, total: 100)
                            .progressViewStyle(LinearProgressViewStyle(tint: fillColor))
                            .scaleEffect(x: 1, y: 2, anchor: .center)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Environmental Conditions
                VStack(alignment: .leading, spacing: 15) {
                    Text("Environmental Conditions")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "thermometer")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Text("\(String(format: "%.1f", container.temperature))°C")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("Temperature")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        if let ph = container.ph {
                            VStack {
                                Image(systemName: "drop.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("\(String(format: "%.1f", ph))")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text("pH Level")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Wine Information
                if container.grapeVariety != nil || container.harvestDate != nil {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Wine Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(spacing: 12) {
                            if let grapeVariety = container.grapeVariety {
                                HStack {
                                    Image(systemName: "leaf.fill")
                                        .foregroundColor(.green)
                                    Text("Grape Variety")
                                    Spacer()
                                    Text(grapeVariety)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            if let harvestDate = container.harvestDate {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.purple)
                                    Text("Harvest Date")
                                    Spacer()
                                    Text(harvestDate)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
                
                // Location Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Location")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.purple)
                        Text(container.location)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    Map(coordinateRegion: $region, annotationItems: [container]) { container in
                        MapAnnotation(coordinate: container.coordinates.clLocationCoordinate) {
                            Image(systemName: iconForContainerType(container.type))
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding(12)
                                .background(colorForStatus(container.status))
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .disabled(true)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                
                // Action Buttons
                HStack(spacing: 15) {
                    Button(action: {
                        showingEditView = true
                    }) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: {
                        openInMaps()
                    }) {
                        HStack {
                            Image(systemName: "map")
                            Text("View in Maps")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle(container.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        likeManager.toggleLike(for: container.id)
                    }
                }) {
                    Image(systemName: likeManager.isLiked(container.id) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(likeManager.isLiked(container.id) ? .red : .gray)
                        .scaleEffect(likeManager.isLiked(container.id) ? 1.2 : 1.0)
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            ContainerEditView(container: $container)
        }
        .onAppear {
            // Update container data if it was modified
            if let updatedContainer = dataManager.getContainer(byId: container.id) {
                container = updatedContainer
                region = MKCoordinateRegion(
                    center: container.coordinates.clLocationCoordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            }
        }
    }
    
    private func openInMaps() {
        let coordinate = container.coordinates.clLocationCoordinate
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = container.name
        mapItem.pointOfInterestCategory = .winery
        
        let launchOptions = [
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue,
            MKLaunchOptionsShowsTrafficKey: false
        ] as [String : Any]
        
        mapItem.openInMaps(launchOptions: launchOptions)
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
    NavigationView {
        ContainerDetailView(container: Container(
            id: 1,
            name: "Tank A1",
            type: "Fermentation Tank",
            capacity: 5000,
            currentVolume: 4200,
            grapeVariety: "Chardonnay",
            harvestDate: "2024-09-15",
            status: "Fermenting",
            location: "Building A",
            temperature: 18.5,
            ph: 3.2,
            coordinates: ContainerCoordinates(latitude: 44.2619, longitude: 26.0838)
        ))
    }
}
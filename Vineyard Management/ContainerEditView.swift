import SwiftUI

struct ContainerEditView: View {
    @Binding var container: Container
    @Environment(\.presentationMode) var presentationMode
    @State private var editedContainer: EditableContainer
    @State private var showingSaveAlert = false
    @ObservedObject private var activityManager = ActivityManager.shared
    
    init(container: Binding<Container>) {
        self._container = container
        self._editedContainer = State(initialValue: EditableContainer(from: container.wrappedValue))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Information") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Container Name", text: $editedContainer.name)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Type")
                        Spacer()
                        Picker("Type", selection: $editedContainer.type) {
                            Text("Fermentation Tank").tag("Fermentation Tank")
                            Text("Storage Tank").tag("Storage Tank")
                            Text("Oak Barrel").tag("Oak Barrel")
                            Text("Clarification Tank").tag("Clarification Tank")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        Picker("Status", selection: $editedContainer.status) {
                            Text("Empty").tag("Empty")
                            Text("Fermenting").tag("Fermenting")
                            Text("Aging").tag("Aging")
                            Text("Clarifying").tag("Clarifying")
                            Text("Ready").tag("Ready")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        Text("Location")
                        Spacer()
                        TextField("Building/Location", text: $editedContainer.location)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Capacity") {
                    HStack {
                        Text("Total Capacity (L)")
                        Spacer()
                        TextField("Capacity", value: $editedContainer.capacity, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Current Volume (L)")
                        Spacer()
                        TextField("Volume", value: $editedContainer.currentVolume, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Fill Percentage")
                        Spacer()
                        Text("\(String(format: "%.1f", fillPercentage))%")
                            .foregroundColor(fillColor)
                            .fontWeight(.semibold)
                    }
                    
                    ProgressView(value: fillPercentage, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: fillColor))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                }
                
                Section("Environmental Conditions") {
                    HStack {
                        Text("Temperature (°C)")
                        Spacer()
                        TextField("Temperature", value: $editedContainer.temperature, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("pH Level")
                        Spacer()
                        TextField("pH", value: $editedContainer.ph, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Wine Information") {
                    HStack {
                        Text("Grape Variety")
                        Spacer()
                        TextField("Optional", text: $editedContainer.grapeVariety)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Harvest Date")
                        Spacer()
                        TextField("YYYY-MM-DD", text: $editedContainer.harvestDate)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section("Location Coordinates") {
                    HStack {
                        Text("Latitude")
                        Spacer()
                        TextField("Latitude", value: $editedContainer.latitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Longitude")
                        Spacer()
                        TextField("Longitude", value: $editedContainer.longitude, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Edit Container")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Container Updated", isPresented: $showingSaveAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your changes have been saved successfully.")
        }
    }
    
    private var fillPercentage: Double {
        guard editedContainer.capacity > 0 else { return 0 }
        return editedContainer.currentVolume / editedContainer.capacity * 100
    }
    
    private var fillColor: Color {
        if fillPercentage > 90 {
            return .red
        } else if fillPercentage > 70 {
            return .orange
        } else {
            return .green
        }
    }
    
    private func saveChanges() {
        let originalContainer = container
        
        container = Container(
            id: container.id,
            name: editedContainer.name,
            type: editedContainer.type,
            capacity: editedContainer.capacity,
            currentVolume: editedContainer.currentVolume,
            grapeVariety: editedContainer.grapeVariety.isEmpty ? nil : editedContainer.grapeVariety,
            harvestDate: editedContainer.harvestDate.isEmpty ? nil : editedContainer.harvestDate,
            status: editedContainer.status,
            location: editedContainer.location,
            temperature: editedContainer.temperature,
            ph: editedContainer.ph,
            coordinates: ContainerCoordinates(
                latitude: editedContainer.latitude,
                longitude: editedContainer.longitude
            )
        )
        
        // Save to local storage
        ContainerDataManager.shared.updateContainer(container)
        
        // Track activity based on what was changed
        trackContainerChanges(original: originalContainer, updated: container)
        
        showingSaveAlert = true
    }
    
    private func trackContainerChanges(original: Container, updated: Container) {
        var changes: [String] = []
        
        if original.name != updated.name {
            changes.append("name")
        }
        if original.status != updated.status {
            changes.append("status")
        }
        if original.temperature != updated.temperature {
            changes.append("temperature")
        }
        if original.ph != updated.ph {
            changes.append("pH level")
        }
        if original.currentVolume != updated.currentVolume {
            changes.append("volume")
        }
        if original.capacity != updated.capacity {
            changes.append("capacity")
        }
        if original.location != updated.location {
            changes.append("location")
        }
        
        if !changes.isEmpty {
            let changeText = changes.count == 1 ? changes.first! : "\(changes.dropLast().joined(separator: ", ")) and \(changes.last!)"
            let activity = "Updated \(changeText) for \(updated.name)"
            let icon = getIconForChange(changes: changes)
            activityManager.addActivity(action: activity, icon: icon)
        }
    }
    
    private func getIconForChange(changes: [String]) -> String {
        if changes.contains("temperature") {
            return "thermometer"
        } else if changes.contains("pH level") {
            return "drop"
        } else if changes.contains("volume") || changes.contains("capacity") {
            return "chart.bar"
        } else if changes.contains("status") {
            return "flask"
        } else if changes.contains("location") {
            return "location"
        } else {
            return "pencil"
        }
    }
}

struct EditableContainer {
    var name: String
    var type: String
    var capacity: Double
    var currentVolume: Double
    var grapeVariety: String
    var harvestDate: String
    var status: String
    var location: String
    var temperature: Double
    var ph: Double
    var latitude: Double
    var longitude: Double

    init(from container: Container) {
        self.name = container.name
        self.type = container.type
        self.capacity = container.capacity
        self.currentVolume = container.currentVolume
        self.grapeVariety = container.grapeVariety ?? ""
        self.harvestDate = container.harvestDate ?? ""
        self.status = container.status
        self.location = container.location
        self.temperature = container.temperature
        self.ph = container.ph ?? 0.0
        self.latitude = container.coordinates.latitude
        self.longitude = container.coordinates.longitude
    }
}

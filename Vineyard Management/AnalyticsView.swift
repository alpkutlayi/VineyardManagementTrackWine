import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @ObservedObject private var activityManager = ActivityManager.shared
    @State private var showingExportAlert = false
    @State private var selectedContainer: Container?
    @State private var showingEditSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary Cards
                    HStack(spacing: 15) {
                        SummaryCard(
                            title: "Total Containers",
                            value: "\(viewModel.totalContainers)",
                            color: .blue,
                            isEditable: viewModel.isEditMode
                        )
                        SummaryCard(
                            title: "Active",
                            value: "\(viewModel.activeContainers)",
                            color: .green,
                            isEditable: viewModel.isEditMode
                        )
                        SummaryCard(
                            title: "Empty",
                            value: "\(viewModel.emptyContainers)",
                            color: .gray,
                            isEditable: viewModel.isEditMode
                        )
                    }
                    .padding(.horizontal)

                    // Capacity Overview
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Capacity Overview")
                                .font(.headline)
                            Spacer()
                            if viewModel.isEditMode {
                                Text("Tap to edit")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(viewModel.getTopContainersByCapacity()) { container in
                                CapacityCard(
                                    container: container,
                                    viewModel: viewModel,
                                    isEditable: viewModel.isEditMode
                                )
                                .onTapGesture {
                                    if viewModel.isEditMode {
                                        selectedContainer = container
                                        showingEditSheet = true
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Status Distribution
                    VStack(alignment: .leading) {
                        Text("Status Distribution")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 10) {
                            ForEach(statusCounts.keys.sorted(), id: \.self) { status in
                                HStack {
                                    Circle()
                                        .fill(colorForStatus(status))
                                        .frame(width: 12, height: 12)
                                    Text(status)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(statusCounts[status] ?? 0)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewModel.toggleEditMode() }) {
                        Text(viewModel.isEditMode ? "Done" : "Edit")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: exportAnalytics) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .alert("Analytics Exported", isPresented: $showingExportAlert) {
                Button("OK") { }
            } message: {
                Text("Analytics report has been exported successfully.")
            }
            .sheet(item: $selectedContainer) { container in
                EditContainerSheet(container: container, viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadData()
                activityManager.addActivity(action: "Reviewed container capacity", icon: "chart.bar")
            }
        }
    }

    private var statusCounts: [String: Int] {
        Dictionary(grouping: viewModel.containers, by: { $0.status })
            .mapValues { $0.count }
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
        case "active":
            return .green
        default:
            return .green
        }
    }

    private func exportAnalytics() {
        activityManager.addActivity(action: "Exported analytics report", icon: "square.and.arrow.up")
        showingExportAlert = true
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    let isEditable: Bool

    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditable ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

struct CapacityCard: View {
    let container: Container
    let viewModel: AnalyticsViewModel
    let isEditable: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(container.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)

            Text("\(viewModel.formatCapacity(container.currentVolume))/\(viewModel.formatCapacityWithUnit(container.capacity))")
                .font(.caption)
                .foregroundColor(.secondary)

            let percentage = viewModel.getCapacityPercentage(for: container)
            ProgressView(value: percentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: viewModel.getCapacityColor(percentage: percentage)))

            Text("\(String(format: "%.1f", percentage))% full")
                .font(.caption2)
                .foregroundColor(viewModel.getCapacityColor(percentage: percentage))
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditable ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

struct EditContainerSheet: View {
    @State var container: Container
    let viewModel: AnalyticsViewModel
    @Environment(\.dismiss) var dismiss

    @State private var currentVolume: String = ""
    @State private var capacity: String = ""
    @State private var status: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Container Details")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(container.name)
                            .foregroundColor(.secondary)
                    }

                    Picker("Status", selection: $status) {
                        Text("Active").tag("Active")
                        Text("Fermenting").tag("Fermenting")
                        Text("Aging").tag("Aging")
                        Text("Clarifying").tag("Clarifying")
                        Text("Empty").tag("Empty")
                        Text("Maintenance").tag("Maintenance")
                    }
                }

                Section(header: Text("Volume Information")) {
                    HStack {
                        Text("Current Volume (L)")
                        TextField("Volume", text: $currentVolume)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Capacity (L)")
                        TextField("Capacity", text: $capacity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    if let currentVol = Double(currentVolume),
                       let cap = Double(capacity),
                       cap > 0 {
                        HStack {
                            Text("Fill Percentage")
                            Spacer()
                            Text("\(String(format: "%.1f", (currentVol/cap) * 100))%")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Edit Container")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
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
        .onAppear {
            currentVolume = String(format: "%.0f", container.currentVolume)
            capacity = String(format: "%.0f", container.capacity)
            status = container.status
        }
    }

    private func saveChanges() {
        if let currentVol = Double(currentVolume),
           let cap = Double(capacity) {
            container.currentVolume = currentVol
            container.capacity = cap
            container.status = status
            viewModel.updateContainer(container)
            dismiss()
        }
    }
}

#Preview {
    AnalyticsView()
}
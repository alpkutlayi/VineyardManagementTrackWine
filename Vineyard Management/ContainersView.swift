import SwiftUI

struct ContainersView: View {
    @StateObject private var containerManager = ContainerManager()
    @StateObject private var likeManager = LikeManager()
    
    var body: some View {
        NavigationView {
            List(containerManager.containers) { container in
                NavigationLink(destination: ContainerDetailView(container: container)) {
                    ContainerRowView(container: container, likeManager: likeManager)
                }
            }
            .navigationTitle("Containers")
            .refreshable {
                containerManager.loadContainers()
            }
        }
    }
}

struct ContainerRowView: View {
    let container: Container
    @ObservedObject var likeManager: LikeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(container.name)
                    .font(.headline)
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        likeManager.toggleLike(for: container.id)
                    }
                }) {
                    Image(systemName: likeManager.isLiked(container.id) ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundColor(likeManager.isLiked(container.id) ? .red : .gray)
                        .scaleEffect(likeManager.isLiked(container.id) ? 1.1 : 1.0)
                }
                .buttonStyle(PlainButtonStyle())
                
                Text(container.status)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Text(container.type)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Volume: \(container.currentVolume)/\(container.capacity)L")
                        .font(.caption)
                    Text("Fill: \(String(format: "%.1f", container.fillPercentage))%")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Location: \(container.location)")
                        .font(.caption)
                    Text("Temp: \(String(format: "%.1f", container.temperature))°C")
                        .font(.caption)
                }
            }
            
            if let grapeVariety = container.grapeVariety {
                Text("Grape: \(grapeVariety)")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: container.fillPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: fillColor))
        }
        .padding(.vertical, 4)
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

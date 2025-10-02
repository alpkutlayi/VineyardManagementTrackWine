import SwiftUI
import PhotosUI

struct SettingsView: View {
    @State private var profileImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var userName = "Vineyard Manager"
    @State private var userEmail = "manager@vineyard.com"
    @State private var showingImagePicker = false
    @StateObject private var likeManager = LikeManager()
    @StateObject private var containerManager = ContainerManager()
    @ObservedObject private var activityManager = ActivityManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Section
                    VStack(spacing: 15) {
                        // Profile Image
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.purple, lineWidth: 3))
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "person.crop.circle.fill.badge.plus")
                                                .font(.title)
                                                .foregroundColor(.purple)
                                            Text("Add Photo")
                                                .font(.caption)
                                                .foregroundColor(.purple)
                                        }
                                    )
                            }
                        }
                        
                        // User Info
                        VStack(spacing: 8) {
                            TextField("Name", text: $userName)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Email", text: $userEmail)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 20)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Liked Containers Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("Favorite Containers")
                                .font(.headline)
                            Spacer()
                            Text("\(likeManager.likedCount)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        if likeManager.likedCount > 0 {
                            LazyVStack(spacing: 12) {
                                ForEach(likedContainers) { container in
                                    LikedContainerRowView(container: container, likeManager: likeManager)
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            HStack {
                                Spacer()
                                VStack(spacing: 10) {
                                    Image(systemName: "heart")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No favorite containers yet")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Tap the heart icon on any container to add it to your favorites")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Recent Activity Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack {
                            if activityManager.activities.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    Text("No recent activity")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Your activity will appear here as you use the app")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(activityManager.getRecentActivities()) { activity in
                                        ActivityRowView(activity: activity)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Profile")
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileImage = uiImage
                    }
                }
            }
            .onAppear {
                containerManager.loadContainers()
            }
        }
    }
    
    private var likedContainers: [Container] {
        likeManager.getLikedContainers(from: containerManager.containers)
    }
    
}


struct ActivityRowView: View {
    let activity: UserActivity
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .foregroundColor(.purple)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.action)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(timeAgoString(from: activity.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct LikedContainerRowView: View {
    let container: Container
    @ObservedObject var likeManager: LikeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconForContainerType(container.type))
                .foregroundColor(.white)
                .font(.title3)
                .padding(10)
                .background(colorForStatus(container.status))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(container.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(container.type)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(String(format: "%.1f", container.fillPercentage))% full")
                    .font(.caption)
                    .foregroundColor(fillColor)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(container.status)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(colorForStatus(container.status).opacity(0.2))
                    .foregroundColor(colorForStatus(container.status))
                    .cornerRadius(8)
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        likeManager.toggleLike(for: container.id)
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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

struct VineyardSettings {
    var name: String = "My Vineyard"
    var location: String = "Bucharest, Romania"
    var owner: String = "Vineyard Owner"
    var temperatureUnit: String = "C"
    var notificationsEnabled: Bool = true
    var autoBackup: Bool = true
    var highFillThreshold: Double = 90
    var lowFillThreshold: Double = 10
    var maxTemperature: Double = 20
}

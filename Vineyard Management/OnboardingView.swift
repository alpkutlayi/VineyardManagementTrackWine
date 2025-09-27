import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showMainApp = false
    
    var body: some View {
        if showMainApp {
            ContentView()
        } else {
            VStack {
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)
                    
                    OnboardingPage2()
                        .tag(1)
                    
                    OnboardingPage3(showMainApp: $showMainApp)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .foregroundColor(.purple)
                    }
                    
                    Spacer()
                    
                    if currentPage < 2 {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .foregroundColor(.purple)
                        .fontWeight(.semibold)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.purple)
                
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Vineyard Management")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 15) {
                Text("Your complete solution for")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                Text("tracking and optimizing winemaking processes from grape harvesting to final storage")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingPage2: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.purple)
                
                Text("Powerful Features")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 25) {
                FeatureRow(icon: "archivebox.fill", title: "Container Tracking", description: "Monitor all tanks, barrels, and storage containers in real-time")
                
                FeatureRow(icon: "map.fill", title: "Location Mapping", description: "Apple Maps integration to track vineyard locations and facilities")
                
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Analytics Dashboard", description: "Comprehensive insights and reports for your winemaking process")
                
                FeatureRow(icon: "person.crop.circle", title: "Personal Profile", description: "Track your activities and manage vineyard preferences")
            }
            
            Spacer()
        }
        .padding()
    }
}

struct OnboardingPage3: View {
    @Binding var showMainApp: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 120))
                    .foregroundColor(.purple)
                
                Text("Ready to Start?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            VStack(spacing: 20) {
                Text("To provide the best experience, we need access to:")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    PermissionRow(icon: "location.fill", title: "Location Services", description: "For mapping vineyard facilities")
                    
                    PermissionRow(icon: "photo.fill", title: "Photo Library", description: "To upload your profile picture")
                    
                    PermissionRow(icon: "bell.fill", title: "Notifications", description: "For important vineyard alerts")
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    showMainApp = true
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
        .padding()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 25)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    OnboardingView()
}
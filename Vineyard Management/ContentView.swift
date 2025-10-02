//
//  ContentView.swift
//  Vineyard Management
//
//  Created by Mihail Ozun on 22.09.2025.
//

import SwiftUI

struct SizeClassPreferenceKey: PreferenceKey {
    static var defaultValue: UserInterfaceSizeClass? = nil

    static func reduce(value: inout UserInterfaceSizeClass?, nextValue: () -> UserInterfaceSizeClass?) {
        value = nextValue() ?? value
    }
}

struct ContentView: View {
    @State private var cachedSizeClass: UserInterfaceSizeClass = .compact
    
    var body: some View {
        TabView {
            ContainersView()
                .environment(\.horizontalSizeClass, cachedSizeClass)
                .tabItem {
                    Image(systemName: "archivebox")
                    Text("Containers")
                }
            
            MapView()
                .environment(\.horizontalSizeClass, cachedSizeClass)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            AnalyticsView()
                .environment(\.horizontalSizeClass, cachedSizeClass)
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Analytics")
                }
            
            SettingsView()
                .environment(\.horizontalSizeClass, cachedSizeClass)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
        }
        .accentColor(.purple)
        .onPreferenceChange(SizeClassPreferenceKey.self) { value in
            cachedSizeClass = value ?? .compact
        }
        .transformEnvironment(\.horizontalSizeClass) { sizeClass in
            sizeClass = .compact
        }
    }
}

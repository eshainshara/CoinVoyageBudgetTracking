import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            IslandsView()
                .tabItem {
                    Label("Islands", systemImage: "map.fill")
                }
            
            MissionsView()
                .tabItem {
                    Label("Missions", systemImage: "star.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .onAppear {
            AppDelegate.orientationLock = .portrait
        }
    }
}


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("HomeCoin", systemImage: "house.fill")
                }
            
            IslandsView()
                .tabItem {
                    Label("Islands", systemImage: "map.fill")
                }
            
            MissionsView()
                .tabItem {
                    Label("MissionsCoin", systemImage: "star.fill")
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


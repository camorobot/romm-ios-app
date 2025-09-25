//
//  MainTabView.swift
//  romm
//
//  Created by Ilyas Hallak on 08.08.25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appData: AppData
    private let dependencyFactory: DependencyFactoryProtocol
    
    init(dependencyFactory: DependencyFactoryProtocol = DefaultDependencyFactory.shared) {
        self.dependencyFactory = dependencyFactory
    }
    
    var body: some View {
        TabView {
            Tab("Platforms", systemImage: "gamecontroller") {
                NavigationStack {
                    PlatformsView()
                }
            }
            
            Tab("Collection", systemImage: "books.vertical") {
                NavigationStack {
                    CollectionView()
                }
            }
            
            Tab("Devices", systemImage: "server.rack") {
                NavigationStack {
                    SFTPDevicesView(dependencyFactory: dependencyFactory)
                }
            }
            
            Tab("Settings", systemImage: "gear") {
                NavigationStack {
                    SettingsView()
                }
            }

            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                NavigationStack {
                    SearchView(dependencyFactory: dependencyFactory)
                }
            }
        }
    }
}

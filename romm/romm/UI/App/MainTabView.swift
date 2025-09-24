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
            NavigationStack {
                PlatformsView()
            }
            .tabItem {
                Image(systemName: "gamecontroller")
                Text("Plattforms")
            }
            
            NavigationStack {
                CollectionView()
            }
            .tabItem {
                Image(systemName: "books.vertical")
                Text("Collection")
            }
            
            NavigationStack {
                SearchView(dependencyFactory: dependencyFactory)
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Suche")
            }
            
            NavigationStack {
                SFTPDevicesView(dependencyFactory: dependencyFactory)
            }
            .tabItem {
                Image(systemName: "server.rack")
                Text("Devices")
            }
            
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Image(systemName: "person.circle")
                Text("Profil")
            }
        }
    }
}

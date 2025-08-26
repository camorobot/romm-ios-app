//
//  MainTabView.swift
//  romm
//
//  Created by Ilyas Hallak on 08.08.25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appData: AppData
    
    var body: some View {
        TabView {
            PlatformsView()
                .tabItem {
                    Image(systemName: "gamecontroller")
                    Text("Plattforms")
                }
            
            CollectionView()
                .tabItem {
                    Image(systemName: "books.vertical")
                    Text("Collection")
                }
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Suche")
                }
            
            SFTPDevicesView()
                .tabItem {
                    Image(systemName: "server.rack")
                    Text("Devices")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("Profil")
                }
        }
    }
}

//
//  ProfileView.swift
//  romm
//
//  Created by Ilyas Hallak on 07.08.25.
//

import SwiftUI
import os

struct ProfileView: View {
    private let logger = Logger.ui
    @EnvironmentObject var appData: AppData
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var showingLogoutAlert = false
    @State private var showingResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                // User Section
                if let user = appData.currentUser {
                    Section("User Information") {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.username)
                                    .font(.headline)
                                
                                Text("Active User")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Configuration Section
                Section("Configuration") {
                    if let config = appData.currentConfiguration {
                        HStack {
                            Image(systemName: "server.rack")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Server")
                                Text(config.serverURL)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "person")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Username")
                                Text(config.username)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "calendar")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Setup Date")
                                Text("Recently configured")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "app.badge")
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Setup Version")
                                Text("1.0.0")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    NavigationLink(destination: LoggingConfigurationView()) {
                        HStack {
                            Image(systemName: "doc.text.magnifyingglass")
                            Text("Logging Configuration")
                        }
                    }
                    
                    NavigationLink(destination: ImageCacheSettingsView()) {
                        HStack {
                            Image(systemName: "photo.stack")
                            Text("Image Cache Settings")
                        }
                    }
                    
                    Button(action: {
                        showingResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset Configuration")
                        }
                        .foregroundColor(.orange)
                    }
                }
                
                // Actions Section
                Section("Actions") {
                    Button(action: {
                        showingLogoutAlert = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                        }
                        .foregroundColor(.red)
                    }
                }
                
                // App Information Section
                Section("App Information") {
                    HStack {
                        Image(systemName: "info.circle")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Version")
                            Text("1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                        VStack(alignment: .leading, spacing: 2) {
                            Text("RomM Client")
                            Text("iOS ROM Management")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Profil")
            .alert("Logout", isPresented: $showingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    profileViewModel.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .alert("Reset Configuration", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetConfiguration()
                }
            } message: {
                Text("This will reset all configuration settings and return you to the setup screen.")
            }
        }
    }
    
    private func resetConfiguration() {
        logger.info("Resetting configuration...")
        
        // Use ProfileViewModel's restart setup method
        profileViewModel.restartSetup()
        
        logger.info("Configuration reset complete")
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppData())
}
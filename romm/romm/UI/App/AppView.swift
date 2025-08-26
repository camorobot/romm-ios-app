//
//  AppView.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import SwiftUI
import os

struct AppView: View {
    private let logger = Logger.ui
    @StateObject private var appViewModel = AppViewModel()
    
    var body: some View {
        Group {
            switch appViewModel.appState {
            case .loading:
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .padding(.top, 16)
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    Task {
                        await appViewModel.checkInitialState()
                    }
                }
                
            case .setup:
                SetupView()
                    .environmentObject(appViewModel)
                
            case .authenticated:
                MainTabView()
                    .environmentObject(appViewModel.appData)
                
            case .authenticationFailed:
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    VStack(spacing: 8) {
                        Text("Authentication Failed")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Your session has expired. Please set up your connection again.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    Button("Restart Setup") {
                        logger.info("Restart Setup button tapped")
                        appViewModel.restartSetup()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}

#Preview {
    AppView()
}

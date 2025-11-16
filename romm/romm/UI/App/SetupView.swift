//
//  SetupView.swift
//  romm
//
//  Created by Ilyas Hallak on 07.08.25.
//

import SwiftUI

struct SetupView: View {
    let appViewModel: AppViewModel
    @State private var serverURL = ""
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "gear")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("RomM Setup")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Configure your ROM Management System")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Setup Form
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Server URL")
                            .font(.headline)
                        TextField("",
                                  text: $serverURL,
                                  prompt: Text("Server Endpoint").foregroundColor(.secondary))
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        // Quick input chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                QuickInputChip(text: "192.168.", action: { insertText("192.168.") })
                                QuickInputChip(text: "http://", action: { insertText("http://") })
                                QuickInputChip(text: "https://", action: { insertText("https://") })
                                QuickInputChip(text: ":8080", action: { insertText(":8080") })
                                QuickInputChip(text: ".com", action: { insertText(".com") })
                                QuickInputChip(text: ".de", action: { insertText(".de") })
                                QuickInputChip(text: ".org", action: { insertText(".org") })
                            }
                        }

                        Text(verbatim: "Examples: http://192.168.1.100 or https://romm.example.com")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.headline)
                        TextField("Username", text: $username)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.username)
                            .autocapitalization(.none)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.password)
                    }
                }
                .padding(.horizontal, 24)
                
                // Error Message
                if let errorMessage = appViewModel.appData.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button {
                    Task {
                        await saveConfiguration()
                    }
                } label: {
                    if appViewModel.appData.isLoading {
                        HStack {
                            LoadingView()
                                .frame(width: 20, height: 20)
                            Text("Connecting...")
                        }
                    } else {
                        Text("Save Configuration")
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(serverURL.isEmpty || username.isEmpty || password.isEmpty || appViewModel.appData.isLoading)
                .padding(.horizontal, 24)
                
                // Info Text
                VStack(spacing: 8) {
                    Text("Your credentials will be stored securely")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Password will not be stored locally")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func saveConfiguration() async {
        hideKeyboard()
        await appViewModel.saveConfiguration(serverURL: serverURL, username: username, password: password)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func insertText(_ text: String) {
        serverURL += text
    }
}

// MARK: - QuickInputChip Component
struct QuickInputChip: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray5))
                .foregroundColor(.secondary)
                .clipShape(Capsule())
                .cornerRadius(12)
        }
    }
}

//
//  ToastView.swift
//  romm
//
//  Created by Ilyas Hallak on 28.08.25.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success
        case error
        case info
        
        var color: Color {
            switch self {
            case .success:
                return .green
            case .error:
                return .red
            case .info:
                return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .error:
                return "xmark.circle.fill"
            case .info:
                return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .font(.title2)
            
            Text(message)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThickMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(type.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Toast Modifier

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let type: ToastView.ToastType
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    ToastView(message: message, type: type)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 60) // Add padding to account for tab bar and safe area
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                        .zIndex(1000)
                        .onAppear {
                            // Auto-dismiss after duration
                            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    isPresented = false
                                }
                            }
                        }
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
    }
}

// MARK: - View Extension

extension View {
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        type: ToastView.ToastType = .success,
        duration: TimeInterval = 3.0
    ) -> some View {
        self.modifier(ToastModifier(
            isPresented: isPresented,
            message: message,
            type: type,
            duration: duration
        ))
    }
}

#Preview {
    VStack(spacing: 20) {
        ToastView(message: "ROM successfully added to collection!", type: .success)
        ToastView(message: "Failed to connect to server", type: .error)
        ToastView(message: "Loading collections...", type: .info)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

//
//  LoadingView.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import SwiftUI

struct LoadingView: View {
    let message: String?
    let fillScreen: Bool
    
    init(_ message: String? = nil, fillScreen: Bool = true) {
        self.message = message
        self.fillScreen = fillScreen
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: fillScreen ? .infinity : nil, maxHeight: fillScreen ? .infinity : nil)
        .background(Color.clear)
    }
}

#Preview {
    LoadingView("Loading collections...")
}
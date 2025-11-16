//
//  StatCardView.swift
//  romm
//
//  Created by Ilyas Hallak on 16.11.25.
//

import SwiftUI

struct StatCardView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.blue)

            VStack(spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HStack {
        StatCardView(
            icon: "gamecontroller.fill",
            value: "13",
            label: "Platforms"
        )

        StatCardView(
            icon: "opticaldisc",
            value: "6449",
            label: "Games"
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

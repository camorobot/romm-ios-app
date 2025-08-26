//
//  CharFilterPicker.swift
//  romm
//
//  Created by Claude on 08.08.25.
//

import SwiftUI
import os

struct CharFilterPicker: View {
    let charIndex: [String: Int] // Available chars with counts
    let selectedChar: String? // Currently selected character
    let onCharSelected: (String?) -> Void // Callback when char is tapped
    
    @State private var activeChar: String?
    @State private var isExpanded: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Toggle button - position changes based on expanded state
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                VStack(spacing: 4) {
                    // Show current selected character or A-Z
                    Text(selectedChar ?? "A-Z")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                    
                    Image(systemName: isExpanded ? "chevron.right" : "chevron.left")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(width: 28, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor)
                        .opacity(0.8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 2) {
                        ForEach(availableChars, id: \.self) { char in
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                
                                activeChar = char
                                onCharSelected(char == "ALL" ? nil : char)
                                
                                // Auto-collapse after selection
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isExpanded = false
                                }
                                
                                // Reset active state after animation
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    activeChar = nil
                                }
                            }) {
                                Text(char)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(
                                        selectedChar == char || (selectedChar == nil && char == "ALL") ? .blue : 
                                        activeChar == char ? .blue : .secondary
                                    )
                                    .frame(width: 36, height: 21)
                                    .background(
                                        (selectedChar == char || (selectedChar == nil && char == "ALL")) ? 
                                        Color.blue.opacity(0.2) : 
                                        activeChar == char ? Color.blue.opacity(0.1) : Color.clear
                                    )
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(
                                (selectedChar == char || (selectedChar == nil && char == "ALL")) ? 1.2 : 
                                activeChar == char ? 1.1 : 1.0
                            )
                            .animation(.easeInOut(duration: 0.1), value: activeChar)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .frame(maxHeight: UIScreen.main.bounds.height * 0.75) // Max 75% of screen height
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemBackground))
                        .opacity(0.9)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
    
    private var availableChars: [String] {
        var chars = ["ALL"]
        
        let processedChars = charIndex.keys.compactMap { key -> String? in
            // Convert 0-9 to #
            if key.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
                return "#"
            }
            return key
        }
        
        // Remove duplicates and sort
        let uniqueChars = Array(Set(processedChars)).sorted()
        chars.append(contentsOf: uniqueChars)
        
        return chars
    }
}

#Preview {
    let logger = Logger.ui
    
    return CharFilterPicker(
        charIndex: [
            "#": 156, // Numbers 0-9
            "A": 245,
            "B": 189,
            "C": 378,
            "D": 156,
            "E": 89,
            "F": 234,
            "G": 145,
            "H": 98,
            "S": 345,
            "T": 234,
            "Z": 28
        ],
        selectedChar: "A"
    ) { char in
        logger.info("Selected: \(char ?? "ALL")")
    }
    .padding()
}
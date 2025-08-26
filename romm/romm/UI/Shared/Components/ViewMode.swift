//
//  ViewMode.swift
//  romm
//
//  Created by Ilyas Hallak on 23.08.25.
//

import Foundation

enum ViewMode: String, CaseIterable {
    case smallCard = "Small Cards"
    case bigCard = "Big Cards"
    case table = "Table"
    
    var icon: String {
        switch self {
        case .smallCard: return "square.grid.2x2"
        case .bigCard: return "square.grid.3x2"
        case .table: return "list.bullet"
        }
    }
}
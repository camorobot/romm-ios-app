//
//  GetViewModeUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 22.09.25.
//

import Foundation

protocol GetViewModeUseCaseProtocol {
    func execute() -> ViewMode
}

class GetViewModeUseCase: GetViewModeUseCaseProtocol {
    
    func execute() -> ViewMode {
        if let savedViewMode = UserDefaults.standard.string(forKey: "selectedViewMode"),
           let mode = ViewMode(rawValue: savedViewMode) {
            return mode
        }
        return .smallCard
    }
}
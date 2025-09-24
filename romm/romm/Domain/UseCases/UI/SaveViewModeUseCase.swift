//
//  SaveViewModeUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 22.09.25.
//

import Foundation

protocol SaveViewModeUseCaseProtocol {
    func execute(_ viewMode: ViewMode)
}

class SaveViewModeUseCase: SaveViewModeUseCaseProtocol {
    
    func execute(_ viewMode: ViewMode) {
        UserDefaults.standard.set(viewMode.rawValue, forKey: "selectedViewMode")
    }
}
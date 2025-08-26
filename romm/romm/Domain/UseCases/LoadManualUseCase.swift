//
//  LoadManualUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 13.08.25.
//

import Foundation

class LoadManualUseCase {
    private let manualRepository: ManualRepositoryProtocol
    
    init(manualRepository: ManualRepositoryProtocol = ManualRepository()) {
        self.manualRepository = manualRepository
    }
    
    func execute(for romId: Int) async throws -> Manual? {
        return try await manualRepository.loadManual(for: romId)
    }
    
    func getManualPDFData(for romId: Int) async throws -> Data? {
        return try await manualRepository.getManualPDFData(for: romId)
    }
}
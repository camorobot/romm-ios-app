//
//  GetFileSizeUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class GetFileSizeUseCase {
    private let fileSystemRepository: FileSystemRepositoryProtocol
    
    init(fileSystemRepository: FileSystemRepositoryProtocol) {
        self.fileSystemRepository = fileSystemRepository
    }
    
    func execute(at path: String) throws -> Int64 {
        return try fileSystemRepository.getFileSize(at: path)
    }
}
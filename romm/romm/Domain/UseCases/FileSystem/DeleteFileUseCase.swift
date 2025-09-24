//
//  DeleteFileUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class DeleteFileUseCase {
    private let fileSystemRepository: FileSystemRepositoryProtocol
    
    init(fileSystemRepository: FileSystemRepositoryProtocol) {
        self.fileSystemRepository = fileSystemRepository
    }
    
    func execute(at path: String) throws {
        try fileSystemRepository.deleteFile(at: path)
    }
}
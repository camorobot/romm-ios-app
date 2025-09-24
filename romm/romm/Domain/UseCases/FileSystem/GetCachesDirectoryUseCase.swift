//
//  GetCachesDirectoryUseCase.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//

import Foundation

class GetCachesDirectoryUseCase {
    private let fileSystemRepository: FileSystemRepositoryProtocol
    
    init(fileSystemRepository: FileSystemRepositoryProtocol) {
        self.fileSystemRepository = fileSystemRepository
    }
    
    func execute() -> String {
        return fileSystemRepository.cachesDirectory()
    }
}
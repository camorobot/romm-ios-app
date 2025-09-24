//
//  FileValidationResult.swift
//  romm
//
//  Created by Ilyas Hallak on 27.08.25.
//


struct FileValidationResult {
    let isValid: Bool
    let actualSize: Int64
    let expectedSize: Int64?
    let actualChecksum: String
    let expectedChecksum: String?
    let errorMessage: String?
}

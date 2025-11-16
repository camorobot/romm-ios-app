//
//  ByteFormatter.swift
//  romm
//
//  Created by Ilyas Hallak on 16.11.25.
//

import Foundation

struct ByteFormatter {
    static func format(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true

        return formatter.string(fromByteCount: Int64(bytes))
    }
}

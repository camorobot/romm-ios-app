//
//  rommApp.swift
//  romm
//
//  Created by Ilyas Hallak on 06.08.25.
//

import SwiftUI

@main
struct rommApp: App {
    
    init() {
        // Initialize image cache configuration at app startup
        _ = ImageCacheConfiguration.shared
    }

    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}

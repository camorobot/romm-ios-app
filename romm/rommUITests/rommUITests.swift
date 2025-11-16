//
//  rommUITests.swift
//  rommUITests
//
//  Created by Ilyas Hallak on 06.08.25.
//

import XCTest

final class rommUITests: XCTestCase {

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testTakeScreenshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // Wait for app to load
        sleep(2)

        // Take main screen screenshot
        snapshot("01-Home")

        // Navigate to Profile/Settings tab
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 5) {
            // Try to find the profile/settings tab button
            let profileButton = tabBar.buttons.element(boundBy: 1) // Usually second tab
            if profileButton.exists {
                profileButton.tap()
                sleep(1)
                snapshot("02-Profile")
            }
        }
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

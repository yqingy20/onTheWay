//
//  onTheWayUITests.swift
//  onTheWayUITests
//
//  Created by 严清驭 on 2026/9/2.
//

import XCTest

final class onTheWayUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testWelcomeCanOpenLoginAndEnterMarketplace() throws {
        let app = XCUIApplication()
        app.launch()

        let welcomeHeading = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS %@", "Turn spare time")
        ).firstMatch
        XCTAssertTrue(welcomeHeading.waitForExistence(timeout: 10))
        app.buttons["Already have an account? Log in"].tap()
        XCTAssertTrue(app.staticTexts["Welcome back"].waitForExistence(timeout: 10))
        app.buttons["Sign In"].tap()
        XCTAssertTrue(app.staticTexts["Need Help"].waitForExistence(timeout: 10))
    }

    @MainActor
    func testAuthenticatedUserCanStartCreatingTask() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST_AUTHENTICATED"]
        app.launch()

        let createButton = app.buttons["Create a new task"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 10))
        createButton.tap()
        XCTAssertTrue(app.staticTexts["What do you need?"].waitForExistence(timeout: 10))
        XCTAssertTrue(app.buttons["Food / Coffee, Prepaid orders and takeout"].exists || app.staticTexts["Food / Coffee"].exists)
    }

    @MainActor
    func testPrivacyAndResolutionStates() throws {
        let helperApp = XCUIApplication()
        helperApp.launchArguments = ["UITEST_AUTHENTICATED", "UITEST_HELPER_MODE"]
        helperApp.launch()
        let directEntry = helperApp.buttons.containing(NSPredicate(format: "label CONTAINS %@", "Direct request waiting")).firstMatch
        XCTAssertTrue(directEntry.waitForExistence(timeout: 10))
        directEntry.tap()
        XCTAssertTrue(helperApp.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Direct request from Emma W.")).firstMatch.waitForExistence(timeout: 10))
        let directOfferScreenshot = XCTAttachment(screenshot: helperApp.screenshot())
        directOfferScreenshot.name = "helper-direct-offer"
        directOfferScreenshot.lifetime = .keepAlways
        add(directOfferScreenshot)
        helperApp.terminate()

        let scenarios: [([String], String, String)] = [
            (["UITEST_TASK_DETAIL"], "privacy-task-detail", "Exact address, full order reference"),
            (["UITEST_DIRECT_SEARCH"], "direct-search", "Waiting for Alex J."),
            (["UITEST_PENDING_CHANGE"], "pending-change", "Change awaiting helper consent"),
            (["UITEST_CANCELLED_TASK"], "cancelled-task", "Task cancelled"),
            (["UITEST_DELIVERY_CONFIRMATION"], "delivery-confirmation", "Confirm your handoff"),
            (["UITEST_HELPER_PIN"], "helper-pin", "Secure handoff")
        ]

        for (arguments, screenshotName, expectedLabel) in scenarios {
            let app = XCUIApplication()
            app.launchArguments = arguments
            app.launch()
            let expected = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", expectedLabel)).firstMatch
            XCTAssertTrue(expected.waitForExistence(timeout: 10), "Missing state: \(expectedLabel)")
            if arguments.contains("UITEST_TASK_DETAIL") {
                XCTAssertFalse(app.staticTexts["2301 Bancroft Way"].exists)
                XCTAssertFalse(app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "Apt 3B")).firstMatch.exists)
            }
            if !expected.isHittable {
                for _ in 0..<4 where !expected.isHittable { app.swipeUp() }
            }

            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.name = screenshotName
            screenshot.lifetime = .keepAlways
            add(screenshot)
            app.terminate()
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}

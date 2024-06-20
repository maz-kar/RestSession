//
//  NetworkCallsUITestsLaunchTests.swift
//  NetworkCallsUITests
//
//  Created by Maziar Layeghkar on 17.03.24.
//

import XCTest

final class NetworkCallsUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

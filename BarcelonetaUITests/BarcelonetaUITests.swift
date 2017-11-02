//
//  BarcelonetaUITests.swift
//  BarcelonetaUITests
//
//  Created by Arnaud Schloune on 17/05/16.
//  Copyright © 2016 Arnaud Schloune. All rights reserved.
//

import XCTest

class BarcelonetaUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}

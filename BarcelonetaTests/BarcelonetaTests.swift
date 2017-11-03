//
//  BarcelonetaTests.swift
//  BarcelonetaTests
//
//  Created by Arnaud Schloune on 03/11/17.
//  Copyright © 2017 Arnaud Schloune. All rights reserved.
//

import XCTest
@testable import Barceloneta

class BarcelonetaTests: XCTestCase {

    var bcn: Barceloneta?

    override func setUp() {
        super.setUp()
        bcn = Barceloneta()
    }

    /*
    func testBarceloneta_Should(){
        //Given
        //When
        //Then
    }
    */

    func testBarceloneta_ShouldCalculateCorrectPercentage() {
        //Given
        //When
        //Then
        XCTAssertTrue(true)
    }

    override func tearDown() {
        super.tearDown()
        bcn = nil
    }
}

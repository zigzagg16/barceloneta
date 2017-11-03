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
        let limit: CGFloat = 50.0
        //When
        let prct0 = bcn?.percentage(limit: limit, constant: CGFloat(0))
        let prct50 = bcn?.percentage(limit: limit, constant: CGFloat(25.0))
        let prct80 = bcn?.percentage(limit: limit, constant: CGFloat(40.0))
        let prct100 = bcn?.percentage(limit: limit, constant: CGFloat(50.0))
        let prct120 = bcn?.percentage(limit: limit, constant: CGFloat(60.0))
        //Then
        XCTAssertEqual(prct0, 0)
        XCTAssertEqual(prct50, 50)
        XCTAssertEqual(prct80, 80)
        XCTAssertEqual(prct100, 100)
        XCTAssertEqual(prct120, 120)
    }

    override func tearDown() {
        super.tearDown()
        bcn = nil
    }
}

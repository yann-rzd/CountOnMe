//
//  SimpleCalcTests.swift
//  SimpleCalcTests
//
//  Created by Vincent Saluzzo on 29/03/2019.
//  Copyright © 2019 Vincent Saluzzo. All rights reserved.
//

import XCTest
@testable import CountOnMe

class CalculatorServiceTests: XCTestCase {
    var calculator: CalculatorService!

    override func setUp() {
        super.setUp()
        calculator = CalculatorService()
    }

    func testGivenNoDigitAdded_WhenTapOnOneButton_ThenOneIsAdded() {
        calculator.operation = ""
        
        calculator.add(digit: 1)
        
        XCTAssertTrue(calculator.operation.contains("1"))
    }
    
    func testGivenExpressionHaveNoResult_WhenAddADigit_ThenExpressionIsResetAnddDigitAdded() {
        calculator.operation = "1 + 1 = 2"
        
        calculator.add(digit: 1)
        
        XCTAssertTrue(calculator.operation.contains("1"))
    }
}

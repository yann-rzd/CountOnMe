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
    
    
    func test_givenOperationWithLastElementIsMathOperator_whenAddOperator_thenCannotAddMathOperator() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)
        
        
        XCTAssertThrowsError(try calculator.add(mathOperator: .plus), "") { error in
            guard let calculatorError = error as? CalculatorServiceError else {
                XCTFail()
                return
            }
            XCTAssertEqual(calculatorError, .failedToAddMathOperator)
        }
        
    }
    
    
    
}


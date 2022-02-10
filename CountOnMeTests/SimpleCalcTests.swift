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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addDigit() {
        let calculatorService = CalculatorService()
        XCTAssertTrue(calculatorService.operation.isEmpty)
        
        calculatorService.add(digit: 5)
        
        XCTAssertEqual(calculatorService.operation, "5")

    }

    
    func test_addDigit_zero() {
        let calculatorService = CalculatorService()
        XCTAssertTrue(calculatorService.operation.isEmpty)
        
        calculatorService.add(digit: 0)
        calculatorService.add(digit: 0)
        
        XCTAssertEqual(calculatorService.operation, "0")

    }
    
    

}

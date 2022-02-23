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

    // MARK: - Test func add(digit: Int) in CalculatorService
    func testGivenExpressionHaveResult_WhenAddADigit_ThenExpressionIsResetAnddDigitAdded() {
        calculator.operation = "1 + 1 = 2"
        calculator.add(digit: 1)

        XCTAssertTrue(calculator.operation.contains("1"))
    }

    func testGivenNoDigitAdded_WhenTapOnOneButton_ThenOneIsAdded() {
        calculator.operation = ""
        calculator.add(digit: 1)

        XCTAssertTrue(calculator.operation.contains("1"))
    }

    // Test func add(mathOperator: MathOperator) in CalculatorService
    func testGivenExpressionHasResult_WhenAddAMathOperator_ThenNothingHappens() throws {
        calculator.operation = "1 + 1 = 2"
        try calculator.add(mathOperator: .plus)

        XCTAssertEqual(calculator.operation, "1 + 1 = 2")
    }

    func testGivenExpressionHasResult_WhenAddAMinusMathOperator_ThenExpressionResetAndMinusAdded() throws {
        calculator.operation = "1 + 1 = 2"
        try calculator.add(mathOperator: .minus)

        XCTAssertEqual(calculator.operation, " - ")
    }

    func testGivenOperationWithLastElementIsMathOperator_WhenAddOperatorExeptMinus_ThenCannotAddMathOperator() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)

        XCTAssertThrowsError(try calculator.add(mathOperator: .plus))
    }

    func testGivenOperationWithLastElementMathOperator_WhenAddMinusOperator_ThenCanAddMinusOperator() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)

        XCTAssertNoThrow(try calculator.add(mathOperator: .minus))
        XCTAssertEqual(calculator.operation, "3 +  - ")
    }

    func testGivenOperationWithMinusAsFirtElement_WhenAddMinusOperator_ThenCannotAddMinusOperator() throws {
        calculator.operation = ""
        try calculator.add(mathOperator: .minus)

        XCTAssertThrowsError(try calculator.add(mathOperator: .minus))
    }

    func testGivenOperationWithTwoLastElementMathOperator_WhenAddOperator_ThenCannotAddMathOperator() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)
        try calculator.add(mathOperator: .minus)

        XCTAssertThrowsError(try calculator.add(mathOperator: .minus))
    }

    // MARK: - Test func add() in CalculatorService
    func testGivenOperationLasElementIsDigit_WhenAddDecimalPoint_ThenDecimalPointAdded() throws {
        calculator.add(digit: 3)

        XCTAssertNoThrow(try calculator.addDecimalPoint())
        XCTAssertEqual(calculator.operation, "3.")
    }

    func testGivenOperationIsEmpty_WhenAddDecimalPoint_ThenDecimalPointAddedWithZero() throws {
        calculator.operation = ""

        XCTAssertNoThrow(try calculator.addDecimalPoint())
        XCTAssertEqual(calculator.operation, "0.")
    }

    func testGivenOperationLastElementIsMathOperator_WhenAddDecimalPoint_ThenDecimalPointAddedWithZero() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)

        XCTAssertNoThrow(try calculator.addDecimalPoint())
        XCTAssertEqual(calculator.operation, "3 + 0.")
    }

    func testGivenOperationHasResult_WhenAddDecimalPoint_ThenResetOperationAndDeciMalPointWithZeroAdded() throws {
        calculator.operation = "3 + 3 = 6"

        XCTAssertNoThrow(try calculator.addDecimalPoint())
        XCTAssertEqual(calculator.operation, "0.")
    }

    func testGivenOperationLastElementIsDecimalPoint_WhenAddDecimalPoint_ThenCannotAddDecimalPoint() throws {
        calculator.add(digit: 3)
        try calculator.addDecimalPoint()

        XCTAssertThrowsError(try calculator.addDecimalPoint())
        XCTAssertEqual(calculator.operation, "3.")
    }

    // MARK: - Test func resetOperation() in CalculatorService
    func testGivenOperationContainsElements_WhenResetOperation_ThenOperationIsreset() {
        calculator.operation = "3 + 3 = 6"
        calculator.resetOperation()

        XCTAssertTrue(calculator.operation.isEmpty)
    }

    // MARK: - Test func solveOperation() in CalculatorService
    func testGivenOperationIsNotCorrect_WhenSolveOperation_ThenCannotSolveOperation() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)
        let resultStatus = calculator.solveOperation()

        XCTAssertEqual(resultStatus.isOperationSolved, false)
    }

    func testGivenOperationhasNotEnoughtElement_WhenSolveOperation_ThenCannotSolveOperation() {
        calculator.add(digit: 3)
        let resultStatus = calculator.solveOperation()

        XCTAssertEqual(resultStatus.isOperationSolved, false)
    }

    func testGivenOperationhasResult_WhenSolveOperation_ThenCannotSolveOperation() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)
        calculator.add(digit: 3)
        let firstResultStatus = calculator.solveOperation()
        let secondResultStatus = calculator.solveOperation()

        XCTAssertEqual(firstResultStatus.isOperationSolved, true)
        XCTAssertEqual(secondResultStatus.isOperationSolved, false)
    }

    func testGivenOperationIsDividedByZero_WhenSolveOperation_ThenCannotSolveOperation() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .divide)
        calculator.add(digit: 0)
        let resultStatus = calculator.solveOperation()

        XCTAssertEqual(resultStatus.isOperationSolved, false)
    }

    // MARK: - mergeMinusToNegativeDigit() in CalculatorService
    func testGivenOperationContainsNegativeDigit_WhenSolveOperation_ThenOperationSolved() {
        calculator.operation = "- 4 + - 6 - - 6"
        let operationResult = "- 4 + - 6 - - 6 = -4"
        _ = calculator.solveOperation()

        XCTAssertEqual(calculator.operation, operationResult)
    }

    // MARK: - Test solveMultiplyAndDivideOperations() in CalculatorService
    func testGivenOperationconatinsMultipliesAndSum_WhenSolveOperation_ThenMultipliesAreSolvedFirst() {
        calculator.operation = "1 + 2 × 3 + 4 × 5"
        let operationResult = "1 + 2 × 3 + 4 × 5 = 27"
        _ = calculator.solveOperation()

        XCTAssertEqual(calculator.operation, operationResult)
    }

    func testGivenOperationconatinsDividesAndSum_WhenSolveOperation_ThenDividesAreSolvedFirst() {
        calculator.operation = "1 + 2 ÷ 3 + 4 ÷ 5"
        let operationResult = "1 + 2 ÷ 3 + 4 ÷ 5 = 2.47"
        _ = calculator.solveOperation()

        XCTAssertEqual(calculator.operation, operationResult)
    }
}

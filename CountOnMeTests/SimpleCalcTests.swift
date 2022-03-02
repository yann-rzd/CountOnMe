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
    func testGivenExpressionHaveResult_WhenAddADigit_ThenExpressionIsResetAnddDigitAdded() throws {
//        calculator.operation = "1 + 1 = 2"
        calculator.add(digit: 1)
        try calculator.add(mathOperator: .plus)
        calculator.add(digit: 1)
        try calculator.solveOperation()
        calculator.add(digit: 1)

        XCTAssertEqual(calculator.operation, "1")
    }

    func testGivenNoDigitAdded_WhenTapOnOneButton_ThenOneIsAdded() {
        calculator.operation = ""
        calculator.add(digit: 1)

        XCTAssertEqual(calculator.operation, "1")
    }

    // MARK: - Test func add(mathOperator: MathOperator) in CalculatorService
    func testGivenExpressionHasResult_WhenAddAMathOperator_ThenError() throws {
//        calculator.operation = "1 + 1 = 2"
        calculator.add(digit: 1)
        try calculator.add(mathOperator: .plus)
        calculator.add(digit: 1)
        try calculator.solveOperation()

        XCTAssertThrowsError(try calculator.add(mathOperator: .plus))
    }

    func testGivenExpressionHasResult_WhenAddAMinusMathOperator_ThenExpressionResetAndMinusAdded() throws {
//        calculator.operation = "1 + 1 = 2"
        calculator.add(digit: 1)
        try calculator.add(mathOperator: .plus)
        calculator.add(digit: 1)
        _ = try calculator.solveOperation()
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

    func testGivenOperationIsEmpty_WhenAddPlusOperator_ThenThrowsError() throws {
        calculator.operation = ""

        XCTAssertThrowsError( try calculator.add(mathOperator: .plus))
    }

    func testGivenOperationisEmpty_WhenAddMinusOperator_ThenMinusAdded() throws {
        try calculator.add(mathOperator: .minus)

        XCTAssertEqual(calculator.operation, " - ")
    }

    func testGivenOperationHasResult_WhenAddMinusOperator_ThenOperationResetAndMinusAdded() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)
        calculator.add(digit: 2)
        _ = try calculator.solveOperation()
        try calculator.add(mathOperator: .minus)
        XCTAssertEqual(calculator.operation, " - ")
    }

    func testGivenOperationHasTwoMinusInARow_WhenAddMinusOperator_ThenThrowsError() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .minus)
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
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)
        calculator.add(digit: 3)
        _ = try calculator.solveOperation()

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
    func testGivenOperationContainsElements_WhenResetOperation_ThenOperationIsreset() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)
        calculator.add(digit: 3)
        _ = try calculator.solveOperation()
        calculator.resetOperation()

        XCTAssertTrue(calculator.operation.isEmpty)
    }

    // MARK: - Test func solveOperation() in CalculatorService
    func testGivenOperationIsNotCorrect_WhenSolveOperation_ThenCannotSolveOperation() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)
        XCTAssertThrowsError(try calculator.solveOperation())
    }

    func testGivenOperationhasNotEnoughtElement_WhenSolveOperation_ThenCannotSolveOperation() {
        calculator.add(digit: 3)
        XCTAssertThrowsError(try calculator.solveOperation())
    }

    func testGivenOperationhasResult_WhenSolveOperation_ThenCannotSolveOperation() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .plus)
        calculator.add(digit: 3)
        _ = try calculator.solveOperation()
        XCTAssertThrowsError(try calculator.solveOperation())
    }

    func testGivenOperationIsDividedByZero_WhenSolveOperation_ThenCannotSolveOperation() throws {
        calculator.add(digit: 3)
        try calculator.add(mathOperator: .divide)
        calculator.add(digit: 0)
        XCTAssertThrowsError(try calculator.solveOperation())
    }

    // MARK: - mergeMinusToNegativeDigit() in CalculatorService
    func testGivenOperationContainsNegativeDigit_WhenSolveOperation_ThenOperationSolved() throws {
        try calculator.add(mathOperator: .minus)
        calculator .add(digit: 4)
        try calculator.add(mathOperator: .plus)
        try calculator.add(mathOperator: .minus)
        calculator .add(digit: 6)
        try calculator.add(mathOperator: .minus)
        try calculator.add(mathOperator: .minus)
        calculator .add(digit: 6)
        try calculator.solveOperation()

        XCTAssertEqual(calculator.operation, " - 4 +  - 6 -  - 6 = -4")
    }

    // MARK: - Test solveMultiplyAndDivideOperations() in CalculatorService
    func testGivenOperationconatinsMultipliesAndSum_WhenSolveOperation_ThenMultipliesAreSolvedFirst() throws {
        calculator .add(digit: 1)
        try calculator.add(mathOperator: .plus)
        calculator .add(digit: 2)
        try calculator.add(mathOperator: .multiply)
        calculator .add(digit: 3)
        try calculator.add(mathOperator: .plus)
        calculator .add(digit: 4)
        try calculator.add(mathOperator: .multiply)
        calculator .add(digit: 5)
        try calculator.solveOperation()

        XCTAssertEqual(calculator.operation, "1 + 2 × 3 + 4 × 5 = 27")
    }

    func testGivenOperationconatinsDividesAndSum_WhenSolveOperation_ThenDividesAreSolvedFirst() throws {
        calculator .add(digit: 1)
        try calculator.add(mathOperator: .plus)
        calculator .add(digit: 2)
        try calculator.add(mathOperator: .divide)
        calculator .add(digit: 3)
        try calculator.add(mathOperator: .plus)
        calculator .add(digit: 4)
        try calculator.add(mathOperator: .divide)
        calculator .add(digit: 5)
        try calculator.solveOperation()

        XCTAssertEqual(calculator.operation, "1 + 2 ÷ 3 + 4 ÷ 5 = 2.466667")
    }

    func testGivenOperationHasUnknownElement_WhenSolveOperation_ThenThrowsError() throws {
        calculator.operation = "A + 3"
        XCTAssertThrowsError(try calculator.solveOperation())
    }

    func testGivenOperationHasThreeDigitsAsElementInARow_WhenSolveOperation_ThenThrowsError() throws {
        calculator.operation = "3 3 3"
        XCTAssertThrowsError(try calculator.solveOperation())
    }

    // MARK: - Test zero handling

    func testGivenOperationHasZero_WhenAddZero_ThenOneZeroOnly() throws {
        calculator.add(digit: 0)
        calculator.add(digit: 0)
        XCTAssertEqual(calculator.operation, "0")
    }

    func testGivenOperationIsEmpty_WhenAddZero_ThenOneZeroOnly() throws {
        calculator.add(digit: 0)
        XCTAssertEqual(calculator.operation, "0")
    }

    func testGivenOperationHasZeroAndPoint_WhenAddZero_ThenZeroAdded() throws {
        calculator.add(digit: 0)
        try calculator.addDecimalPoint()
        calculator.add(digit: 0)
        XCTAssertEqual(calculator.operation, "0.0")
    }

    func testGivenOperationHasZeroAndPointZero_WhenAddZero_ThenZeroAdded() throws {
        calculator.add(digit: 0)
        try calculator.addDecimalPoint()
        calculator.add(digit: 0)
        calculator.add(digit: 0)
        XCTAssertEqual(calculator.operation, "0.00")
    }

    func testGivenOperationHasZeroAndPointZeroThree_WhenAddZero_ThenZeroAdded() throws {
        calculator.add(digit: 0)
        try calculator.addDecimalPoint()
        calculator.add(digit: 0)
        calculator.add(digit: 3)
        calculator.add(digit: 0)
        XCTAssertEqual(calculator.operation, "0.030")
    }

    func testGivenOperationHasZero_WhenAddTwo_ThenOperationIsTwoOnly() throws {
        calculator.add(digit: 0)
        calculator.add(digit: 2)
        XCTAssertEqual(calculator.operation, "2")
    }

    func testGivenOperationHasZero_WhenAddTwo_ThenOperationIsTwoOnlyasdadsadsasd() throws {
        let numberFormatterMock = FailureNumberFormatterMock()
        let calculatorWithMockFormatter = CalculatorService(numberFormatter: numberFormatterMock)
        calculatorWithMockFormatter.add(digit: 0)
        try calculatorWithMockFormatter.add(mathOperator: .plus)
        calculatorWithMockFormatter.add(digit: 0)
        try calculatorWithMockFormatter.solveOperation()
        XCTAssertEqual(calculatorWithMockFormatter.operation, "0 + 0 = ")
    }
    
    
//    func testTEstTest() throws {
//        calculator.operation = "0 + a"
//        XCTAssertThrowsError(try calculator.solveOperation())
//    }
}

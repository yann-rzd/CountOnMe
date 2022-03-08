//
//  CalculatorService.swift
//  CountOnMe
//
//  Created by Yann Rouzaud on 10/02/2022.
//  Copyright © 2022 Vincent Saluzzo. All rights reserved.
//
import Foundation

protocol CalculatorServiceDelegate: AnyObject {
    func didUpdateOperation(operation: String)
}

final class CalculatorService {

    init(
        numberFormatter: NumberFormatterProtocol = NumberFormatter()
    ) {
        self.numberFormatter = numberFormatter
    }

    // MARK: - INTERNAL : propeties
    weak var delegate: CalculatorServiceDelegate?

    var operation = "" {
        didSet {
            delegate?.didUpdateOperation(operation: operation)
        }
    }

    var elements: [String] {
        return operation.split(separator: " ").map { "\($0)" }
    }

    // MARK: - INTERNAL : methods

    /// This function adds a digit to the operation
    /// - parameter digit: Int
    func add(digit: Int) {
        if expressionHaveResult {
            resetOperation()
        }

        if let lastElement = elements.last,
           lastElement == "0" {
            operation.removeLast()
        }

        operation.append(digit.description)
    }

    /// This funtion adds an operator to the operation
    /// - parameter mathOperator: MathOperator
    /// - throws: Failed to add operator
    func add(mathOperator: MathOperator) throws {
        if expressionHaveResult {
            resetOperation()
        }

        guard canAdd(mathOperator: mathOperator) else {
            throw CalculatorServiceError.failedToAddMathOperator
        }

        operation.append(" \(mathOperator.symbol) ")
    }

    /// This function adds a decimal point to the operation
    /// - throws: Failed to add a decimal point
    func addDecimalPoint() throws {
        guard canAddDecimalPoint else {
            throw CalculatorServiceError.failedToAddPoint
        }

        guard !expressionHaveResult else {
            resetOperation()
            operation.append("0.")
            return
        }

        if conditionForZeroBeforeDecimalPoint {
            operation.append(DecimalPointFormat.zeroBeforeDeciamlPoint.format)
        } else {
            operation.append(".")
        }
    }

    /// This function resets the operation
    func resetOperation() {
        operation.removeAll()
    }

    /// This functions solves the operation
    /// - returns: Bool and String
    func solveOperation() throws {
        guard expressionIsCorrect else {
            throw CalculatorServiceError.expressionIsNotCorrect
        }

        guard expressionHaveEnoughElement else {
            throw CalculatorServiceError.expressionHaveNotEnoughElement
        }

        guard !expressionHaveResult else {
            throw CalculatorServiceError.expressionHaveResult
        }

        guard expressionIsNotDividedByZero else {
            throw CalculatorServiceError.expressionIsDividedByZero
        }

        operationsToReduce = elements
        mergeMinusToNegativeDigit()

        while operationsToReduce.count > 1 {
            try solveOperationUnits()
        }

        let resultString = operationsToReduce.first ?? ""
        guard let resultNumber = Double(resultString) else {
            operation.append(" = ")
            return
        }

        let formattedResult = format(result: resultNumber)
        operation.append(" = \(formattedResult)")
    }

    // MARK: - PRIVATE : properties

    private let numberFormatter: NumberFormatterProtocol

    private var operationsToReduce: [String] = []

    // Error check computed variables
    private var expressionIsCorrect: Bool {
        !isLastElementMathOperator
    }

    private var expressionHaveEnoughElement: Bool {
        return elements.count >= 3
    }

    private var expressionHaveResult: Bool {
        return operation.firstIndex(of: "=") != nil
    }

    private var expressionIsNotDividedByZero: Bool {
        return !operation.contains("÷ 0")
    }

    private var expressionContainsMultiplyOrDivide: Bool {
        operationsToReduce.contains { element in
            isSymbolPriority(symbol: element)
        }
    }

    private var conditionForZeroBeforeDecimalPoint: Bool {
        isLastElementMathOperator || elements.isEmpty
    }

    private var isFirstElementIsMinusOperator: Bool {
        guard let firstElement = elements.first else {
            return false
        }
        return isSymbolMathOperator(symbol: firstElement)
    }

    private var isLastElementMathOperator: Bool {
        guard let lastElement = elements.last else {
            return false
        }

        return isSymbolMathOperator(symbol: lastElement)
    }

    private var isPreviousLastElementMathOperator: Bool {
        guard elements.count >= 2 else {
            return false
        }
        let previousLastElement = elements[elements.count - 2]
        return isSymbolMathOperator(symbol: previousLastElement)
    }

    private var canAddDecimalPoint: Bool {

        guard let lastElement = elements.last else {
            return true
        }

        return !lastElement.contains(".")
    }

    private var canAddMinusOperator: Bool {
        guard elements.count < 2 && isFirstElementIsMinusOperator else {
            return !isPreviousLastElementMathOperator || !isLastElementMathOperator
        }
        return false
    }

    // MARK: - PRIVATE : methods

    /// This function solves multiplies and divides
    private func solveOperationUnits() throws {
        try ensureOperationValidity(operationToReduce: operationsToReduce)

        for (index, element) in operationsToReduce.enumerated() {
            guard let mathOperator = MathOperator(symbolString: element),
                !expressionContainsMultiplyOrDivide || (expressionContainsMultiplyOrDivide && mathOperator.isPriority)
            else {
                continue
            }

            solveOperationUnit(indexOperand: index, mathOperator: mathOperator)
            break
        }
    }

    private func solveOperationUnit(indexOperand: Int, mathOperator: MathOperator) {
        guard
            let left = Double(operationsToReduce[indexOperand-1]),
            let right = Double(operationsToReduce[indexOperand+1])
        else {
            return
        }

        let result = mathOperator.operation(left, right)

        operationsToReduce.insert(result.description, at: indexOperand-1)
        for _ in 1...3 {
            operationsToReduce.remove(at: indexOperand)
        }
    }

    private func ensureOperationValidity(operationToReduce: [String]) throws {
        for (index, element) in operationToReduce.enumerated() {
            if !index.isMultiple(of: 2) && MathOperator(symbolString: element) == nil {
                throw CalculatorServiceError.expressionIsDividedByZero
            } else if index.isMultiple(of: 2) && Double(element) == nil {
                throw CalculatorServiceError.expressionIsDividedByZero
            }
        }
    }

    /// This function merges a minus and a digit to create negative digit
    private func mergeMinusToNegativeDigit() {
        while let minusIndex = operationsToReduce.firstIndex(of: "-") {

            if operationsToReduce[minusIndex+1] == "-" {
                operationsToReduce[minusIndex+1] = "\(operationsToReduce[minusIndex+1])\(operationsToReduce[minusIndex+2])"
                operationsToReduce.remove(at: minusIndex+2)
            } else if minusIndex == 0 || operationsToReduce[minusIndex-1] == "+" || operationsToReduce[minusIndex-1] == "×" || operationsToReduce[minusIndex-1] == "÷" {
                operationsToReduce[minusIndex] = "\(operationsToReduce[minusIndex])\(operationsToReduce[minusIndex+1])"
                operationsToReduce.remove(at: minusIndex+1)
            } else {
                return
            }
        }
    }

    /// This function checks if a math operator can be added
    /// - parameter mathOperator: A math operator.
    /// - returns: Bool
    private func canAdd(mathOperator: MathOperator) -> Bool {
        guard mathOperator != .minus else {
            return canAddMinusOperator
        }

        guard let lastElement = elements.last else {
            return false
        }

        return !MathOperator.allCases.contains { mathOperator in
            mathOperator.symbol.description == lastElement
        }
    }

    /// This function checks if an element is a math operator
    /// - parameter symbol: String.
    /// - returns: Bool
    private func isSymbolMathOperator(symbol: String) -> Bool {
        MathOperator.allCases.contains { mathOperator in
            mathOperator.symbol.description == symbol
        }
    }

    /// This function checks if an element is a priority math operator
    /// - parameter symbol: String.
    /// - returns: Bool
    private func isSymbolPriority(symbol: String) -> Bool {
        guard let mathOperator = MathOperator(symbolString: symbol) else {
            return false
        }
        return mathOperator.isPriority
    }

    private func format(result: Double) -> String {

        numberFormatter.maximumFractionDigits = 6
        numberFormatter.allowsFloats = true

        guard let formattedDescription = numberFormatter.string(from: result as NSNumber) else {
            return ""
        }
        return formattedDescription
    }
}

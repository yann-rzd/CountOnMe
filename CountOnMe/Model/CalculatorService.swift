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
    func didProduceError(error: CalculatorServiceError)
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
    func add(mathOperator: MathOperator) {
        if expressionHaveResult {
            resetOperation()
        }

        guard canAdd(mathOperator: mathOperator) else {
            delegate?.didProduceError(error: .failedToAddMathOperator)
            return
        }

        operation.append(" \(mathOperator.symbol) ")
    }

    /// This function adds a decimal point to the operation
    /// - throws: Failed to add a decimal point
    func addDecimalPoint() {
        guard canAddDecimalPoint else {
            delegate?.didProduceError(error: .failedToAddPoint)
            return
        }

        guard !expressionHaveResult else {
            resetOperation()
            operation.append(DecimalPointFormat.zeroBeforeDecimalPoint.format)
            return
        }

        if conditionForZeroBeforeDecimalPoint {
            operation.append(DecimalPointFormat.zeroBeforeDecimalPoint.format)
        } else {
            operation.append(DecimalPointFormat.decimalPoint.format)
        }
    }

    /// This function resets the operation
    func resetOperation() {
        operation.removeAll()
    }

    /// This functions solves the operation
    /// - returns: Bool and String
    func solveOperation() {
        guard expressionIsCorrect else {
            delegate?.didProduceError(error: .expressionIsNotCorrect)
            return
        }

        guard expressionHaveEnoughElement else {
            delegate?.didProduceError(error: .expressionHaveNotEnoughElement)
            return
        }

        guard !expressionHaveResult else {
            delegate?.didProduceError(error: .expressionHaveResult)
            return
        }

        guard expressionIsNotDividedByZero else {
            delegate?.didProduceError(error: .expressionIsDividedByZero)
            return
        }

        operationsToReduce = elements
        mergeMinusToNegativeDigit()

        while operationsToReduce.count > 1 {
            do {
                try searchAndSolveOperationUnit()
            } catch {
                guard let error = error as? CalculatorServiceError else {
                    return
                }
                delegate?.didProduceError(error: error)
                return
            }
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
        guard let indexForZero = elements.firstIndex(of: "0") else {
            return true
        }

        guard indexForZero > 1 else {
            return true
        }

        let previousIndexOfZero = indexForZero - 1
        if elements[previousIndexOfZero] == "÷" {
            return false
        } else {
            return true
        }
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
    private func searchAndSolveOperationUnit() throws {
        try ensureOperationValidity(operationToReduce: operationsToReduce)

        for (index, element) in operationsToReduce.enumerated() {
            guard let mathOperator = MathOperator(symbolString: element),
                !expressionContainsMultiplyOrDivide || mathOperator.isPriority
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
            let isIndexEven = index.isMultiple(of: 2)

            let isElementMathOperator = MathOperator(symbolString: element) != nil
            let isElementNumber = Double(element) != nil

            switch (isIndexEven, isElementMathOperator, isElementNumber) {
            case (false, false, _):
                throw CalculatorServiceError.operationUnitIsNotValid
            case (true, _, false):
                throw CalculatorServiceError.operationUnitIsNotValid
            default:
                break
            }
        }
    }

    /// This function merges a minus and a digit to create negative digit
    private func mergeMinusToNegativeDigit() {
        while let minusIndex = operationsToReduce.firstIndex(of: MathOperator.minus.symbol.description) {

            let nextElementIndex = minusIndex + 1
            let nextElement = operationsToReduce[nextElementIndex]

            if MathOperator(symbolString: nextElement) == .minus {
                operationsToReduce[nextElementIndex] = "\(nextElement)\(operationsToReduce[minusIndex+2])"
                operationsToReduce.remove(at: minusIndex+2)
            } else if minusIndex == 0 || MathOperator(symbolString: operationsToReduce[minusIndex-1]) != nil {
                operationsToReduce[minusIndex] = "\(operationsToReduce[minusIndex])\(nextElement)"
                operationsToReduce.remove(at: nextElementIndex)
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

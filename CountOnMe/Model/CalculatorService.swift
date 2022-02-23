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
        guard !expressionHaveResult else {
            resetOperation()
            operation.append(digit.description)
            return
        }
        operation.append(digit.description)
    }

    /// This funtion adds an operator to the operation
    /// - parameter mathOperator: MathOperator
    /// - throws: Failed to add operator
    func add(mathOperator: MathOperator) throws {
        guard !expressionHaveResult else {
            if mathOperator == .minus {
                resetOperation()
                operation.append(" \(mathOperator.symbol) ")
            }
            return
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
            operation.append("0.")
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
    func solveOperation() -> (isOperationSolved: Bool, message: String) {
        guard expressionIsCorrect else {
            return (false, "Veuillez entrer une expression correcte.")
        }

        guard expressionHaveEnoughElement else {
            return (false, "Veuillez démarrer un nouveau calcul.")
        }

        guard !expressionHaveResult else {
            return (false, "L'opération est déjà résolue")
        }

        guard expressionIsNotDividedByZero else {
            return (false, "Impossible de diviser par 0")
        }

        operationsToReduce = elements

        while operationsToReduce.count > 1 {
            mergeMinusToNegativeDigit()
            solveMultiplyAndDivideOperations()
            solvePlusAndMinusOperations()
        }
        operation.append(" = \(operationsToReduce.first!)")
        return (true, "")
    }

    // MARK: - PRIVATE : properties
    private var operationsToReduce: [String]!

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
        return !operation.contains(" 0")
    }

    private var expressionContainsMultiplyOrDivide: Bool {
        elements.contains { element in
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
        guard !elements.isEmpty else {
            return true
        }

        guard let lastElement = elements.last else {
            return false
        }

        return !lastElement.contains(".")
    }

    private var canAddMinusOperator: Bool {

        if elements.count < 2 && isFirstElementIsMinusOperator {
            return false
        } else if expressionHaveResult {
            return true
        } else {
            return !(isLastElementMathOperator && isPreviousLastElementMathOperator)
        }
    }

    // MARK: - PRIVATE : methods

    /// This function solves multiplies and divides
    private func solveMultiplyAndDivideOperations() {
        while expressionContainsMultiplyOrDivide {
            if let indexOperand = operationsToReduce.firstIndex(of: "×") {
                multiplyOperation(indexOperand)
            } else if let indexOperand = operationsToReduce.firstIndex(of: "÷") {
                divideOperation(indexOperand)
            } else {
                return
            }
        }
    }

    /// This function is used to multiply
    /// - parameter indexOperand: Index of the math operator multiply.
    private func multiplyOperation(_ indexOperand: Int) {
        let left = Double(operationsToReduce[indexOperand-1])!
        let right = Double(operationsToReduce[indexOperand+1])!
        let result = Double(left * right)

        operationsToReduce.insert("\(result.clean)", at: indexOperand-1)
        for _ in 1...3 {
            operationsToReduce.remove(at: indexOperand)
        }
    }

    /// This function is used to divide
    /// - parameter indexOperand: Index of the math operator divide.
    private func divideOperation(_ indexOperand: Int) {
        let left = Double(operationsToReduce[indexOperand-1])!
        let right = Double(operationsToReduce[indexOperand+1])!
        let result = Double(left / right)

        operationsToReduce.insert("\(result.clean)", at: indexOperand-1)
        for _ in 1...3 {
            operationsToReduce.remove(at: indexOperand)
        }
    }

    /// This function solves additions and subtractions
    private func solvePlusAndMinusOperations() {
        if operationsToReduce.count >= 3 {
            let left = Double(operationsToReduce[0])!
            let operand = operationsToReduce[1]
            let right = Double(operationsToReduce[2])!

            let result: Double
            switch operand {
            case "+": result = left + right
            case "-": result = left - right
            default: fatalError("Unknown operator !")
            }
            operationsToReduce = Array(operationsToReduce.dropFirst(3))
            operationsToReduce.insert("\(result.clean)", at: 0)
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
        guard
            let symbolAsCharacter = symbol.first,
            let mathOperator = MathOperator(symbol: symbolAsCharacter) else {
            return false
        }
        return mathOperator.isPriority
    }
}

// MARK: - EXTENSIONS
extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }

}

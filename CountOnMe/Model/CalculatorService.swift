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
    
    weak var delegate: CalculatorServiceDelegate?
    
    var operation = "" {
        didSet {
            delegate?.didUpdateOperation(operation: operation)
        }
    }
    
    var elements: [String] {
        return operation.split(separator: " ").map { "\($0)" }
    }
    
    var operationsToReduce: [String]!
    
    // Error check computed variables
    var expressionIsCorrect: Bool {
        !isLastElementMathOperator
    }
    
    var expressionHaveEnoughElement: Bool {
        return elements.count >= 3
    }
    
    var canAddDecimalPoint: Bool {
        guard !elements.isEmpty else {
            return true
        }
        
        guard let lastElement = elements.last else {
            return false
        }
        
        return !lastElement.contains(".")
        
        
        //elements.last != "." && !elements.allSatisfy({ $0.contains(".") }) && !(elements.last?.contains("."))! || elements.isEmpty
    }
    
    var expressionHaveResult: Bool {
        return operation.firstIndex(of: "=") != nil
    }
    
    var conditionForZeroBeforeDecimalPoint: Bool {
        isLastElementMathOperator || elements.isEmpty
    }
    
    var expressionIsNotDividedByZero: Bool {
        return !operation.contains("/ 0")
    }
    
    var expressionContainsMultiplyOrDivide: Bool {
        elements.contains { element in
            isSymbolPriority(symbol: element)
        }
        //elements.firstIndex(of: "*") != nil || elements.firstIndex(of: "/") != nil
    }
    
    func add(digit: Int) {
        guard !expressionHaveResult else {
            resetOperation()
            operation.append(digit.description)
            return
        }
        operation.append(digit.description)
    }
    
    func add(mathOperator: MathOperator) throws {
        guard !expressionHaveResult else {
            return
        }
        
        guard canAdd(mathOperator: mathOperator) else {
            throw CalculatorServiceError.failedToAddMathOperator
        }

        
        operation.append(" \(mathOperator.symbol) ")
    }
    
    func add() throws {
        guard canAddDecimalPoint else {
            throw CalculatorServiceError.failedToAddPoint
        }
        
        guard !expressionHaveResult else {
            resetOperation()
            if conditionForZeroBeforeDecimalPoint {
                operation.append("0.")
            } else {
                operation.append(".")
            }
            return
        }
        
        if conditionForZeroBeforeDecimalPoint {
            operation.append("0.")
        } else {
            operation.append(".")
        }
        
    }
    
    func resetOperation() {
        operation.removeAll()
    }
    
    func solveOperation() -> (isOperationSolved: Bool, message: String) {
        guard expressionIsCorrect else {
            return (false, "Veuillez entrer une expression correcte.")
        }
        
        guard expressionHaveEnoughElement else {
            return (false, "Veuillez démarrer un nouveau calcul.")
        }
        
        guard !expressionHaveResult else {
            return (false, "")
        }
        
        guard expressionIsNotDividedByZero else {
            return (false, "Impossible de diviser par 0")
        }
        
//        if expressionContainBracket {
//            guard isBalanced(operation) else {
//                return (false, "Une des parenthèse n'est pas fermée")
//            }
//        }
        
        operationsToReduce = elements
        print("operationToReduce : \(operationsToReduce!)")
        
        while operationsToReduce.count > 1 {
            print("operationToReduce : \(operationsToReduce!)")
            mergeMinusToNegativeDigit()
            solveMultiplyAndDivideOperations()
            solvePlusAndMinusOperations()
            
            operation.append(" = \(operationsToReduce.first!)")
            print("operation : \(operation)")
        }
        return (true, "")
    }
    
    private func solveMultiplyAndDivideOperations() {
        while expressionContainsMultiplyOrDivide {
            print("expressionContainsMultiplyOrDivide : \(expressionContainsMultiplyOrDivide)")
            //let indexOperand: Int?
            
            if let indexOperand = operationsToReduce.firstIndex(of: "*") {
                print("indexOperand : \(indexOperand)")
                
                let left = Double(operationsToReduce[indexOperand-1])!
                print("left : \(left)")
                let right = Double(operationsToReduce[indexOperand+1])!
                print("right : \(right)")
                
                let result = Double(left * right)
                print("result : \(result)")
                
                operationsToReduce.insert("\(result.clean)", at: indexOperand-1)
                print("operationToReduce : \(operationsToReduce!)")
                operationsToReduce.remove(at: indexOperand)
                print("operationToReduce : \(operationsToReduce!)")
                operationsToReduce.remove(at: indexOperand)
                print("operationToReduce : \(operationsToReduce!)")
                operationsToReduce.remove(at: indexOperand)
                print("operationToReduce : \(operationsToReduce!)")
                
            } else if let indexOperand = operationsToReduce.firstIndex(of: "/") {
                
                let left = Double(operationsToReduce[indexOperand-1])!
                let right = Double(operationsToReduce[indexOperand+1])!
                
                let result = Double(left / right)
                
                operationsToReduce.insert("\(result.clean)", at: indexOperand-1)
                operationsToReduce.removeSubrange(indexOperand-1...indexOperand+1)
            } else {
                return
            }
        }
    }
    
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
    
    private func mergeMinusToNegativeDigit() {
        while let minusIndex = operationsToReduce.firstIndex(of: "-") {
            
            if operationsToReduce[minusIndex+1] == "-" {
                operationsToReduce[minusIndex+1] = "\(operationsToReduce[minusIndex+1])\(operationsToReduce[minusIndex+2])"
                operationsToReduce.remove(at: minusIndex+2)
            } else if minusIndex == 0 || operationsToReduce[minusIndex-1] == "+" || operationsToReduce[minusIndex-1] == "*" || operationsToReduce[minusIndex-1] == "/" {
                operationsToReduce[minusIndex] = "\(operationsToReduce[minusIndex])\(operationsToReduce[minusIndex+1])"
                operationsToReduce.remove(at: minusIndex+1)
            }
        }
    }
    
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
        
        // return elements.last != "+" && elements.last != "-" && elements.last != "*" && elements.last != "/" && elements.first != nil
    }
    
    private var canAddMinusOperator: Bool {
        !(isLastElementMathOperator && isPreviousLastElementMathOperator)
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
    
    private func isSymbolMathOperator(symbol: String) -> Bool {
        MathOperator.allCases.contains { mathOperator in
            mathOperator.symbol.description == symbol
        }
    }
    
    private func isSymbolPriority(symbol: String) -> Bool {
        guard
            let symbolAsCharacter = symbol.first,
            let mathOperator = MathOperator(symbol: symbolAsCharacter) else {
            return false
        }
        
        return mathOperator.isPriority
    }
}


extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }

}

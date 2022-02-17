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
        return elements.last != "+" && elements.last != "-" && elements.last != "*" && elements.last != "/"
    }
    
    var expressionHaveEnoughElement: Bool {
        return elements.count >= 3
    }
    
    var canAddOperator: Bool {
        return elements.last != "+" && elements.last != "-" && elements.last != "*" && elements.last != "/" && elements.first != nil
    }
    
    var canAddMinusOperator: Bool {
        return elements.first == nil || elements.last != "+ -" && elements.last != "- -" && elements.last != "* -" && elements.last != "/ -"
    }
    
    var canAddDecimalPoint: Bool {
        elements.last != "." && !elements.allSatisfy({ $0.contains(".") }) && !(elements.last?.contains("."))! || elements.isEmpty
    }
    
    var expressionHaveResult: Bool {
        return operation.firstIndex(of: "=") != nil
    }
    
    var conditionForZeroBeforeDecimalPoint: Bool {
        return elements.isEmpty || elements.last == "+" || elements.last == "-" || elements.last == "*" || elements.last == "/"
    }
    
    var expressionIsNotDividedByZero: Bool {
        return !operation.contains("/ 0")
    }
    
    var expressionContainBracket: Bool {
        return operation.contains("(") && operation.contains(")")
    }
    
    var expressionContainsMultiplyOrDivide: Bool {
        elements.firstIndex(of: "*") != nil || elements.firstIndex(of: "/") != nil
    }
    
    let brackets: [Character: Character] = ["(":")"]
    var openBrackets: [Character] { return Array(brackets.keys) }
    var closeBrackets: [Character] { return Array(brackets.values) }
    
    func add(digit: Int) {
        guard !expressionHaveResult else {
            resetOperation()
            operation.append(digit.description)
            return
        }
        operation.append(digit.description)
    }
    
    func addOpeningBracket() {
        guard !expressionHaveResult else {
            resetOperation()
            operation.append("(")
            return
        }
        operation.append("(")
    }
    
    func addClosingBracket() {
        guard !expressionHaveResult else {
            resetOperation()
            operation.append(")")
            return
        }
        operation.append(")")
    }
    
    func add(mathOperator: MathOperator) throws {
        guard !expressionHaveResult else {
            return
        }
        
        if mathOperator != MathOperator.minus  {
            guard canAddOperator else {
                throw CalculatorServiceError.failedToAddMathOperator
            }
        } else {
            guard canAddMinusOperator else {
                throw CalculatorServiceError.failedToAddMathOperator
            }
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
    
    func removeLastAction() {
        guard !operation.isEmpty else {
            return
        }
        operation.removeLast()
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
            let indexOperand: Int?
            
            if (operationsToReduce.firstIndex(of: "*") != nil) {
                indexOperand = operationsToReduce.firstIndex(of: "*")
                print("indexOperand : \(indexOperand!)")
                
                let left = Double(operationsToReduce[indexOperand!-1])!
                print("left : \(left)")
                let right = Double(operationsToReduce[indexOperand!+1])!
                print("right : \(right)")
                
                let result = Double(left * right)
                print("result : \(result)")
                
                operationsToReduce.insert("\(result.clean)", at: indexOperand!-1)
                print("operationToReduce : \(operationsToReduce!)")
                operationsToReduce.remove(at: indexOperand!)
                print("operationToReduce : \(operationsToReduce!)")
                operationsToReduce.remove(at: indexOperand!)
                print("operationToReduce : \(operationsToReduce!)")
                operationsToReduce.remove(at: indexOperand!)
                print("operationToReduce : \(operationsToReduce!)")
                
            } else if (operationsToReduce.firstIndex(of: "/") != nil) {
                indexOperand = operationsToReduce.firstIndex(of: "/")
                
                let left = Double(operationsToReduce[indexOperand!-1])!
                let right = Double(operationsToReduce[indexOperand!+1])!
                
                let result = Double(left / right)
                
                operationsToReduce.insert("\(result.clean)", at: indexOperand!-1)
                operationsToReduce.remove(at: indexOperand!)
                operationsToReduce.remove(at: indexOperand!)
                operationsToReduce.remove(at: indexOperand!)
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
        while operationsToReduce.firstIndex(of: "-") != nil {
            let minusIndex: Int?
            minusIndex = operationsToReduce.firstIndex(of: "-")
            
            if operationsToReduce[minusIndex!+1] == "-" {
                operationsToReduce[minusIndex!+1] = "\(operationsToReduce[minusIndex!+1])\(operationsToReduce[minusIndex!+2])"
                operationsToReduce.remove(at: minusIndex!+2)
            } else if minusIndex == 0 || operationsToReduce[minusIndex!-1] == "+" || operationsToReduce[minusIndex!-1] == "*" || operationsToReduce[minusIndex!-1] == "/" {
                operationsToReduce[minusIndex!] = "\(operationsToReduce[minusIndex!])\(operationsToReduce[minusIndex!+1])"
                operationsToReduce.remove(at: minusIndex!+1)
            }
        }
    }
    
//    private func isBalanced(_ string: String) -> Bool {
//        if string.count % 2 != 0 { return false }
//        var stack: [Character] = []
//        for character in string {
//            if closeBrackets.contains(character) {
//                if stack.isEmpty {
//                    return false
//                } else {
//                    let indexOfLastCharacter = stack.endIndex - 1
//                    let lastCharacterOnStack = stack[indexOfLastCharacter]
//                    if character == brackets[lastCharacterOnStack] {
//                        stack.removeLast()
//                    } else {
//                        return false
//                    }
//                }
//            }
//            if openBrackets.contains(character) {
//                stack.append(character)
//            }
//        }
//
//        return stack.isEmpty
//    }
}


extension Double {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }

}

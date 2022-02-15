//
//  CalculatorService.swift
//  CountOnMe
//
//  Created by Yann Rouzaud on 10/02/2022.
//  Copyright © 2022 Vincent Saluzzo. All rights reserved.
//

import Foundation

enum MathOperator {
    
    case plus
    case minus
    case multiply
    case divide
    
    init?(symbol: Character) {
        switch symbol {
        case "+":
            self = .plus
        case "-":
            self = .minus
        case "*":
            self = .multiply
        case "/":
            self = .divide
        default:
            return nil
        }
    }
    
    var symbol: Character {
        switch self {
        case .plus:
            return "+"
        case .minus:
            return "-"
        case .multiply:
            return "*"
        case .divide:
            return "/"
        }
    }
}


enum CalculatorServiceError: Error {
    case failedToAddMathOperator
    case failedToAddPoint
}


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
    
    var canAddDecimalPoint: Bool {
        elements.last != "." && !elements.allSatisfy({ $0.contains(".") }) && !(elements.last?.contains("."))! || elements.isEmpty
    }
    
    var expressionHaveResult: Bool {
        return operation.firstIndex(of: "=") != nil
    }
    
    var conditionForZeroBeforeDecimalPoint: Bool {
        return elements.isEmpty || elements.last == "+" || elements.last == "-" || elements.last == "*" || elements.last == "/"
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
        guard canAddOperator else {
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
        
        // Create local copy of operations
        var operationsToReduce = elements
        
        // Iterate over operations while an operand still here
        while operationsToReduce.count > 1 {
            let left = Int(operationsToReduce[0])!
            let operand = operationsToReduce[1]
            let right = Int(operationsToReduce[2])!
            
            let result: Int
            switch operand {
            case "+": result = left + right
            case "-": result = left - right
            case "*": result = left * right
            case "/": result = left / right
            default: fatalError("Unknown operator !")
            }
            
            operationsToReduce = Array(operationsToReduce.dropFirst(3))
            operationsToReduce.insert("\(result)", at: 0)
        }
        
        if let operationsToReduceFirst = operationsToReduce.first {
            operation.append(" = \(operationsToReduceFirst)")
        }
        
        return (true, "")
    }
    
    func resetOperation() {
        operation.removeAll()
    }
}

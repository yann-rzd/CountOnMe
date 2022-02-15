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
        return elements.last != "+" && elements.last != "-"
    }
    
    var expressionHaveEnoughElement: Bool {
        return elements.count >= 3
    }
    
    var canAddOperator: Bool {
        return elements.last != "+" && elements.last != "-"
    }
    
    var canAddDecimalPoint: Bool {
        elements.last != "." && !elements.allSatisfy({ $0.contains(".") }) && !(elements.last?.contains("."))!
    }
    
    var expressionHaveResult: Bool {
        return operation.firstIndex(of: "=") != nil
    }
    
    var conditionForZeroBeforeDecimalPoint: Bool {
        return elements.last!.isEmpty || elements.last == "+" || elements.last == "-" || elements.last == "*" || elements.last == "/"
    }

    func add(digit: Int) {
        operation.append(digit.description)
    }
    
    func add(mathOperator: MathOperator) throws {
        guard canAddOperator else {
            throw CalculatorServiceError.failedToAddMathOperator
        }
        
        operation.append(" \(mathOperator.symbol) ")
    }
    
    func add() throws {
        guard canAddDecimalPoint else {
            throw CalculatorServiceError.failedToAddPoint
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
}

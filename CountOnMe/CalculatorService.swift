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
    
    func add(digit: Int) {
        operation.append(digit.description)
    }
    
    func add(mathOperator: MathOperator) throws {
        guard canAddOperator else {
            throw CalculatorServiceError.failedToAddMathOperator
        }
        
        operation.append(" \(mathOperator.symbol) ")
    }
    
    func resetOperation() {
        operation.removeAll()
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
    
    var expressionHaveResult: Bool {
        return operation.firstIndex(of: "=") != nil
    }
}

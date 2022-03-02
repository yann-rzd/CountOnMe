//
//  MathOperator.swift
//  CountOnMe
//
//  Created by Yann Rouzaud on 16/02/2022.
//  Copyright © 2022 Vincent Saluzzo. All rights reserved.
//

import Foundation

enum MathOperator: CaseIterable {

    case plus
    case minus
    case multiply
    case divide
    
    init?(symbolString: String) {
        guard
            symbolString.count == 1,
            let symbol = symbolString.first else {
            return nil
        }
       
        self.init(symbol: symbol)
    }


    init?(symbol: Character) {
        switch symbol {
        case "+":
            self = .plus
        case "-":
            self = .minus
        case "×":
            self = .multiply
        case "÷":
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
            return "×"
        case .divide:
            return "÷"
        }
    }

    var isPriority: Bool {
        switch self {
        case .plus:
            return false
        case .minus:
            return false
        case .multiply:
            return true
        case .divide:
            return true
        }
    }
    
    
    var operation: (Double, Double) -> Double {
        switch self {
        case .plus:
            return { $0 + $1 }
        case .minus:
            return { $0 - $1 }
        case .multiply:
            return { $0 * $1 }
        case .divide:
            return { $0 / $1 }
        }
    }
}

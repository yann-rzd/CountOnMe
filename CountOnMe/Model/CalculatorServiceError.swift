//
//  CalculatorServiceError.swift
//  CountOnMe
//
//  Created by Yann Rouzaud on 16/02/2022.
//  Copyright © 2022 Vincent Saluzzo. All rights reserved.
//

import Foundation

enum CalculatorServiceError: Swift.Error {
    case failedToAddMathOperator
    case failedToAddPoint
    case expressionIsNotCorrect
    case expressionHaveNotEnoughElement
    case expressionHaveResult
    case expressionIsDividedByZero
    
    var errorDescription: String? {
        switch self {
        case .failedToAddMathOperator:
            return "Impossible d'ajouter un opérateur."
        case .failedToAddPoint:
            return "Un point est déjà mis !"
        case .expressionIsNotCorrect:
            return "Veuillez entrer une expression correcte."
        case .expressionHaveNotEnoughElement:
            return "Veuillez démarrer un nouveau calcul."
        case .expressionHaveResult:
            return "L'opération est déjà résolue"
        case .expressionIsDividedByZero:
            return "Impossible de diviser par 0"
        }
    }
}

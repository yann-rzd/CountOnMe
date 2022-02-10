//
//  ViewController.swift
//  SimpleCalc
//
//  Created by Vincent Saluzzo on 29/03/2019.
//  Copyright © 2019 Vincent Saluzzo. All rights reserved.
//

import UIKit

final class CalculatorViewController: UIViewController {
    
    
    @IBOutlet private weak var operationTextView: UITextView!
    @IBOutlet private var numberButtons: [UIButton]!
    
    
    private let calculatorService = CalculatorService()
    
    

    
    // View Life cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatorService.delegate = self
        // Do any additional setup after loading the view.
    }
    

    
    
    
    // View actions
    @IBAction func tappedNumberButton(_ sender: UIButton) {
        calculatorService.add(digit: sender.tag)
    }
    
    @IBAction func didTapMathOperatorButton(_ sender: UIButton) {
        guard let mathOperatorButtonTitleCharacter = sender.title(for: .normal)?.first,
              let mathOperator = MathOperator(symbol: mathOperatorButtonTitleCharacter)
        else {
            presentAlert(message: "Failed to create math operator from button")
            return
        }
        
        
        do {
            try calculatorService.add(mathOperator: mathOperator)
        } catch {
            presentAlert(message: "Un operateur est déja mis !")
        }
    }
    
   
    @IBAction func didTapResetButton() {
        calculatorService.resetOperation()
    }
    
    private func presentAlert(message: String) {
        let alertVC = UIAlertController(title: "Zéro!", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }

    @IBAction func tappedEqualButton(_ sender: UIButton) {
        guard calculatorService.expressionIsCorrect else {
            presentAlert(message: "Entrez une expression correcte !")
            return
        }
        
        guard calculatorService.expressionHaveEnoughElement else {
            presentAlert(message: "Démarrez un nouveau calcul !")
            return
        }
        
        // Create local copy of operations
        var operationsToReduce = calculatorService.elements
        
        // Iterate over operations while an operand still here
        while operationsToReduce.count > 1 {
            let left = Int(operationsToReduce[0])!
            let operand = operationsToReduce[1]
            let right = Int(operationsToReduce[2])!
            
            let result: Int
            switch operand {
            case "+": result = left + right
            case "-": result = left - right
            default: fatalError("Unknown operator !")
            }
            
            operationsToReduce = Array(operationsToReduce.dropFirst(3))
            operationsToReduce.insert("\(result)", at: 0)
        }
        
        operationTextView.text.append(" = \(operationsToReduce.first!)")
    }

}


extension CalculatorViewController: CalculatorServiceDelegate {
    func didUpdateOperation(operation: String) {
        operationTextView.text = operation
    }
    
    
}

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
        calculatorService.resetOperation()
        // Do any additional setup after loading the view.
    }
    
    
    // View actions
    @IBAction func tappedNumberButton(_ sender: UIButton) {
        calculatorService.add(digit: sender.tag)
    }
    
    
    @IBAction func didTapPointButton(_ sender: UIButton) {
        do {
            try calculatorService.add()
        } catch {
            presentAlert(message: "Un point est déja mis !")
        }
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
            presentAlert(message: "Impossible d'ajouter un opérateur.")
        }
    }
    
    

    @IBAction func tappedEqualButton(_ sender: UIButton) {
        let resultStatus = calculatorService.solveOperation()
        
        guard resultStatus.isOperationSolved else {
            return presentAlert(message: resultStatus.message)
        }
    }
    
    @IBAction func didTapResetButton() {
        calculatorService.resetOperation()
    }
    
    
    private func presentAlert(message: String) {
        let alertVC = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }

}


extension CalculatorViewController: CalculatorServiceDelegate {
    func didUpdateOperation(operation: String) {
        operationTextView.text = operation
    }
    
    
}


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
    }

    @IBAction func tappedNumberButton(_ sender: UIButton) {
        calculatorService.add(digit: sender.tag)
    }

    @IBAction func didTapPointButton(_ sender: UIButton) {
        calculatorService.addDecimalPoint()
    }

    @IBAction func didTapMathOperatorButton(_ sender: UIButton) {
        guard let mathOperatorButtonTitleCharacter = sender.title(for: .normal)?.first,
              let mathOperator = MathOperator(symbol: mathOperatorButtonTitleCharacter)
        else {
            presentAlert(message: "Impossible d'ajouter un opérateur.")
            return
        }

        calculatorService.add(mathOperator: mathOperator)
    }

    @IBAction func tappedEqualButton(_ sender: UIButton) {
        calculatorService.solveOperation()
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
    func didProduceError(error: CalculatorServiceError) {
        presentAlert(message: error.errorDescription ?? "")
    }

    func didUpdateOperation(operation: String) {
        operationTextView.text = operation
    }
}

//
//  ViewController.swift
//  Calculator
//
//  Created by Kanstantsin Linou on 7/13/16.
//  Copyright © 2016 Kanstantsin Linou. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{
    @IBOutlet weak var graphButton: UIButton!
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    private func updateUI() {
        descriptionLabel.text = (brain.description.isEmpty ? " " : brain.getDescription())
        displayValue = brain.result
        // Reflect whether or not it is currently possible to graph 
        // what has been entered so far (i.e. whether there is a partial result or not).
        graphButton.enabled = !brain.isPartialResult
    }
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit != "." || textCurrentlyInDisplay.rangeOfString(".") == nil {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.clear()
        displayValue = 0
        userIsInTheMiddleOfTyping = false
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    @IBAction func backspace(sender: UIButton) {
        guard userIsInTheMiddleOfTyping == true else {
            brain.undo()
            updateUI()
            return
        }
        
        guard var number = display.text else {
            return
        }
        
        number.removeAtIndex(number.endIndex.predecessor())
        if number.isEmpty {
            number = "0"
            userIsInTheMiddleOfTyping = false
        }
        display.text = number
    }
    
    private var displayValue: Double? {
        get {
            if let text = display.text, value = NSNumberFormatter().numberFromString(text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.maximumFractionDigits = Constants.Math.numberOfDigitsAfterDecimalPoint
                display.text = formatter.stringFromNumber(value)
                descriptionLabel.text = brain.getDescription()
            } else {
                display.text = "0"
                descriptionLabel.text = " "
                userIsInTheMiddleOfTyping = false
            }
            
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        updateUI()
    }
    
    @IBAction func setVariable() {
        brain.variableValues[Constants.Math.variableName] = displayValue
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
        } else {
            brain.undo()
        }
        // Trick with a computed property
        brain.program = brain.program
        updateUI()
    }
    
    @IBAction func getVariable() {
        brain.setOperand(Constants.Math.variableName)
        userIsInTheMiddleOfTyping = false
        updateUI()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Graph":
                guard !brain.isPartialResult else {
                    NSLog(Constants.Error.partialResult)
                    return
                }
                
                var destinationVC = segue.destinationViewController
                if let nvc = destinationVC as? UINavigationController {
                    destinationVC = nvc.visibleViewController ?? destinationVC
                }
                
                if let vc = destinationVC as? GraphViewController {
                    vc.navigationItem.title = brain.description
                    vc.function = {
                        (x: CGFloat) -> Double in
                        self.brain.variableValues[Constants.Math.variableName] = Double(x)
                        // Trick with a computed property
                        self.brain.program = self.brain.program
                        return self.brain.result
                    }
                }
            default: break
            }
        }
    }
}

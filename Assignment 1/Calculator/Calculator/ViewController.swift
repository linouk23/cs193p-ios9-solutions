//
//  ViewController.swift
//  Calculator
//
//  Created by Kanstantsin Linou on 7/13/16.
//  Copyright © 2016 Kanstantsin Linou. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
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
    
    @IBAction func backspace(sender: UIButton) {
        guard userIsInTheMiddleOfTyping == true else {
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
                formatter.maximumFractionDigits = Constants.numberOfDigitsAfterDecimalPoint
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
        
        displayValue = brain.result
    }
}

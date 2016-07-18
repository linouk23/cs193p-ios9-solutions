//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Kanstantsin Linou on 7/15/16.
//  Copyright © 2016 Kanstantsin Linou. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    var variableValues = [String:Double]()
    
    private var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    private var resultAccumulator = 0.0
    private var internalProgram = [AnyObject]()
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    private var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Precedence.Max
            }
        }
    }
    
    private var currentPrecedence = Precedence.Max
    
    func clear() {
        pending = nil
        resultAccumulator = 0.0
        descriptionAccumulator = "0"
        internalProgram.removeAll()
    }
    
    func setOperand(operand: Double) {
        resultAccumulator = operand
        descriptionAccumulator = String(format:"%g", operand)
        internalProgram.append(operand)
    }
    
    func setOperand(variableName: String) {
        variableValues[variableName] = variableValues[variableName] ?? 0.0
        resultAccumulator = variableValues[variableName]!
        descriptionAccumulator = variableName
        internalProgram.append(variableName)
    }
    
    private enum Precedence: Int {
        case Min = 0, Max
    }

    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({ -$0 }, { "-(\($0))"}),
        "√" : Operation.UnaryOperation(sqrt, { "√(\($0))"}),
        "cos" : Operation.UnaryOperation(cos, { "cos(\($0))"}),
        "x⁻¹" : Operation.UnaryOperation({ 1 / $0 }, { "(\($0))⁻1"}),
        "x²" : Operation.UnaryOperation({ $0 * $0 }, { "(\($0))²"}),
        "×" : Operation.BinaryOperation({ $0 * $1 }, { "\($0) × \($1)"}, Precedence.Max),
        "÷" : Operation.BinaryOperation({ $0 / $1 }, { "\($0) ÷ \($1)"}, Precedence.Max),
        "+" : Operation.BinaryOperation({ $0 + $1 }, { "\($0) + \($1)"}, Precedence.Min),
        "−" : Operation.BinaryOperation({ $0 - $1 }, { "\($0) - \($1)"}, Precedence.Min),
        "rand" : Operation.NullaryOperation( { Double(arc4random()) }, "arc4random()"),
        "=" : Operation.Equals
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Precedence)
        case NullaryOperation(() -> Double, String)
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                resultAccumulator = value
                descriptionAccumulator = symbol
            case .NullaryOperation(let function, let descriptionValue):
                resultAccumulator = function()
                descriptionAccumulator = descriptionValue
            case .UnaryOperation(let resultFunction, let descriptionFunction):
                resultAccumulator = resultFunction(resultAccumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .BinaryOperation(let resultFunction, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence.rawValue < precedence.rawValue {
                    descriptionAccumulator = "(\(descriptionAccumulator))"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: resultFunction, firstOperand: resultAccumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .Equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    func undo() {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
            program = internalProgram
        } else {
            clear()
            descriptionAccumulator = ""
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            resultAccumulator = pending!.binaryFunction(pending!.firstOperand, resultAccumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    var result: Double {
        get {
            return resultAccumulator
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let variableName = op as? String {
                        if variableValues[variableName] != nil {
                            setOperand(variableName)
                        } else if let operation = op as? String {
                            performOperation(operation)
                        }
                    }
                }
            }
        }
    }
    
    func getDescription() -> String {
        let whitespace = (description.hasSuffix(" ") ? "" : " ")
        return isPartialResult ? (description + whitespace  + "...") : (description + whitespace  + "=")
    }
}

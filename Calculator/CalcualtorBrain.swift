//
//  CalcualtorBrain.swift
//  Calculator
//
//  Created by Stéphane Lux on 09.05.16.
//  Copyright © 2016 LUXio IT-Solutions. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private var accumlator = 0.0
    private var internalProgram = [AnyObject]()
    var variableValues: Dictionary<String, Double> = [String : Double]()
    
    var description: String {
        if isPartialResult {
            return pending!.firstDescriptiveOperand + " " + pending!.descriptiveFunction + " " + descriptiveOperand
        } else {
            return descriptiveOperand
        }
    }
    
    private var descriptiveOperand = ""
    private var pendingFirstOperand = ""
    private var pendingSecondOperand = ""
    private var pendingSymbol = ""

    func setOperand(operand: Double){
        accumlator = operand
        internalProgram.append(operand)
        
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 6
        formatter.minimumIntegerDigits = 1
        descriptiveOperand  = formatter.stringFromNumber(operand)!
        
    }
    
    func setOperand(variableName: String) {
        variableValues[variableName] = variableValues[variableName] ?? 0.0
        accumlator = variableValues[variableName]!
        internalProgram.append(variableName)
        descriptiveOperand  = variableName
    }
    
    private var operations: [String: Operation] = [
        "π": Operation.Constant(M_PI),
        "e": Operation.Constant(M_E),
        "±": Operation.UnaryOperation({ -$0 }),
        "√": Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "×": Operation.BinaryOperation({ $0*$1 }),
        "÷": Operation.BinaryOperation({ $0/$1 }),
        "+": Operation.BinaryOperation({ $0+$1 }),
        "−": Operation.BinaryOperation({ $0-$1}),
        "=": Operation.Equals,
        "sin": Operation.UnaryOperation(sin),
        "tan": Operation.UnaryOperation(tan),
        "x²": Operation.UnaryOperation({ pow($0, 2)}),
        "x³": Operation.UnaryOperation({ pow($0, 3)}),
        "%": Operation.UnaryOperation({ $0 * 0.01 })
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    func performOperation(symbol: String){
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumlator = value;
                descriptiveOperand = symbol
            case .UnaryOperation(let function):
                accumlator = function(accumlator);
                descriptiveOperand = "\(symbol)(\(descriptiveOperand))"
            case .BinaryOperation(let function):
                executePendingBinrayOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumlator, descriptiveFunction: symbol, firstDescriptiveOperand: descriptiveOperand)
                descriptiveOperand = ""
            case .Equals:
                executePendingBinrayOperation()
            }
        }
    }
    
    private func executePendingBinrayOperation() {
        if pending != nil {
            descriptiveOperand = "\(pending!.firstDescriptiveOperand) \(pending!.descriptiveFunction) \(descriptiveOperand == "" ? pending!.firstDescriptiveOperand : descriptiveOperand)"
            accumlator = pending!.binaryFunction(pending!.firstOperand, accumlator)
            pending = nil
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
    
    
    var isPartialResult: Bool  {
        return pending != nil ? true : false
    }
    
    
    func clear() {
        accumlator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptiveFunction : String
        var firstDescriptiveOperand: String
    }
    
    var result: Double {
        get {
            return accumlator
        }
    }
    
    
    func undoLastOperation() {
        if internalProgram.count > 0 {
            internalProgram.removeLast()
            program = internalProgram
        } else {
            clear()
            descriptiveOperand = ""
        }
    }
    
}
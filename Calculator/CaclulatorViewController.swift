//
//  ViewController.swift
//  Calculator
//
//  Created by Stéphane Lux on 06.05.16.
//  Copyright © 2016 LUXio IT-Solutions. All rights reserved.
//

import UIKit

class CaclulatorViewController: UIViewController {
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func touchDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentInDisplay = display.text!
            display.text = textCurrentInDisplay + (digit == "." && textCurrentInDisplay.rangeOfString(".") != nil ? "" : digit)
        } else {
            display.text = digit == "." ? "0." : digit
        }
        userIsInTheMiddleOfTyping = true
        
    }
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            let formatter = NSNumberFormatter()
            formatter.maximumFractionDigits = 6
            formatter.minimumIntegerDigits = 1
            //display.text = String(format: "%.6f", newValue)
            display.text = formatter.stringFromNumber(newValue)
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        savedProgram = brain.program
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
        }
        
        userIsInTheMiddleOfTyping = false
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        updateUI()
        
    }
    
    private func updateUI() {
        if brain.description != "" {
            descriptionLbl.text = brain.description + (brain.isPartialResult ? " ..." : " =")
        } else {
            descriptionLbl.text = " "
        }
        displayValue = brain.result
    }
    
    @IBAction private func clearBtnTouched(sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        brain = CalculatorBrain()
        updateUI()
    }
    
    @IBAction func setVariableM(sender: UIButton) {
        brain.variableValues["M"] = displayValue
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
        } else {
            brain.undoLastOperation()
        }
        brain.program = brain.program
        updateUI()
    }
    
    @IBAction func MBtnTouches(sender: UIButton) {
        brain.setOperand("M");
        userIsInTheMiddleOfTyping = false
        updateUI()
    }
    
    @IBAction func UndoBtnTouched(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if var displayText = display.text {
                displayText = String(displayText.characters.dropLast())
                if displayText.characters.count == 0 {
                    displayText = "0"
                    userIsInTheMiddleOfTyping = false
                }
                display.text = displayText
            }
        } else {
            brain.undoLastOperation()
            updateUI()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Show Graph":
                if brain.isPartialResult {return}
                var destinationVC = segue.destinationViewController
                if let navcon = destinationVC as? UINavigationController {
                    destinationVC = navcon.visibleViewController ?? destinationVC
                }
                if let graphVC = destinationVC as? GraphViewController {
                    // @TODO: setup graphvc
                    graphVC.navigationItem.title = brain.description;
                    graphVC.graphFunction = self.getYfor(_:)
                    
                }
            default: break
            }
        }
    }

    func getYfor(x: Double) -> Double {
        // store version of M
        let savedM = brain.variableValues["M"];
        brain.variableValues["M"] = x;
        brain.program = brain.program
        let y = brain.result;

        // restore old value
        brain.variableValues["M"] = savedM;

        return y;
    }

    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        // @TODO: should check if is partial result
        return true
    }
    
}


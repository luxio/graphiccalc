//
//  GraphViewController.swift
//  Calculator
//
//  Created by Stéphane Lux on 23.06.16.
//  Copyright © 2016 LUXio IT-Solutions. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    var graphFunction: ((Double ) -> Double)! {
        didSet {
            updateUI()
        }
    }
    var test:Double!
    
    
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(GraphView.changeScale(_:))))
            
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(GraphView.panGraph(_:))))
            
            let tapGestureRecognzier = UITapGestureRecognizer(target: graphView, action: #selector(GraphView.moveOrigin(_:)))
            tapGestureRecognzier.numberOfTapsRequired = 2
            graphView.addGestureRecognizer(tapGestureRecognzier)
            
            graphView.function = graphFunction
            
            updateUI()
        }
    }
    
    private func updateUI() {
        graphView?.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  GraphView.swift
//  Calculator
//
//  Created by Stéphane Lux on 23.06.16.
//  Copyright © 2016 LUXio IT-Solutions. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    @IBInspectable
    var graphColor:UIColor = UIColor.redColor()
    @IBInspectable
    var scale: CGFloat = 50.0 { didSet { self.setNeedsDisplay() } }
    @IBInspectable
    var lineWidth: CGFloat = 1.0
    var graphOrigin: CGPoint! { didSet {self.setNeedsDisplay() } }
    
    
    //var function: (x: Double) -> Double = { return $0*$0 }
    var function: ((x: Double) -> Double)?
    
    func changeScale(regognizer: UIPinchGestureRecognizer) {
        switch regognizer.state {
        case .Changed,.Ended:
            scale *= regognizer.scale
            regognizer.scale = 1.0
        default:
            break
        }
    }
    
    func panGraph(regognizer: UIPanGestureRecognizer) {
        switch regognizer.state {
        case .Changed, .Ended:
            let translation = regognizer.translationInView(self)
            regognizer.setTranslation(CGPointZero, inView: self)
            graphOrigin.x += translation.x
            graphOrigin.y += translation.y
        default:
            break
        }
    }
    
    func moveOrigin(regognizer: UITapGestureRecognizer) {
        switch regognizer.state {
        case .Ended:
            graphOrigin = regognizer.locationInView(self)
        default:
            break
        }
        
    }
    
    override func drawRect(rect: CGRect) {
        // set default orgin to center
        graphOrigin = graphOrigin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        
        //let axes = AxesDrawer()
        let axes = AxesDrawer(contentScaleFactor: self.contentScaleFactor)
        axes.drawAxesInRect(bounds, origin: graphOrigin, pointsPerUnit: scale)
        drawGraph();
    }
    
    func drawGraph() {
        
        if let graphFunction = function {
            
            let graph = UIBezierPath()
            
            var x = bounds.minX
            
            graph.moveToPoint(CGPoint(x: x, y: getYfor(x, function: graphFunction)))
            x += 1 / self.contentScaleFactor
            
            var startNew = false;
            
            while x <= bounds.maxX {
                let y = getYfor(x, function: graphFunction)
                if (y.isNormal || y.isZero ){
                    startNew ? graph.moveToPoint(CGPoint( x: x, y: y )) : graph.addLineToPoint(CGPoint( x: x, y: y ))
                    startNew = false
                } else {
                    startNew = true
                }
                x += 1
            }
            
            graphColor.setStroke()
            graph.lineWidth = lineWidth
            graph.stroke()
        }
    }
    
    private func getYfor(x: CGFloat, function: (x: Double) -> Double) -> CGFloat {
        let x1 = Double(x - graphOrigin.x) / Double(scale)
        var y1 = function(x: x1)
        y1 = Double(bounds.maxY + ( graphOrigin.y - bounds.maxY ) ) -  (y1 * Double(scale))
        return CGFloat(y1)
    }
    
}

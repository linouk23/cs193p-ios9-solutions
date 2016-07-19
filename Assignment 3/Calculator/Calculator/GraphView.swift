//
//  GraphView.swift
//  Calculator
//
//  Created by Kanstantsin Linou on 7/18/16.
//  Copyright © 2016 Kanstantsin Linou. All rights reserved.
//

import UIKit

protocol GraphViewDataSource {
    func getBounds() -> CGRect
    func getYCoordinate(x: CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView: UIView{
    
    @IBInspectable
    var origin: CGPoint! { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var scale = CGFloat(Constants.Drawing.pointsPerUnit) { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var color = UIColor.blackColor() { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    
    var dataSource: GraphViewDataSource?
    private let drawer = AxesDrawer(color: UIColor.blueColor())
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        // Set default origin to center
        origin = origin ?? CGPoint(x: bounds.midX, y: bounds.midY)
        
        color.set()
        pathForFunction().stroke()
        
        drawer.drawAxesInRect(dataSource?.getBounds() ?? bounds, origin: origin, pointsPerUnit: scale)
    }
    
    private func pathForFunction() -> UIBezierPath {
        let path = UIBezierPath()
        
        guard let data = dataSource else {
            NSLog(Constants.Error.data)
            return path
        }
        
        var pathIsEmpty = true
        var point = CGPoint()
        
        // Iterate over every pixel (not point) across the width of your view and
        // draw a line to (or just “move to” if the last datapoint was not valid)
        // the next datapoint you get (if it is valid).
        let width = Int(bounds.size.width * scale)
        for pixel in 0...width {
            point.x = CGFloat(pixel) / scale
            
            if let y = data.getYCoordinate((point.x - origin.x) / scale) {
                
                // Do something sensible when graphing discontinuous functions
                // only try to draw lines to or from points whose y value .isNormal or .isZero)
                if !y.isNormal && !y.isZero {
                    // Move the path to the next point
                    pathIsEmpty = true
                    continue
                }
                
                // As the origin (of the view coordinate system) is upper left and units are points, not pixels
                point.y = origin.y - y * scale
                
                if pathIsEmpty {
                    // Set the path’s current point before we call this addLineToPoint: method
                    // If the path is empty, addLineToPoint: does nothing.
                    path.moveToPoint(point)
                    pathIsEmpty = false
                } else {
                    path.addLineToPoint(point)
                }
            }
        }
        
        path.lineWidth = lineWidth
        return path
    }
    
    // Move the origin of the graph to the point of the double tap
    func doubleTap(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .Ended {
            origin = recognizer.locationInView(self)
        }
    }
    
    func zoom(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    func move(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed: fallthrough
        case .Ended:
            let translation = recognizer.translationInView(self)
            // Update anything that depends on the pan gesture using translation.x and translation.y
            origin.x += translation.x
            origin.y += translation.y
            // Cumulative since start of recognition, get 'incremental' translation
            recognizer.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }
}

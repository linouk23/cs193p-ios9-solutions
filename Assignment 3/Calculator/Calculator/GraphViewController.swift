//
//  GraphViewController.swift
//  Calculator
//
//  Created by Kanstantsin Linou on 7/18/16.
//  Copyright © 2016 Kanstantsin Linou. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource {
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            
            // Since we don't need to update the model after recognizing gestures, target is the outlet itself (not view controller)
            
            // a. Pinching (zooms the entire graph, including the axes, in or out on the graph)
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: #selector(graphView.zoom(_:))))
            
            
            // b. Panning (moves the entire graph, including the axes, to follow the touch around)
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: #selector(graphView.move(_:))))
            
            // c. Double-tapping (moves the origin of the graph to the point of the double tap)
            let recognizer = UITapGestureRecognizer(target: graphView, action: #selector(graphView.doubleTap(_:)))
            recognizer.numberOfTapsRequired = 2 // single tap, double tap, etc.
            graphView.addGestureRecognizer(recognizer)
        }
    }

    func getBounds() -> CGRect {
        return navigationController?.view.bounds ?? view.bounds
    }
    
    func getYCoordinate(x: CGFloat) -> CGFloat? {
        if let function = function {
            return CGFloat(function(x))
        }
        return nil
    }
    
    var function: (CGFloat -> Double)?
}

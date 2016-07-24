//
//  BallView.swift
//  Breakout
//
//  Created by Kanstantsin Linou on 7/24/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit

class BallView: UIView {
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return UIDynamicItemCollisionBoundsType.Ellipse
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.blueColor().setFill()
        path.fill()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.whiteColor()
    }
}

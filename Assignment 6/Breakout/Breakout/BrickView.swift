//
//  BrickView.swift
//  Breakout
//
//  Created by Kanstantsin Linou on 7/24/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit

class BrickView: UIView {
    var numberOfHits = 1 {
        didSet {
            if (numberOfHits == 1) {
                UIView.animateWithDuration(0.4) { self.backgroundColor = UIColor.purpleColor() }
            } else {
                UIView.animateWithDuration(0.4, animations: {
                    self.transform = CGAffineTransformMakeScale(0.05, 0.05)})
                    { _ in self.removeFromSuperview() }
            }
        }
    }
}

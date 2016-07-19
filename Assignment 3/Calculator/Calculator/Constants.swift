//
//  Constants.swift
//  Calculator
//
//  Created by Kanstantsin Linou on 7/17/16.
//  Copyright © 2016 Kanstantsin Linou. All rights reserved.
//

import Foundation

struct Constants {
    struct Math {
        static let numberOfDigitsAfterDecimalPoint = 6
        static let variableName = "M"
    }
    
    struct Drawing {
        static let pointsPerUnit = 40.0
    }
    
    struct Error {
        static let data = "Calculator: DataSource wasn't found"
        static let partialResult = "Calculator: Trying to draw a partial result"
    }
}

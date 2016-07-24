//
//  Settings.swift
//  StanfordBreakout
//
//  Created by Michael Flynn on 11/9/15.
//  Copyright © 2015 MRF. All rights reserved.
//

import Foundation

class Settings {
    
    static let sharedInstance = Settings()
    
    private struct UserConstants {
        static let ballSpeed = "BallSpeed"
        static let numberOfBricks = "NumberOfBricks"
        struct Defaults {
            static let ballSpeed = NSNumber(float: 300)
            static let numberOfBricks = NSNumber(int: 15)

        }
    }
    
    var ballSpeed: Float {
        get {
            if let ballSpeed = NSUserDefaults.standardUserDefaults().valueForKey(UserConstants.ballSpeed) as? NSNumber {
                return ballSpeed.floatValue
            } else {
                return UserConstants.Defaults.ballSpeed.floatValue
            }
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setValue(NSNumber(float: newValue), forKey: UserConstants.ballSpeed)
        }
    }
    
    var numberOfBricks: NSInteger {
        get {
            if let numberOfBricks = NSUserDefaults.standardUserDefaults().valueForKey(UserConstants.numberOfBricks) as? NSNumber {
                return numberOfBricks.integerValue
            } else {
                return UserConstants.Defaults.numberOfBricks.integerValue
            }
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setValue(NSNumber(integer: newValue), forKey: UserConstants.numberOfBricks)
        }
    }
}

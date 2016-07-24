//
//  SettingsTVC.swift
//  Breakout
//
//  Created by Kanstantsin Linou on 7/24/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit

class SettingsTVC: UITableViewController {
    @IBOutlet private weak var ballSpeedSlider: UISlider!
    @IBOutlet private weak var numberOfBricksStepper: UIStepper!
    @IBOutlet private weak var numberOfBricksLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ballSpeedSlider.value = Settings.sharedInstance.ballSpeed
        self.numberOfBricksStepper.value = Double(Settings.sharedInstance.numberOfBricks)
        self.numberOfBricksLabel.text = String(Settings.sharedInstance.numberOfBricks)
    }
    
    @IBAction private func ballSpeedChanged(sender: UISlider) {
        Settings.sharedInstance.ballSpeed = sender.value
    }
    
    @IBAction private func numberOfBricksChanged(sender: UIStepper) {
        Settings.sharedInstance.numberOfBricks = Int(sender.value)
        numberOfBricksLabel.text = String(Int(sender.value))
    }
}

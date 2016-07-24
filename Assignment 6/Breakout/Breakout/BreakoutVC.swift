//
//  FirstViewController.swift
//  StanfordBreakout
//
//  Created by Michael Flynn on 11/9/15.
//  Copyright © 2015 MRF. All rights reserved.
//

import UIKit

class BreakoutVC: UIViewController, UIDynamicAnimatorDelegate, BreakoutBehaviorDelegate {
    private struct Constants {
        static let NumberOfBricksPerRow = 5
        static let BrickGap: CGFloat = 8
        static let BrickHeight: CGFloat = 30
        static let PaddleHeight: CGFloat = 20
        static let PaddleWidth: CGFloat = 80
        static let PaddleGap: CGFloat = 30
        static let BallSize: CGFloat = 20
    }
    
    private var gameInProgress = false
    private var paddleView: UIView?
    private let breakoutBehavior = BreakoutBehavior()
    @IBOutlet private weak var gameView: UIView!
    
    private lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        breakoutBehavior.breakoutBehaviorDelegate = self
        animator.addBehavior(breakoutBehavior)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        clear()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reset()
    }
    
    private func clear() {
        breakoutBehavior.clear()
        gameView.subviews.forEach{ $0.removeFromSuperview() }
    }
    
    private func reset() {
        gameInProgress = false
        let numberOfBricks = Settings.sharedInstance.numberOfBricks
        let brickWidth = (gameView.frame.size.width - CGFloat(CGFloat(Constants.NumberOfBricksPerRow + 1) * Constants.BrickGap)) / CGFloat(Constants.NumberOfBricksPerRow)
        
        var bricksRowIndex = 0
        for numberOfUsedBricks in 0.stride(to: numberOfBricks, by: Constants.NumberOfBricksPerRow) {
            for bricksColumnIndex in 0..<5 {
                if numberOfUsedBricks + bricksColumnIndex >= numberOfBricks {
                    break
                }
                
                let brickView = BrickView(frame: CGRectMake(CGFloat(bricksColumnIndex) * (Constants.BrickGap + brickWidth) + Constants.BrickGap, CGFloat(bricksRowIndex) * (Constants.BrickGap + Constants.BrickHeight) + Constants.BrickGap, brickWidth, Constants.BrickHeight))
                    brickView.numberOfHits = 1                
                breakoutBehavior.addBrick(brickView)
            }
            bricksRowIndex += 1
        }
        
        paddleView = UIView(frame: CGRectMake(0, gameView.frame.size.height - Constants.PaddleHeight - Constants.PaddleGap, Constants.PaddleWidth, Constants.PaddleHeight))
        paddleView!.backgroundColor = UIColor.greenColor()
        paddleView!.center.x = gameView.center.x
        breakoutBehavior.addPaddle(paddleView!)
    }
    
    private func startGame() {
        gameInProgress = true
        let ballView = BallView(frame: CGRectMake(0, CGRectGetMinY(self.paddleView!.frame) - Constants.BallSize, Constants.BallSize, Constants.BallSize))
        ballView.center.x = paddleView!.center.x
        breakoutBehavior.addBall(ballView)
        
    }
    
    @IBAction private func tap(sender: UITapGestureRecognizer) {
        if !gameInProgress {
            startGame()
        }
    }
    
    @IBAction private func pan(sender: UIPanGestureRecognizer) {
        if !gameInProgress {
            return
        }
        
        if sender.state == .Changed || sender.state == .Ended {
            if let paddleView = self.paddleView {
                paddleView.center.x += sender.translationInView(gameView).x * 1.5
                sender.setTranslation(CGPointZero, inView: gameView)
                breakoutBehavior.updatePaddlePosition(paddleView)
            }
        }
    }
    
    func gameOver(playerWon: Bool) {
        guard gameInProgress == true else {
            return
        }
        if (playerWon) {
            let alert = UIAlertController(title: "Congratulations!", message: "You've won!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Game Over!", message: "You've lost.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
        
        gameInProgress = false
        clear()
        reset()
    }
}

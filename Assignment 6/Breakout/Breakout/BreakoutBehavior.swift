//
//  BreakoutBehavior.swift
//  Breakout
//
//  Created by Kanstantsin Linou on 7/24/16.
//  Copyright © 2016 self.edu. All rights reserved.
//

import UIKit

class BreakoutBehavior: UIDynamicBehavior, UICollisionBehaviorDelegate {
    var breakoutBehaviorDelegate: BreakoutBehaviorDelegate?
    private var brickCount = 0
    private var remainingBrickCount = 0
    
    private struct CollisionBorders {
        static let LeftWall = "Left Wall"
        static let TopWall = "Top Wall"
        static let RightWall = "Right Wall"
        static let Paddle = "Paddle"
        static let Brick = "Brick"
    }
    
    private struct Constants {
        static let pathX = 0.5
        static let pathY = 0.5
    }
    
    private lazy var collisionBehavior: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = false
        lazilyCreatedCollider.collisionDelegate = self
        return lazilyCreatedCollider
    }()
    
    private lazy var elasticBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedBehavior = UIDynamicItemBehavior()
        lazilyCreatedBehavior.allowsRotation = false
        lazilyCreatedBehavior.elasticity = 1.0
        lazilyCreatedBehavior.friction = 0
        lazilyCreatedBehavior.resistance = 0
        return lazilyCreatedBehavior
    }()
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(elasticBehavior)
    }
    
    func clear() {
        collisionBehavior.removeAllBoundaries()
        collisionBehavior.items.forEach{ collisionBehavior.removeItem($0) }
        collisionBehavior.items.forEach{ elasticBehavior.removeItem($0) }
        brickCount = 0
    }
    
    func addBall(ball: BallView) {
        if let referenceView = dynamicAnimator?.referenceView {
            referenceView.addSubview(ball)
            collisionBehavior.addItem(ball)
            elasticBehavior.addItem(ball)
            pushBall(ball)
            collisionBehavior.addBoundaryWithIdentifier(CollisionBorders.LeftWall, fromPoint: CGPoint(x: 0, y: referenceView.frame.size.height), toPoint: CGPoint(x: 0, y: 0))
            collisionBehavior.addBoundaryWithIdentifier(CollisionBorders.TopWall, fromPoint: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: referenceView.frame.size.width, y: 0))
            collisionBehavior.addBoundaryWithIdentifier(CollisionBorders.RightWall, fromPoint: CGPoint(x: referenceView.frame.size.width, y: 0), toPoint: CGPoint(x: referenceView.frame.size.width, y: referenceView.frame.size.height))
            collisionBehavior.addBoundaryWithIdentifier(CollisionBorders.TopWall, fromPoint: CGPoint(x: 0, y: 0), toPoint: CGPoint(x: referenceView.frame.size.width, y: 0))
            
            remainingBrickCount = Settings.sharedInstance.numberOfBricks
        }
    }
    
    private func pushBall(ball: UIView) {
        if let animator = dynamicAnimator {
            let pushBehavior = UIPushBehavior(items: [ball], mode: UIPushBehaviorMode.Instantaneous)
            
            pushBehavior.action = {
                pushBehavior.removeItem(ball)
                animator.removeBehavior(pushBehavior)
            }
            
            pushBehavior.addItem(ball)
            pushBehavior.pushDirection = CGVector(dx: Constants.pathX, dy: Constants.pathY)
            pushBehavior.magnitude = CGFloat(Settings.sharedInstance.ballSpeed / 1000.0)
            animator.addBehavior(pushBehavior)
            pushBehavior.active = true
            action = {
                if ball.center.y > self.dynamicAnimator?.referenceView!.frame.maxY {
                    if let delegate = self.breakoutBehaviorDelegate {
                        delegate.gameOver(false)
                    }
                }
            }
            
        }
    }
    
    func addBrick(brick: UIView) {
        if let referenceView = dynamicAnimator?.referenceView {
            brick.alpha = 0
            referenceView.addSubview(brick)
            UIView.animateWithDuration(1) { brick.alpha = 1 }
            brickCount += 1
            brick.tag = brickCount
            collisionBehavior.addBoundaryWithIdentifier(CollisionBorders.Brick + String(brickCount), forPath: UIBezierPath(rect: brick.frame))
        }
    }
    
    func addPaddle(paddle: UIView) {
        paddle.alpha = 0
        dynamicAnimator?.referenceView?.addSubview(paddle)
        UIView.animateWithDuration(1) { paddle.alpha = 1 }
        self.updatePaddlePosition(paddle)
    }
    
    func updatePaddlePosition(paddle: UIView) {
        collisionBehavior.removeBoundaryWithIdentifier(CollisionBorders.Paddle)
        collisionBehavior.addBoundaryWithIdentifier(CollisionBorders.Paddle, forPath: UIBezierPath(ovalInRect: paddle.frame))
    }
    
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        guard let view = dynamicAnimator?.referenceView, let identifier = identifier as? String
            where identifier.rangeOfString(CollisionBorders.Brick) != nil else {
            return
        }
        
        let stringTag = identifier.substringFromIndex(CollisionBorders.Brick.endIndex)
        if let brickView = view.viewWithTag(Int(stringTag)!) as? BrickView {
            brickView.numberOfHits -= 1
            if brickView.numberOfHits == 0 {
                collisionBehavior.removeBoundaryWithIdentifier(identifier)
                remainingBrickCount -= 1
                if remainingBrickCount == 0 {
                    if let delegate = breakoutBehaviorDelegate {
                        delegate.gameOver(true)
                    }
                }
            }
        }
    }
}

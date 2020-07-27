//
//  ExpressionViewController.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 7/21/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import RealityKit

class ExpressionViewController: MinigameViewController {
        
    @IBOutlet weak var faceImageView: UIImageView!
    @IBOutlet weak var expressionLabel: UILabel!
    @IBOutlet weak var timeLeftProgressBar: UIProgressView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var attemptsLabel: UILabel!
    
    var currentFaceAnchor: ARFaceAnchor?
    var currentFrame: ARFrame?
    
    //List of possible expression instances
    var expressionsToUse: [Expression] = [SmileExpression(), EyebrowsRaisedExpression(), EyeBlinkLeftExpression(), EyeBlinkRightExpression(), JawOpenExpression()]
    
    var currentExpression: Expression? = nil {
        didSet {
            if currentExpression != nil {
                self.currentExpressionShownAt = Date()
                self.expressionLabel.text = currentExpression!.name()
            } else {
                self.currentExpressionShownAt = nil
                self.expressionLabel.text = "Waiting for next expression..."
            }
        }
    }
    var currentExpressionShownAt: Date? = nil

    var attemptsLeft = 3 {
        didSet {
            self.attemptsLabel.text = "\(self.attemptsLeft)"
        }
    }
    var currentPoints = 0 {
        didSet {
            self.pointsLabel.text = String(currentPoints)
        }
    }
    
    var totalExpressionsShown = 0
    var totalExpressionsSucceeded = 0
    
    /// changes dynamically during a game session
    var maxPointsAwardedPerExpression = 999
    
    /// changes dynamically during a game session
    var currentStage = 0
    
    /// changes dynamically during a game session
    var timeIntervalPerExpression: TimeInterval = 999.0
    
    /// changes dynamically during a game session
    var timeIntervalBetweenExpressions: TimeInterval = 999.0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.startGame()
        }
    }
    
}

// MARK: ARSessionDelegate
extension ExpressionViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.currentFrame = frame
        DispatchQueue.main.async {
            // need to call heart beat on main thread
            self.processNewARFrame()
        }
    }
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first(where: {anchor in
            if anchor is ARFaceAnchor {
                return true
            }
            else {
                return false
            }
        }) else {
            return
        }
        self.currentFaceAnchor = faceAnchor as! ARFaceAnchor
    }
    
    func processNewARFrame() {
        //Check that an expression is currently being displayed, and that ARKit is correctly tracking the player's expression
        if let currentExpression = self.currentExpression, let shownAt = self.currentExpressionShownAt, let faceAnchor = self.currentFaceAnchor {
            
            let timeSinceShown = Date().timeIntervalSince(shownAt)
            
            // Calculate the percentage of time left for progress bar
            let percentLeft = 1.0 - (timeSinceShown / self.timeIntervalPerExpression)
            self.timeLeftProgressBar.progress = Float(percentLeft)
            
            // Fail the expression when time is up; satisfied when there is time ramaining and doing the right expression
            if percentLeft < 0.0 {
                // failed :(
                self.failedCurrentExpression()
            } else if currentExpression.isExpressing(from: faceAnchor) && !currentExpression.isDoingWrongExpression(from: faceAnchor) {
                // succeeded! (but only if they're not also doing the wrong expression, like raising both eyebrows)
                self.hasSatisifiedCurrentExpression()
            }
        }
    }
}

// MARK: Game Logic
extension ExpressionViewController {
    
    func startGame() {
        //Set all game variables to their starting values
        self.currentStage = 0
        self.totalExpressionsShown = 0
        self.totalExpressionsSucceeded = 0
        self.currentPoints = 0
        self.maxPointsAwardedPerExpression = 10
        self.attemptsLeft = 3
        self.timeIntervalPerExpression = 2.0
        self.timeIntervalBetweenExpressions = 1.3
        self.pointsLabel.text = "0"

        //Prepare for the first expression
        self.expressionLabel.text = "Ready…"
        self.timeLeftProgressBar.progress = 1.0
        
        //Show the first expression
        self.showNextExpressionWhenReady()
    }
    
    func showNextExpressionWhenReady() {
        self.currentExpression = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + timeIntervalBetweenExpressions) {
            //Document the expression
            self.totalExpressionsShown += 1
            
            // Adjust the "stage" (aka difficulty)
            if self.currentStage < 1 && self.totalExpressionsShown > 8 {
                // speed things up
                self.timeIntervalPerExpression = 1.5
                self.maxPointsAwardedPerExpression = 50
                self.timeIntervalBetweenExpressions = 1.0
                self.currentStage = 1
            } else if self.currentStage == 1 && self.totalExpressionsShown > 16 {
                // speed up even more!
                self.timeIntervalPerExpression = 1.1
                self.maxPointsAwardedPerExpression = 100
                self.timeIntervalBetweenExpressions = 0.8
                self.currentStage = 2
            } else if self.currentStage == 2 && self.totalExpressionsShown > 25 {
                // ultra hard
                self.timeIntervalPerExpression = 0.9
                self.maxPointsAwardedPerExpression = 400
                self.timeIntervalBetweenExpressions = 0.6
                self.currentStage = 3
            }
            
            // Assign a random expression to currentExpression
            let randomExpression = self.expressionsToUse.randomItem()!
            self.currentExpression = randomExpression
        }
    }
    
    ///Called if the player correctly mimics the expression
    /// - Adds the correct amount of points, documents the success, and shows the next expression
    func hasSatisifiedCurrentExpression() {
        self.currentPoints += self.pointsToAwardFromCurrentExpression()
        self.totalExpressionsSucceeded += 1
        self.showNextExpressionWhenReady()
    }
    
    ///Calculates the appropriate amount of points to award from a correct expression
    /// - Based off of time left
    func pointsToAwardFromCurrentExpression() -> Int {
        guard let shownAt = self.currentExpressionShownAt else {
            return 0
        }
        
        // figure out percentage through current expression
        let timeSinceShown = Date().timeIntervalSince(shownAt)
        // calculate actual points earned (considering precentLeft)
        let points = Int(Double(self.maxPointsAwardedPerExpression) * (1.0 - (timeSinceShown / self.timeIntervalPerExpression))) + 1
        
        if points > 0 {
            return points
        } else {
            return 0
        }
    }
    
    ///Called if the player fails to mimic the expression in the allotted time
    /// - Detracts from player's attempts
    /// - Ends game if none left
    func failedCurrentExpression() {
        self.expressionLabel.doIncorrectAttemptShakeAnimation()
        self.attemptsLeft -= 1
        
        //if no attempts left, end the game
        if self.attemptsLeft == 0 {
            self.currentExpression = nil
            self.expressionLabel.text = "Game Over"
        } else {
            self.showNextExpressionWhenReady()
        }
    }
}

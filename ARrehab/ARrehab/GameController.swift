//
//  GameController.swift
//  ARrehab
//
//  Created by Eric Wang on 2/14/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit

class GameController {
    /// The different game states.
    indirect enum State: Equatable {
        /// The initial state, which immediately transitions to appStart.
        case begin
        
        /// The app has started but has not yet displayed the game menu.
        case appStart
        
        /// The app is displaying the game menu.
        case menu
        
        /// The player is attempting to locate a playable real-world surface.
        case placingContent
        
        /// Game content is loading and the app is waiting for the load to complete before transitioning to the next state.
        case waitingForContent(nextState: State)
        
        /// The game is ready for the player to roll the dice.
        case readyToRoll
        
        /// The player has rolled and is moving along the board.
        case movingToPosition
        
        /// The player has moved to the desired location.
        case positionReached
    }
    
    /// A series of constants that control aspects of game behavior.
    let settings = GameSettings()   // TODO: enable physical therapists to customize.
    
    /// The app's Reality File anchored scene (from Reality Composer).
    var gameAnchor: Experience.Box!
    
    /// The game board
    var gameBoard = Board(numTiles: settings.numTiles, length: settings.areaDim[0], width: settings.areaDim[1])
    
    /// The game dice
    var gameDice: Entity
    
    /// The current state of the game.
    private var currentState: State
    
    init() {
        currentState = .begin
    }
    
    /// Begins the game from application launch.
    func begin() {
        transition(to: .appStart)
    }
    
    /// Informs the game controller that the player is ready to play the game.
    func playerReadyToBeginPlay() {
        transition(to: .placingContent)
    }
    
    /// Informs the game controller that the player is ready to roll dice.
    func playerReadyToRoll() {
        transition(to: .readyToRoll)
    }
    
    
    /// Causes a state transition.
    private func transition(to state: State) {
        guard state != currentState else { return }
        
        func transitionToAppStart() {
            // TODO: change loadBoxAsync to loading whatever stage it is.
            Experience.loadBoxAsync { [weak self] result in
                switch result {
                case .success(let game):
                    guard let self = self else { return }
                    
                    if self.gameAnchor == nil {
                        self.gameAnchor = game
                    }
                    
                    if case let .waitingForContent(nextState) = self.currentState {
                        self.transition(to: nextState)
                    }
                case .failure(let error):
                    print("Unable to load the game with error: \(error.localizedDescription)")
                }
            }
            
            transition(to: .menu)
        }
        
        func transitionToMenu() {
        }
        
        func transitionToPlacingContent() {
        }
        
        func transitionToReadyToRoll() {
            if gameAnchor == nil {
                transition(to: .waitingForContent(nextState: .readyToRoll))
            } else {
            }
        }
        /*
        func transitionToBallAtRest() {
            let currentGame = gameNumber
            DispatchQueue.main.asyncAfter(deadline: .now() + settings.frameSettleDelay) {
                guard currentGame == self.gameNumber else { return }
                
                // It's been a while and we're still on this game. Assume we have a stuck bowling frame.
                self.completeBowlingFrame()
            }
        }
        
        func transitionToFrameComplete(striking struckPinCount: Int) {
            observer?.gameController(self, completedBowlingFrameWithStruckPins: struckPinCount)
        } */
        
        func transitionToMovingToPosition() {
            
        }
        
        func transitionToPositionReached() {
            
        }
        
        func transitionToWaitingForContent(for nextState: State) {
            if gameAnchor != nil {
                transition(to: nextState)
            }
        }

        currentState = state
        switch state {
        case .begin: break
        case .appStart: transitionToAppStart()
        case .menu: transitionToMenu()
        case .placingContent: transitionToPlacingContent()
        case .readyToRoll:
            transitionToReadyToRoll()
        case .movingToPosition:
            transitionToMovingToPosition()
        case .positionReached:
            transitionToPositionReached()
        case let .waitingForContent(nextState): transitionToWaitingForContent(for: nextState)
        }
    }
}

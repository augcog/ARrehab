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
    
    
    
}

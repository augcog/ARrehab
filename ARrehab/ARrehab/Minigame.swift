//
//  Minigame.swift
//  ARrehab
//
//  Created by Eric Wang on 3/19/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit
import Combine

/**
 Minigames available to play
 
 Use ```Minigame.allCases.randomElement()!``` to get a random minigame.
 */
enum Game : CaseIterable {
    // List of minigames.
    case trace
    
    /**
     Returns a new instance of the minigame.
     */
    func makeNewInstance() -> Minigame{
        switch self {
        case .trace:
            return TraceGame()
        }
    }
}

/**
 Protocol all Minigames conform to.
 */
protocol Minigame : Entity {
        
    /// Initializes the minigame. Adding it to the scene as appropriate.
    ///
    /// - Parameter ground: an Entity to used as a parent for items in fixed locations.
    /// - Parameter player: an Entity that represents the player. This will be used as a parent for elements that need to update with the camera.
    init(ground: Entity, player: Entity)
    
    /**
     Add to the scene as appropriate
     
     Uses the player's current location to determine the inital transofrm of the minigame.
     
     - parameters:
        - ground:  an Entity to used as a parent for items in fixed locations.
        - player:  an Entity that represents the player. This will be used as a parent for elements that need to update with the camera.
     */
    func attach(ground: Entity, player: Entity)
    
    /**
     Start running the minigame, enabling associated entities if required.
     - Returns: If game has started successfully.
     */
    func run() -> Bool
    
    /**
     Removes the minigame from the scene;
     Returns the score of the minigame in the range [0.0, 1.0].
     */
    func endGame() -> Float
    
    /// Score / completion status of the minigame in the range [0.0, 1.0]
    func score() -> Float
}

extension Minigame {
    init(ground: Entity, player: Entity) {
        self.init()
        attach(ground: ground, player: player)
    }
}

/**
 Minigame Controller. Manages minigame instances and their visibility.
 */
class MinigameController {
    
    var currentMinigame : Minigame? = nil
    var ground: Entity
    var player: Entity
    
    init(ground: Entity, player: Entity) {
        self.ground = ground
        self.player = player
    }
    
    /**
     Sets up a new Trace Minigame if no game is currently in progress.
     */
    func enableMinigame(){
        guard currentMinigame == nil else {
             print("A Minigame is already active!")
             return
        }
        enableMinigame(game: .trace)
    }
    
    /**
     Sets up a new Minigame if no game is currently in progress.
     - Parameters:
        - game: the game to set up.
     */
    func enableMinigame(game: Game){
        guard currentMinigame == nil else {
             print("A Minigame is already active!")
             return
        }
        currentMinigame = game.makeNewInstance()
        currentMinigame!.attach(ground: ground, player: player)
        currentMinigame?.run()
    }
    
    /**
     Removes the current game in progress, if any.
    */
    func disableMinigame(){
        guard currentMinigame != nil else {
            print("No minigame active")
            return
        }
        currentMinigame?.endGame()
        currentMinigame = nil
    }
    
    /**
     Returns the score of the current minigame in progress [0, 1].
     If no game in progress, returns 0.
     */
    func score() -> Float{
        guard currentMinigame != nil else {
            return 0.0
        }
        return currentMinigame!.score()
    }
}

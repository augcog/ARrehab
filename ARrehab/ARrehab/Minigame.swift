//
//  Minigame.swift
//  ARrehab
//
//  Created by Eric Wang on 3/19/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit

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
            return TraceTarget()
        }
    }
    
}

protocol Minigame {
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
     Deinitialize the Minigame.
     Removing it from the scene.
     Returns the completion status of the minigame in the range [0.0, 1.0].
     */
    func endGame() -> Float
}

class TraceTarget : Entity, Minigame { //TODO: Replace with actual TraceTarget class upon merge.
    required convenience init(ground: Entity, player: Entity) {
        self.init()
        attach(ground: ground, player: player)
    }
    
    required init() {
        super.init()
    }
    
    func attach(ground: Entity, player: Entity) {
        return
    }
    
    func endGame() -> Float {
        return 1.0
    }
}

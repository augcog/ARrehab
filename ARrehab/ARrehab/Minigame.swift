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
    case movement
    
    /**
     Returns a new instance of the minigame.
     */
    func makeNewInstance() -> Minigame{
        switch self {
        case .trace:
            return TraceGame()
        case .movement:
            return MovementGame(num: 3)
        }
    }
}

/**
 Protocol all Minigames conform to.
 */
class Minigame : Entity {
        
    /// Score / completion status of the minigame in the range [0.0, 100.0]
    @Published var score : Float
    
    /// Initializes the minigame. Adding it to the scene as appropriate.
    ///
    /// - Parameter ground: an Entity to used as a parent for items in fixed locations.
    /// - Parameter player: an Entity that represents the player. This will be used as a parent for elements that need to update with the camera.
    convenience init(ground: Entity, player: Entity) {
        self.init()
        attach(ground: ground, player: player)
    }
    
    required init() {
        self.score = 0
        super.init()
    }
    
    /**
     Add to the scene as appropriate
     
     Uses the player's current location to determine the inital transofrm of the minigame.
     
     - parameters:
        - ground:  an Entity to used as a parent for items in fixed locations.
        - player:  an Entity that represents the player. This will be used as a parent for elements that need to update with the camera.
     */
    func attach(ground: Entity, player: Entity) {
        fatalError("attach() has not been implemented")
    }
    
    /**
     Start running the minigame, enabling associated entities if required.
     - Returns: If game has started successfully.
     */
    func run() -> Bool {
        fatalError("run() has not been implemented")
    }
    
    /**
     Removes the minigame from the scene;
     Returns the score of the minigame in the range [0.0, 1.0].
     */
    func endGame() -> Float {
        fatalError("endGame() has not been implemented")
    }
}

/**
 Minigame Controller. Manages minigame instances and their visibility.
 */
class MinigameController {
    
    var currentMinigame : Minigame? = nil
    var ground: Entity
    var player: Entity
    
    /**
     the score of the current minigame in progress [0, 100]. If no game in progress,  0 or last game's score.
     */
    @Published var score: Float
    var cancellable : [Cancellable]
    
    init(ground: Entity, player: Entity) {
        self.ground = ground
        self.player = player
        self.score = 0
        self.cancellable = []
    }
    
    /**
     Sets up a new Trace Minigame if no game is currently in progress.
     */
    func enableMinigame(){
        guard currentMinigame == nil else {
             print("A Minigame is already active!")
             return
        }
        //enableMinigame(game: .trace)
        enableMinigame(game: .movement)
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
        cancellable.append(currentMinigame!.$score.sink{ score in
            guard self.currentMinigame != nil else {
                self.score = 0.0
                return
            }
            self.score = score
        })
        currentMinigame!.attach(ground: ground, player: player)
        currentMinigame!.run()
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
        cancellable.forEach { (subscription) in
            subscription.cancel()
        }
        self.cancellable = []
    }
}

//
//  ExpressionGame.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 7/21/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import ARKit
import RealityKit

class ExpressionGame: Minigame {
    
    override func attach(ground: Entity, player: Entity) -> Void {
        //do nothing
    }
    
    override func run() -> Bool {
        return true
    }
    
    override func endGame() -> Float {
        //sth about ending the game
        return 12.3
    }
    
}

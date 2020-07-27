//
//  ARFaceGame.swift
//  ARrehab
//
//  Created by Alan Zhang on 2020/6/6.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit
import UIKit
import ARKit

class FaceGame: Minigame {
    
    
    override func attach(ground: Entity, player: Entity) -> Void {
        //do nothing
    }
    
    override func run() -> Bool {
        //sth about running the game
        return true
    }
    
    override func endGame() -> Float {
        //sth about ending the game
        return 12.3
    }
}

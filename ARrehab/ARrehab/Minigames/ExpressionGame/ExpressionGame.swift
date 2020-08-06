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

/**
 Expression Minigame.
 Prompts you to make various facial expressions.
 */
class ExpressionGame: Minigame {
    // Lets put requiresSession into the overall Minigame class.
    static var requiresSession: Bool = true
    var arSession: ARSession
    
    init(session: ARSession) {
        self.arSession = session
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    // TODO consider just merging attach and run in all minigames.
    override func attach(ground: Entity, player: Entity) -> Void {
        
    }
    
    override func run() -> Bool {
        let faceConfig = ARWorldTrackingConfiguration()
        faceConfig.userFaceTrackingEnabled = true
        faceConfig.worldAlignment = .gravity
        
        self.arSession.delegate = self.viewController as? ARSessionDelegate
        self.arSession.run(faceConfig)
        
        return true
    }
    
    override func endGame() -> Float {
        //sth about ending the game
        let defaultConfig = ARWorldTrackingConfiguration()
        self.arSession.run(defaultConfig, options: [])
        self.arSession.delegate = self.viewController.parent as! ARSessionDelegate
        // TODO return score / completion status.
        return 10
    }
    
}

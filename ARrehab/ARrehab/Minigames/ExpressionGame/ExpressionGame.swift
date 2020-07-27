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
    
    static var requiresSession: Bool = true
    var arSession: ARSession
    
    init(session: ARSession) {
        self.arSession = session
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
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
        
        return 10
    }
    
}

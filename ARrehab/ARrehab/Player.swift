//
//  Player.swift
//  ARrehab
//
//  Created by Eric Wang on 2/24/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit

class Player : Entity, HasModel, HasCollision, HasAnchoring{
    
    required init(target: AnchoringComponent.Target) {
        super.init()
        self.components[AnchoringComponent] = AnchoringComponent(target)
        self.components[ModelComponent] = ModelComponent(mesh: MeshResource.generateBox(width: 2, height: 2, depth: 2), materials: [SimpleMaterial(color: SimpleMaterial.Color.blue, isMetallic: false)])
        self.components[CollisionComponent] = CollisionComponent(shapes: [ShapeResource.generateBox(width: 0.1, height: 0.1, depth: 0.1)], mode: .trigger, filter: .sensor)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}

//
//  Tile.swift
//  ARrehab
//
//  Created by Sanath Sengupta on 2/23/20.
//  Copyright © 2020 Eric Wang. All rights reserved.
//

import Foundation
import RealityKit
import CoreGraphics

class Tile : Entity, HasModel, HasCollision {
    
    var entity: ModelEntity
    var name: String
    
    
    init(name: String, x: Float, z: Float) {
        
        self.name = name
        self.entity = ModelEntity(mesh: MeshResource.generateBox(width: 0.5, height: 0.01, depth: 0.5), materials: [SimpleMaterial()], collisionShape: ShapeResource.generateBox(width: 0.5, height: 6.0, depth: 0.5), mass: 0.0)
        self.entity.transform.translation = SIMD3<Float>(x,0.0,z)
        
    }
    
}

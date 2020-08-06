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
    
    //Class attributes
    static let SCALE: Float = 0.75
    static let TILE_SIZE = SIMD3<Float>(0.5, 0.1, 0.5) * Tile.SCALE
    static let TILE_COLLISION_GROUP = CollisionGroup(rawValue: 1) //Totally arbitrary number
    
    static let defaultTileModel = ModelComponent(mesh: MeshResource.generateBox(size: Tile.TILE_SIZE, cornerRadius: 0.2), materials: [SimpleMaterial()])
    static let defaultCollisionComp = CollisionComponent(shapes: [ShapeResource.generateBox(width: Tile.TILE_SIZE.x, height: 4.0, depth: Tile.TILE_SIZE.z).offsetBy(translation: SIMD3<Float>(0,2,0))], mode: .trigger, filter: CollisionFilter(group: Tile.TILE_COLLISION_GROUP, mask: Player.PLAYER_COLLISION_GROUP))

    
    //Instance variables
    var tileName: String
    let coords : Coordinates
    
    
    //Default initializer: Uses default model and collision componenets
    required init(name: String, x: Float, z: Float) {
        self.tileName = name
        self.coords = Coordinates(x: x, z: z)
        
        super.init()

        self.components[ModelComponent] = Tile.defaultTileModel
        self.components[CollisionComponent] = Tile.defaultCollisionComp
        
        self.transform.translation = self.coords.translation
        print("Generated Tile: " + name)
    }
    
    //Optional initializer: Allows specification of custom model components
    convenience init(name: String, x: Float, z: Float, materials: [Material]?) {
        
        self.init(name: name, x: x, z: z)
        
        if materials != nil {
            self.changeMaterials(materials: materials!)
        }
        
        print("Generated Tile: " + name)
    }
    
    required init() {
        fatalError("Can't instantiate a Tile with no paramaters")
    }
}


//Nested data types and convenience methods
extension Tile {
    
    struct Coordinates : Hashable, Equatable {
        
        var x : Float
        var z : Float
        var coordVec : SIMD2<Float> {
            get {
                return SIMD2<Float>(x, z)
            }
            set (newCoords) {
                x = newCoords.x
                z = newCoords.y
            }
        }
        var translation: SIMD3<Float> {
            get {
                return SIMD3<Float>(x, 0.0, z)
            }
        }
        
        init(x: Float, z: Float) {
            self.x = x
            self.z = z
        }
        
        func localVec(center: Coordinates) -> SIMD2<Int> {
            let local = coordVec - center.coordVec
            return SIMD2<Int>(Int(local.x / Tile.TILE_SIZE.x), Int(local.y / Tile.TILE_SIZE.z))
        }
        
    }
    
    /**
     Changes the material attribute of the tile's Model Component
     */
    func changeMaterials(materials: [Material]) {
        self.model?.materials = materials
    }
    
}
